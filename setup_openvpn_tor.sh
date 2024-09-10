# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Variables
OVPN_SERVER_IP=$(curl -s ifconfig.me)
OVPN_SUBNET="10.8.0.0/24"
OVPN_INTERFACE="tun0"
TOR_DNS_PORT="53530"
TOR_TRANS_PORT="9040"
CLIENT_CONF=$(pwd)/client.ovpn  # Save the client configuration in the current directory
EASYRSA_DIR=$(pwd)/openvpn-ca  # Use the current directory for Easy-RSA

# Update and install necessary packages
apt-get update
apt-get install -y openvpn easy-rsa tor htop telegram-send

# Configure OpenVPN
make-cadir $EASYRSA_DIR
cd $EASYRSA_DIR

# Initialize PKI and build CA
./easyrsa init-pki
./easyrsa build-ca nopass

# Generate server certificate, key, and DH parameters
./easyrsa gen-req server nopass
./easyrsa sign-req server server
./easyrsa gen-dh

# Generate TLS key
openvpn --genkey secret ta.key
cp ta.key /etc/openvpn/

# Copy the server keys and certificates
cp pki/ca.crt pki/issued/server.crt pki/private/server.key pki/dh.pem /etc/openvpn/

# Generate client certificate and key
./easyrsa gen-req client nopass
./easyrsa sign-req client client

# Copy client certificate and key
cp pki/issued/client.crt pki/private/client.key /etc/openvpn/

# Create OpenVPN server configuration
cat > /etc/openvpn/server.conf <<EOF
port 1194
proto udp
dev $OVPN_INTERFACE
ca ca.crt
cert server.crt
key server.key
dh dh.pem
tls-auth ta.key 0
cipher AES-256-CBC
auth SHA256
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS $OVPN_SERVER_IP"
keepalive 10 120
persist-key
persist-tun
status openvpn-status.log
verb 3
EOF

# Enable OpenVPN to start at boot
systemctl enable openvpn@server

# Install and configure Tor
cat > /etc/tor/torrc <<EOF
VirtualAddrNetwork 10.192.0.0/10
AutomapHostsOnResolve 1
DNSPort 10.8.0.1:$TOR_DNS_PORT
TransPort 10.8.0.1:$TOR_TRANS_PORT
EOF

# Enable Tor to start at boot
systemctl enable tor

# Configure IPtables for routing through Tor
iptables -A INPUT -i $OVPN_INTERFACE -s 10.8.0.0/24 -m state --state NEW -j ACCEPT
iptables -t nat -A PREROUTING -i $OVPN_INTERFACE -p udp --dport 53 -s 10.8.0.0/24 -j DNAT --to-destination 10.8.0.1:$TOR_DNS_PORT
iptables -t nat -A PREROUTING -i $OVPN_INTERFACE -p tcp -s 10.8.0.0/24 -j DNAT --to-destination 10.8.0.1:$TOR_TRANS_PORT
iptables -t nat -A PREROUTING -i $OVPN_INTERFACE -p udp -s 10.8.0.0/24 -j DNAT --to-destination 10.8.0.1:$TOR_TRANS_PORT

# Save the IPtables rules
iptables-save > /etc/iptables/rules.v4

# Generate the OpenVPN client configuration in the current directory
cat > $CLIENT_CONF <<EOF
client
dev tun
proto udp
remote $OVPN_SERVER_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
auth SHA256
key-direction 1
verb 3

<ca>
$(cat /etc/openvpn/ca.crt)
</ca>

<cert>
$(cat /etc/openvpn/client.crt)
</cert>

<key>
$(cat /etc/openvpn/client.key)
</key>

<tls-auth>
$(cat /etc/openvpn/ta.key)
</tls-auth>
EOF

# Restart Tor and OpenVPN to apply changes
systemctl restart tor
systemctl restart openvpn@server

# Send the OVPN file via Telegram
telegram-send --file $CLIENT_CONF --caption "Your OpenVPN configuration file"

# Start a screen session and launch htop
screen -S openvpn-monitor -d -m htop

# Output final instructions
echo "OpenVPN and Tor setup is complete."
echo "Your client configuration has been sent via Telegram."
echo "To monitor the system, attach to the screen session using: screen -r openvpn-monitor"
