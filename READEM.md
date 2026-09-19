🐸 FROGZZ PTERODACTYL INSTALLER V5

All-In-One Pterodactyl Panel + Wings Installer

Installer otomatis untuk melakukan deployment Pterodactyl Panel + Wings dari VPS Ubuntu fresh sampai Panel dan Node siap digunakan.

Installer menyediakan menu untuk memilih:

- Pterodactyl Panel Version
- Pterodactyl Wings Version
- Domain Panel
- Domain Node
- Owner Panel
- Location
- Node
- Wings Port
- SFTP Port

Sebagian besar konfigurasi dibuat otomatis agar proses instalasi dari VPS fresh menjadi lebih sederhana.

---

✨ FEATURES

- 🚀 Full Pterodactyl Panel Installer
- 🪽 Full Pterodactyl Wings Installer
- 🐧 Ubuntu 22.04 LTS
- 🐧 Ubuntu 24.04 LTS
- 🎛️ Panel Version Selector
- 🎛️ Wings Version Selector
- 👑 Automatic Panel Owner
- 🗄️ Automatic MariaDB
- ⚡ Automatic Redis
- 🌐 Automatic Nginx
- 🐘 Automatic PHP
- 📦 Automatic Composer
- 🐳 Automatic Docker
- 🔐 Automatic SSL
- 📍 Automatic Location
- 🖥️ Automatic Node
- 🪽 Automatic Wings Configuration
- 🔥 Automatic UFW
- 🔌 Automatic Wings Port
- 📡 Automatic SFTP Port
- 🟢 Automatic Node Verification
- 🔧 Wings Repair Menu
- 📋 Installation Log
- 🔑 Credentials File
- ♻️ Systemd Service Configuration

---

🖥️ REQUIREMENTS

Supported Operating System

Operating System| Status
Ubuntu 22.04 LTS| ✅ Supported
Ubuntu 24.04 LTS| ✅ Supported
Ubuntu 20.04| ❌ Not Supported
Debian| ❌ Not Supported
CentOS| ❌ Not Supported

Recommended VPS

OS          : Ubuntu 22.04 / 24.04
Access      : Root
IPv4        : Public IPv4
Virtualizer : KVM Recommended
RAM         : 2 GB+
Disk        : 20 GB+

For production hosting, use resources according to the number of servers and workloads you plan to run.

---

🌐 BEFORE INSTALLATION

Before running the installer, prepare:

1. Fresh Ubuntu VPS
2. Root access
3. Public IPv4
4. Panel domain
5. Node domain
6. DNS records pointing to VPS
7. Ports 80 and 443 accessible
8. VPS provider firewall configured if applicable

Example:

Panel:
panel.example.com

Node:
node.example.com

Both domains should point to the VPS IP.

---

☁️ CLOUDFLARE DNS

If you use Cloudflare, during installation it is recommended to use:

DNS Only

Example:

panel.example.com  → DNS Only
node.example.com   → DNS Only

This allows the installer to obtain and verify the Let's Encrypt certificate directly.

After the installation is complete, you can adjust your Cloudflare configuration according to your setup.

---

🚀 INSTALLATION

1. LOGIN TO VPS

From your computer or phone SSH application:

ssh root@YOUR_VPS_IP

Example:

ssh root@123.123.123.123

Enter your VPS root password.

---

2. UPDATE UBUNTU

Run:

apt update && apt upgrade -y

Wait until the process finishes.

---

3. INSTALL GIT

apt install git -y

Check Git:

git --version

---

4. CLONE INSTALLER

Clone the repository:

git clone https://github.com/YogzzOktz/InstallerV5ByFrogzzNew.git

Enter the directory:

cd InstallerV5ByFrogzzNew

Check files:

ls -lah

Expected:

README.md
install-pterodactyl-frogzz.sh

---

5. GIVE EXECUTE PERMISSION

chmod +x install-pterodactyl-frogzz.sh

---

6. START INSTALLER

Run:

./install-pterodactyl-frogzz.sh

Or:

bash install-pterodactyl-frogzz.sh

---

🎛️ INSTALLER MENU

The installer provides a main menu similar to:

╔════════════════════════════════════════════════════════════╗
║                                                            ║
║          FROGZZ PTERODACTYL INSTALLER V5                  ║
║                                                            ║
║                 PANEL + WINGS                              ║
║                                                            ║
╠════════════════════════════════════════════════════════════╣
║                                                            ║
║  [1] FULL INSTALL                                          ║
║      Fresh VPS → Panel → Owner → Node → GREEN             ║
║                                                            ║
║  [2] REPAIR WINGS                                          ║
║      Repair / Restart Wings                                ║
║                                                            ║
║  [0] EXIT                                                  ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝

For a fresh VPS, choose:

1

---

🧩 FULL INSTALL FLOW

The Full Install process handles the installation in stages:

VPS CHECK
    ↓
SYSTEM UPDATE
    ↓
DEPENDENCIES
    ↓
PHP
    ↓
MARIA DB
    ↓
REDIS
    ↓
NGINX
    ↓
COMPOSER
    ↓
PTERODACTYL PANEL
    ↓
PANEL DATABASE
    ↓
OWNER ACCOUNT
    ↓
SSL
    ↓
DOCKER
    ↓
WINGS
    ↓
LOCATION
    ↓
NODE
    ↓
WINGS CONFIG
    ↓
UFW
    ↓
WINGS SERVICE
    ↓
NODE VERIFICATION
    ↓
🟢 GREEN

---

🎛️ PANEL VERSION

The installer provides a Panel version selection menu.

Example:

╔══════════════════════════════════════════╗
║        PTERODACTYL PANEL VERSION        ║
╠══════════════════════════════════════════╣
║ [1] v1.15.1                             ║
║ [2] Other Available Version             ║
╚══════════════════════════════════════════╝

Select the version you want to install.

The available options depend on the installer release.

---

🪽 WINGS VERSION

The installer also provides Wings version selection.

Example:

╔══════════════════════════════════════════╗
║         PTERODACTYL WINGS VERSION       ║
╠══════════════════════════════════════════╣
║ [1] v1.13.3                             ║
║ [2] Other Available Version             ║
╚══════════════════════════════════════════╝

Choose the Wings version you want.

Make sure the selected Panel and Wings versions are compatible.

---

🌐 PANEL DOMAIN

The installer will ask for the Panel domain.

Example:

Panel Domain:
panel.example.com

The installer uses this domain for the Panel URL.

After installation:

https://panel.example.com

---

🪽 NODE DOMAIN

The installer will ask for the Node domain.

Example:

Node Domain:
node.example.com

This domain is used by Wings.

Example:

https://node.example.com

---

📧 LET'S ENCRYPT EMAIL

Enter an email address for Let's Encrypt.

Example:

admin@example.com

This email is used for SSL certificate registration and renewal notifications.

---

👑 PANEL OWNER

The installer automatically creates the first Panel administrator.

Example:

First Name:
Frogzz

Last Name:
Official

Username:
frogzz

Email:
admin@example.com

Password:
YOUR-STRONG-PASSWORD

After installation, use this account to access the Panel.

No manual Owner creation should be necessary when the automated step succeeds.

---

🗄️ DATABASE

The installer automatically prepares the database required by Pterodactyl.

Components include:

MariaDB
Redis
Pterodactyl Database
Pterodactyl Database User

Database credentials are generated/configured during installation.

---

🔐 SSL

The installer configures Let's Encrypt SSL.

Expected Panel URL:

https://panel.example.com

Expected Node URL:

https://node.example.com

SSL certificates should be successfully issued before the final Node verification.

---

🐳 DOCKER

Docker is installed automatically because Wings requires Docker to manage server containers.

Check Docker:

systemctl status docker

Check Docker information:

docker info

Restart Docker:

systemctl restart docker

---

🔌 AUTOMATIC PORTS

You do not need to manually calculate Wings and SFTP ports.

The installer checks available ports automatically.

Default starting values:

Wings:
8080

SFTP:
2022

If a port is already occupied, the installer searches for another available port.

Example:

Wings:
8080 → 8081 → 8082 → ...

SFTP:
2022 → 2023 → 2024 → ...

The selected ports are then used for:

Panel Node
Wings Configuration
UFW
Node Verification

---

📍 LOCATION

The installer automatically creates a Pterodactyl Location.

Example:

Location:
Indonesia

This Location is then assigned to the new Node.

---

🖥️ NODE CREATION

The installer automatically creates the Node.

Example:

Node Name:
Node-01

Location:
Indonesia

FQDN:
node.example.com

Scheme:
https

Wings Port:
8080

SFTP Port:
2022

Actual ports may differ because the installer automatically selects available ports.

---

🪽 WINGS CONFIGURATION

After creating the Node, the installer obtains the Node configuration and writes it to:

/etc/pterodactyl/config.yml

Wings binary:

/usr/local/bin/wings

Pterodactyl directory:

/etc/pterodactyl

---

⚙️ WINGS SERVICE

Wings runs through systemd.

Start:

systemctl start wings

Stop:

systemctl stop wings

Restart:

systemctl restart wings

Enable on boot:

systemctl enable wings

Check:

systemctl status wings

---

🟢 NODE GREEN VERIFICATION

The installer performs verification after configuring Wings.

The process is:

Create Location
       ↓
Create Node
       ↓
Generate Node Configuration
       ↓
Write config.yml
       ↓
Start Wings
       ↓
Check Wings Service
       ↓
Check Node Endpoint
       ↓
Verify Connectivity
       ↓
🟢 GREEN

The installer should not treat the Node as successfully configured merely because the Wings process started.

Both the service and connectivity need to be checked.

---

🔥 UFW FIREWALL

The installer configures UFW.

Expected ports include:

22/tcp
80/tcp
443/tcp
Wings Port/tcp
SFTP Port/tcp

Check:

ufw status

Check listening ports:

ss -lntp

---

🔑 CREDENTIALS

The installer saves installation information to:

/root/pterodactyl-credentials.txt

The file may contain:

Panel URL
Owner Username
Owner Email
Owner Password
Panel Version
Wings Version
Node Name
Location
Wings Port
SFTP Port
Database Information

Protect the file:

chmod 600 /root/pterodactyl-credentials.txt

Do not upload this file to GitHub.

Do not share it publicly.

---

📋 INSTALLATION LOG

Installer logs are stored at:

/var/log/frogzz-pterodactyl-installer.log

View the complete log:

cat /var/log/frogzz-pterodactyl-installer.log

View the latest lines:

tail -n 100 /var/log/frogzz-pterodactyl-installer.log

Follow the log:

tail -f /var/log/frogzz-pterodactyl-installer.log

---

📁 IMPORTANT PATHS

Pterodactyl Panel

/var/www/pterodactyl

Wings Configuration

/etc/pterodactyl/config.yml

Wings Directory

/etc/pterodactyl

Wings Binary

/usr/local/bin/wings

Pterodactyl Server Volumes

/var/lib/pterodactyl/volumes

Installer Log

/var/log/frogzz-pterodactyl-installer.log

Credentials

/root/pterodactyl-credentials.txt

---

🧪 BASIC HEALTH CHECK

After installation, run:

systemctl status nginx

systemctl status mariadb

systemctl status redis-server

systemctl status docker

systemctl status wings

All required services should be active.

---

🌐 PANEL CHECK

Open:

https://panel.example.com

Login using the Owner account created during installation.

Then open:

Admin Panel
    ↓
Nodes
    ↓
Your Node

Check the Node connection status.

---

🪽 WINGS LOG

If the Node is offline:

journalctl -u wings -n 100 --no-pager

For live logs:

journalctl -u wings -f

---

🐳 DOCKER CHECK

If Wings reports Docker problems:

systemctl status docker

Then:

docker info

If necessary:

systemctl restart docker

Restart Wings afterward:

systemctl restart wings

---

🔌 PORT CHECK

Check all listening ports:

ss -lntp

Example:

LISTEN 0 4096 0.0.0.0:80
LISTEN 0 4096 0.0.0.0:443
LISTEN 0 4096 0.0.0.0:8080
LISTEN 0 4096 0.0.0.0:2022

Your actual Wings/SFTP ports may be different.

---

🔧 REPAIR WINGS

If Wings becomes offline after installation, run:

cd InstallerV5ByFrogzzNew

Then:

./install-pterodactyl-frogzz.sh

Choose:

[2] REPAIR WINGS

Or manually restart:

systemctl restart wings

Then check:

systemctl status wings

---

❌ TROUBLESHOOTING

Panel Does Not Open

Check Nginx:

nginx -t

systemctl status nginx

Check PHP:

systemctl status php8.3-fpm

Check Panel:

cd /var/www/pterodactyl
php artisan about

---

Node Is Offline

Check Wings:

systemctl status wings

Check logs:

journalctl -u wings -n 100 --no-pager

Check Docker:

systemctl status docker

Check configuration:

ls -lah /etc/pterodactyl/

Check ports:

ss -lntp

Check firewall:

ufw status

Also verify that the VPS provider's external firewall/security group allows the selected Wings and SFTP ports.

---

SSL Failed

Verify DNS:

getent ahostsv4 panel.example.com

getent ahostsv4 node.example.com

Both should return the VPS IP.

Also make sure port "80/tcp" is reachable from the internet.

If using Cloudflare, verify that the records are correctly configured.

---

DNS Not Ready

If the domain was created immediately before installation, DNS propagation may not have completed yet.

Check:

getent ahostsv4 panel.example.com

and:

getent ahostsv4 node.example.com

Do not continue with SSL installation until the DNS records resolve correctly.

---

🛡️ FRESH VPS RECOMMENDATION

This installer is intended primarily for:

Fresh Ubuntu VPS

Avoid running it on a server that already contains:

Pterodactyl
Wings
Docker
Nginx
MariaDB
Redis
Existing production websites

unless you understand the changes being made.

The installer may modify system packages, services, firewall rules, web server configuration, databases, Docker and Pterodactyl files.

Always keep backups of important data.

---

📦 INSTALLATION SUMMARY

The complete installation looks like:

┌─────────────────────────────┐
│       FRESH UBUNTU VPS      │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│       RUN INSTALLER         │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│       SELECT VERSIONS        │
│   PANEL + WINGS VERSION      │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│       PANEL INSTALL          │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│       OWNER CREATED          │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│       SSL + NGINX            │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│       DOCKER + WINGS         │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│     LOCATION + NODE         │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│   AUTO WINGS CONFIGURATION  │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│       PORT VERIFICATION     │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│    NODE CONNECTIVITY TEST   │
└──────────────┬──────────────┘
               │
               ▼
             🟢
          **GREEN**

---

📌 VERSION

FROGZZ PTERODACTYL INSTALLER V5

Project:

InstallerV5ByFrogzzNew

Developer:

Yogzz / Frogzz

---

🔗 GITHUB

Repository:

https://github.com/YogzzOktz/InstallerV5ByFrogzzNew

---

❤️ CREDITS

Built for automated Pterodactyl deployment.

Powered by:

- Pterodactyl Panel
- Pterodactyl Wings
- Docker
- Ubuntu
- MariaDB
- Redis
- Nginx
- Let's Encrypt

Official Pterodactyl:

https://pterodactyl.io/

---

⚖️ DISCLAIMER

FROGZZ PTERODACTYL INSTALLER V5 is an independent installation script.

This project is not an official Pterodactyl installer.

Pterodactyl Panel and Pterodactyl Wings are projects of the Pterodactyl Project.

Always review the source code before executing an installer on a production server.

---

🐸 FROGZZ PTERODACTYL INSTALLER V5

Fresh VPS → Panel → Owner → Docker → Wings → Node → GREEN 🟢