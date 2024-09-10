
***Tutorial: Automated Setup of OpenVPN and Tor with Telegram Integration:***
This tutorial will walk you through using a set of scripts to automatically configure OpenVPN, Tor, and send the config through Telegram on your VPS. You'll need to clone the repository, give the necessary permissions to the scripts, and run them to get OpenVPN, Tor, and Telegram set up and working.

***Prerequisites***

A VPS with Ubuntu or a similar Linux distribution.

Root access to your VPS.

A Telegram account with a bot token to be used with telegram-send.

***Step 1: Clone the Repository***

SSH into your VPS and navigate to the directory where you'd like to clone the repository.
Use the following command to clone the repository from GitHub:
```bash
git clone https://github.com/CoreConnect-dev/ConnecTOR-vpn
```

Change into the cloned directory:
```bash
cd ConnecTOR-vpn
```
***Step 2: Make Scripts Executable***
Before running the scripts, you'll need to ensure that they have the correct executable permissions. To do so, run the following command:

```bash
chmod +x setup_telegram.sh setup_openvpn_tor.sh
```

***Step 3: Run the Telegram Setup Script***
The first script you'll need to run is setup_telegram.sh, which installs and configures telegram-send on your VPS. This tool is used to send messages or files via Telegram. The script will also test the configuration by sending a test message to your Telegram.

Run the script:

```bash
sudo ./setup_telegram.sh
```

***This script will:***

Install telegram-send.
Configure it by prompting you to link it to your Telegram bot.
Send a test message to confirm that Telegram notifications are working.
After running this script, and adding your telegram token you should receive a message saying "Telegram setup complete! You can now receive notifications from your VPS."

***If you don't have a telegram token yet, follow this tutorial:***

***How to Get a Telegram Token and Create a Bot Using BotFather:***

To use telegram-send, you need to create a Telegram bot and get the bot's API token. Follow the steps below to set up your bot and retrieve the token.

***Step 1: Open Telegram and Start a Conversation with BotFather***

Open the Telegram app and search for “[BotFather](https://t.me/BotFather)” in the search bar.
Start a conversation with BotFather by clicking on it.
Type /start to begin interacting with BotFather.

***Step 2: Create a New Bot***

Type /newbot and hit enter.
BotFather will ask you to name your bot. Choose a descriptive name for your bot (e.g., MyVPSTelegramBot).
After naming the bot, BotFather will ask for a username for your bot. The username must end with bot. For example, myvps_bot or notifications_bot.

***Step 3: Get the Telegram Bot Token***

Once you've chosen a valid username, [BotFather](https://t.me/BotFather) will confirm the creation of your bot and send you the bot's API token. It will look something like this:

```123456789:ABCDefghIjklMnopQRstUVwxyz1234567```

This token is essential for configuring telegram-send.

***Step 4: Use the Token in the setup_telegram.sh Script***

During the telegram-send configuration step (which happens when you run setup_telegram.sh), you will be prompted to enter this bot token to link telegram-send with your bot. Simply copy and paste the token you received from BotFather when prompted.

Once you've entered the token, Telegram will automatically link the bot to your VPS, and you can start sending notifications and files directly from your server.

***Step 4: Run the OpenVPN and Tor Setup Script***

Next, run the setup_openvpn_tor.sh script to install and configure OpenVPN, Tor, and all necessary components.

Run the script:

```bash
sudo ./setup_openvpn_tor.sh
```

This script will:

Install OpenVPN, Easy-RSA, Tor, htop, and telegram-send.
Configure OpenVPN with Easy-RSA for certificate management.
Set up an OpenVPN server configuration and generate a client configuration file.
Configure Tor to work as a transparent proxy that routes traffic through it.
Configure IPtables to ensure traffic is routed correctly.
Automatically restart OpenVPN and Tor services.
Send the OpenVPN client configuration (client.ovpn) via Telegram.
Start a screen session and run htop for monitoring the VPS performance.

***Step 5: Use the OpenVPN Client Configuration***

Once the script is complete, you will receive your OpenVPN client configuration file (client.ovpn) via Telegram. You can download this file and use it with any OpenVPN client to connect to your VPS securely.

***Step 6: Monitor the System***
The script also launches a screen session running htop to allow you to monitor the system in real-time. To attach to the screen session and view the htop output, run the following command:

```bash
screen -r openvpn-monitor
```
If you need to detach from the screen session, press Ctrl + A followed by D.
