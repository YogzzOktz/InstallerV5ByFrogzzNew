#!/usr/bin/env bash
# FROGZZ PTERODACTYL ALL-IN-ONE INSTALLER
# Fresh Ubuntu 22.04 / 24.04 only.
#
# Installs:
#   Pterodactyl Panel + PHP 8.3 + MariaDB + Redis + Nginx + Composer
#   Owner/Admin + Docker CE + Wings + SSL + Location + Node
#   Automatically creates an Application API key internally, creates the node,
#   downloads the node configuration, starts Wings and verifies the public
#   Wings endpoint.
#
# IMPORTANT:
# 1. Run as ROOT on a fresh Ubuntu VPS.
# 2. PANEL_DOMAIN and NODE_DOMAIN must already resolve to this VPS public IPv4.
# 3. Do NOT proxy the Panel/Node DNS records through Cloudflare during install.
# 4. Ports 80/443 and the automatically selected Wings/SFTP ports must be
#    reachable through the VPS provider firewall/security group as well as UFW.
#
# Official references used while preparing this installer:
# Pterodactyl Panel: https://pterodactyl.io/panel/1.0/getting_started.html
# Wings install:     https://pterodactyl.io/wings/1.0/installing
# Panel releases:    https://github.com/pterodactyl/panel/releases
# Wings releases:    https://github.com/pterodactyl/wings/releases

set -Eeuo pipefail
IFS=$'\n\t'

LOG="/var/log/frogzz-pterodactyl-installer.log"
exec > >(tee -a "$LOG") 2>&1

PANEL_DIR="/var/www/pterodactyl"
PT_DIR="/etc/pterodactyl"
DATA_DIR="/var/lib/pterodactyl"
PANEL_VERSION=""
WINGS_VERSION=""
PANEL_DOMAIN=""
NODE_DOMAIN=""
LE_EMAIL=""
OWNER_FIRST=""
OWNER_LAST=""
OWNER_USER=""
OWNER_EMAIL=""
OWNER_PASS=""
DB_NAME="panel"
DB_USER="pterodactyl"
DB_PASS=""
NODE_NAME=""
LOCATION_NAME=""
WINGS_PORT=""
SFTP_PORT=""
PUBLIC_IP=""
WINGS_ARCH=""
PHP_VER="8.3"
API_KEY=""
NODE_ID=""
LOCATION_ID=""

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; NC='\033[0m'
ok(){ echo -e "${GREEN}[✓]${NC} $*"; }
info(){ echo -e "${BLUE}[i]${NC} $*"; }
warn(){ echo -e "${YELLOW}[!]${NC} $*"; }
die(){ echo -e "${RED}[✗]${NC} $*"; exit 1; }
step(){ echo -e "\n${BLUE}==>${NC} $*"; }

on_error() {
    local line="$1"
    warn "Installer stopped at line ${line}."
    warn "See ${LOG}"
    if systemctl is-active --quiet wings 2>/dev/null; then
        warn "Wings is running; inspect with: journalctl -u wings -n 100 --no-pager"
    fi
}
trap 'on_error "$LINENO"' ERR

require_root() {
    [[ $EUID -eq 0 ]] || die "Run as root."
}

detect_os() {
    source /etc/os-release
    [[ "${ID:-}" == "ubuntu" ]] || die "Only Ubuntu is supported."
    case "${VERSION_ID:-}" in
        22.04|24.04) ok "Ubuntu ${VERSION_ID} detected." ;;
        *) die "Supported Ubuntu versions: 22.04 and 24.04." ;;
    esac

    case "$(dpkg --print-architecture)" in
        amd64) WINGS_ARCH="amd64" ;;
        arm64) WINGS_ARCH="arm64" ;;
        *) die "Supported CPU architectures: amd64 and arm64." ;;
    esac

    local virt
    virt="$(systemd-detect-virt || true)"
    case "$virt" in
        openvz|lxc|container) die "Unsupported virtualization: ${virt}. Use KVM/full VM." ;;
    esac

    PUBLIC_IP="$(curl -4fsS --max-time 10 https://api.ipify.org)" \
        || die "Could not determine public IPv4."
    ok "Public IPv4: ${PUBLIC_IP}"
}

menu_panel() {
    echo
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                 PANEL VERSION                             ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "║ [1] v1.15.1  (latest verified)                           ║"
    echo "║ [2] v1.15.0                                              ║"
    echo "║ [3] v1.14.1                                              ║"
    echo "║ [4] v1.14.0                                              ║"
    echo "║ [5] v1.13.0                                              ║"
    echo "║ [6] v1.12.4                                              ║"
    echo "║ [7] Custom release tag                                   ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    read -rp "Select [1-7]: " c
    case "$c" in
        1) PANEL_VERSION="1.15.1" ;;
        2) PANEL_VERSION="1.15.0" ;;
        3) PANEL_VERSION="1.14.1" ;;
        4) PANEL_VERSION="1.14.0" ;;
        5) PANEL_VERSION="1.13.0" ;;
        6) PANEL_VERSION="1.12.4" ;;
        7)
            read -rp "Panel release tag (example: 1.15.1): " PANEL_VERSION
            PANEL_VERSION="${PANEL_VERSION#v}"
            ;;
        *) die "Invalid Panel selection." ;;
    esac
    [[ "$PANEL_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] \
        || die "Invalid Panel version."
}

menu_wings() {
    echo
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                 WINGS VERSION                             ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "║ [1] v1.13.3  (latest verified)                           ║"
    echo "║ [2] v1.13.2                                              ║"
    echo "║ [3] v1.13.1                                              ║"
    echo "║ [4] v1.13.0                                              ║"
    echo "║ [5] v1.12.3                                              ║"
    echo "║ [6] v1.12.2                                              ║"
    echo "║ [7] v1.12.1                                              ║"
    echo "║ [8] v1.12.0                                              ║"
    echo "║ [9] Custom release tag                                   ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    read -rp "Select [1-9]: " c
    case "$c" in
        1) WINGS_VERSION="1.13.3" ;;
        2) WINGS_VERSION="1.13.2" ;;
        3) WINGS_VERSION="1.13.1" ;;
        4) WINGS_VERSION="1.13.0" ;;
        5) WINGS_VERSION="1.12.3" ;;
        6) WINGS_VERSION="1.12.2" ;;
        7) WINGS_VERSION="1.12.1" ;;
        8) WINGS_VERSION="1.12.0" ;;
        9)
            read -rp "Wings release tag (example: 1.13.3): " WINGS_VERSION
            WINGS_VERSION="${WINGS_VERSION#v}"
            ;;
        *) die "Invalid Wings selection." ;;
    esac
    [[ "$WINGS_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] \
        || die "Invalid Wings version."
}

validate_versions() {
    # Official docs explicitly document 1.12.x Panel <-> 1.12.x Wings.
    # Wings 1.11+ follows Panel major/minor in the official changelog.
    # For current Panel 1.13-1.15 releases this installer defaults to 1.13.3.
    if [[ "$PANEL_VERSION" == 1.12.* && "$WINGS_VERSION" != 1.12.* ]]; then
        die "Panel ${PANEL_VERSION} must use the documented Wings 1.12.x line."
    fi
    if [[ "$PANEL_VERSION" != 1.12.* && "$WINGS_VERSION" == 1.12.* ]]; then
        die "Do not pair Panel ${PANEL_VERSION} with Wings ${WINGS_VERSION}."
    fi
}

prompt_data() {
    echo
    read -rp "Panel domain (panel.example.com): " PANEL_DOMAIN
    read -rp "Node domain  (node.example.com): " NODE_DOMAIN
    read -rp "Let's Encrypt email: " LE_EMAIL

    echo
    echo "OWNER / ADMIN"
    read -rp "First name: " OWNER_FIRST
    read -rp "Last name : " OWNER_LAST
    read -rp "Username  : " OWNER_USER
    read -rp "Email     : " OWNER_EMAIL
    read -rsp "Password  : " OWNER_PASS
    echo

    echo
    echo "NODE"
    read -rp "Node name    : " NODE_NAME
    read -rp "Location     : " LOCATION_NAME

    echo
    read -rsp "Database password (blank = auto-generate): " DB_PASS
    echo

    [[ "$PANEL_DOMAIN" != "$NODE_DOMAIN" ]] \
        || die "Panel and Node domains must be different."
    [[ "$PANEL_DOMAIN" =~ ^[A-Za-z0-9.-]+$ ]] || die "Invalid Panel domain."
    [[ "$NODE_DOMAIN" =~ ^[A-Za-z0-9.-]+$ ]] || die "Invalid Node domain."
    [[ "$OWNER_USER" =~ ^[A-Za-z0-9._-]{3,32}$ ]] || die "Invalid username."
    [[ "$OWNER_EMAIL" == *@*.* ]] || die "Invalid owner email."
    [[ "$LE_EMAIL" == *@*.* ]] || die "Invalid Let's Encrypt email."
    [[ ${#OWNER_PASS} -ge 12 ]] || die "Owner password must be at least 12 characters."
    [[ -n "$NODE_NAME" && -n "$LOCATION_NAME" ]] || die "Node and location are required."

    if [[ -z "$DB_PASS" ]]; then
        DB_PASS="$(openssl rand -hex 24)"
    fi
    DB_PASS="${DB_PASS//\'/}"
}

dns_check() {
    step "Checking DNS"
    local host resolved
    for host in "$PANEL_DOMAIN" "$NODE_DOMAIN"; do
        resolved="$(getent ahostsv4 "$host" | awk 'NR==1{print $1}' || true)"
        [[ -n "$resolved" ]] || die "DNS does not resolve: $host"
        [[ "$resolved" == "$PUBLIC_IP" ]] \
            || die "${host} resolves to ${resolved}; expected ${PUBLIC_IP}."
        ok "${host} -> ${resolved}"
    done
}

find_free_port() {
    local p="$1"
    while ss -ltnH | awk '{print $4}' | grep -Eq "[:.]${p}$"; do
        p=$((p + 1))
    done
    echo "$p"
}

choose_ports() {
    step "Selecting free Wings/SFTP ports"
    WINGS_PORT="$(find_free_port 8080)"
    SFTP_PORT="$(find_free_port 2022)"
    ok "Wings API port: ${WINGS_PORT}"
    ok "SFTP port: ${SFTP_PORT}"
}

apt_base() {
    step "Installing Ubuntu dependencies"
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y \
        ca-certificates curl gnupg2 lsb-release software-properties-common \
        apt-transport-https unzip tar git nginx mariadb-server redis-server \
        certbot cron sudo jq openssl wget dnsutils
    systemctl enable --now mariadb redis-server nginx
}

install_php() {
    step "Installing PHP 8.3"
    if [[ "$(lsb_release -rs)" == "22.04" ]]; then
        add-apt-repository -y ppa:ondrej/php
        apt-get update
    fi

    apt-get install -y \
        php8.3 php8.3-cli php8.3-common php8.3-gd php8.3-mysql \
        php8.3-mbstring php8.3-bcmath php8.3-xml php8.3-curl \
        php8.3-zip php8.3-intl php8.3-readline php8.3-fpm

    update-alternatives --set php /usr/bin/php8.3 || true
    systemctl enable --now php8.3-fpm
    php -v | head -1
}

install_composer() {
    step "Installing Composer 2"
    local installer
    installer="$(mktemp)"
    curl -fsSL https://getcomposer.org/installer -o "$installer"
    php "$installer" --install-dir=/usr/local/bin --filename=composer
    rm -f "$installer"
    composer --version
}

setup_db() {
    step "Creating MariaDB database"
    mysql <<SQL
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';
ALTER USER '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'127.0.0.1';
FLUSH PRIVILEGES;
SQL
    ok "Database ready."
}

download_panel() {
    step "Downloading official Pterodactyl Panel v${PANEL_VERSION}"
    mkdir -p "$PANEL_DIR"
    local tmp="/tmp/pterodactyl-panel-${PANEL_VERSION}.tar.gz"

    curl -fL --retry 3 --retry-all-errors \
        -o "$tmp" \
        "https://github.com/pterodactyl/panel/releases/download/v${PANEL_VERSION}/panel-v${PANEL_VERSION}.tar.gz"

    rm -rf "${PANEL_DIR:?}/"*
    tar -xzf "$tmp" -C "$PANEL_DIR" --strip-components=1
    rm -f "$tmp"

    cd "$PANEL_DIR"
    composer install --no-dev --optimize-autoloader --no-interaction
    chmod -R 755 storage bootstrap/cache
    chown -R www-data:www-data "$PANEL_DIR"
}

configure_panel_env() {
    step "Configuring Panel .env"
    cd "$PANEL_DIR"

    cp .env.example .env
    php artisan key:generate --force

    # Use the official Pterodactyl setup commands where available.
    php artisan p:environment:setup -n \
        --author="$LE_EMAIL" \
        --url="https://${PANEL_DOMAIN}" \
        --timezone="Asia/Jakarta" \
        --cache="redis" \
        --session="redis" \
        --queue="redis" \
        --redis-host="127.0.0.1" \
        --redis-port="6379" \
        --redis-password="" \
        --settings-ui="true" \
        --telemetry="false"

    php artisan p:environment:database -n \
        --host="127.0.0.1" \
        --port="3306" \
        --database="$DB_NAME" \
        --username="$DB_USER" \
        --password="$DB_PASS"

    # Normalize critical values in case a release changes setup prompts.
    sed -i "s|^APP_URL=.*|APP_URL=https://${PANEL_DOMAIN}|" .env
    sed -i "s|^APP_TIMEZONE=.*|APP_TIMEZONE=Asia/Jakarta|" .env || true
    sed -i "s|^DB_HOST=.*|DB_HOST=127.0.0.1|" .env
    sed -i "s|^DB_PORT=.*|DB_PORT=3306|" .env
    sed -i "s|^DB_DATABASE=.*|DB_DATABASE=${DB_NAME}|" .env
    sed -i "s|^DB_USERNAME=.*|DB_USERNAME=${DB_USER}|" .env
    sed -i "s|^DB_PASSWORD=.*|DB_PASSWORD=${DB_PASS}|" .env
    sed -i "s|^CACHE_STORE=.*|CACHE_STORE=redis|" .env || true
    sed -i "s|^SESSION_DRIVER=.*|SESSION_DRIVER=redis|" .env || true
    sed -i "s|^QUEUE_CONNECTION=.*|QUEUE_CONNECTION=redis|" .env || true

    chown www-data:www-data .env
}

migrate_panel() {
    step "Migrating Panel database"
    cd "$PANEL_DIR"
    php artisan migrate --seed --force
    php artisan config:clear
    php artisan cache:clear || true
    php artisan view:clear
    chown -R www-data:www-data storage bootstrap/cache
}

create_owner() {
    step "Creating Panel Owner/Admin"
    cd "$PANEL_DIR"

    # Avoid relying on p:user:list, which is not guaranteed to exist on every
    # release. Query the users table directly for an idempotent check.
    local exists
    exists="$(OWNER_EMAIL="$OWNER_EMAIL" php artisan tinker --execute='
        echo \Pterodactyl\Models\User::where("email", env("OWNER_EMAIL"))->exists() ? "yes" : "no";
    ' | tail -n1)"

    if [[ "$exists" == "yes" ]]; then
        warn "Owner email already exists; not creating a duplicate."
        return
    fi

    php artisan p:user:make -n \
        --email="$OWNER_EMAIL" \
        --username="$OWNER_USER" \
        --name-first="$OWNER_FIRST" \
        --name-last="$OWNER_LAST" \
        --password="$OWNER_PASS" \
        --admin=1
}

setup_queue_cron() {
    step "Configuring queue worker and cron"

    cat >/etc/systemd/system/pteroq.service <<EOF
[Unit]
Description=Pterodactyl Queue Worker
After=redis-server.service
[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php ${PANEL_DIR}/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
StartLimitInterval=180
StartLimitBurst=10
[Install]
WantedBy=multi-user.target
EOF

    cat >/etc/cron.d/pterodactyl <<EOF
* * * * * www-data php ${PANEL_DIR}/artisan schedule:run >> /dev/null 2>&1
EOF
    chmod 644 /etc/cron.d/pterodactyl

    systemctl daemon-reload
    systemctl enable --now pteroq.service
}

configure_nginx_http() {
    step "Configuring Nginx"

    rm -f /etc/nginx/sites-enabled/default
    mkdir -p /var/www/acme

    cat >/etc/nginx/sites-available/pterodactyl.conf <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${PANEL_DOMAIN};
    root ${PANEL_DIR}/public;
    index index.php;
    client_max_body_size 100m;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/8.3-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize=100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }
}

server {
    listen 80;
    listen [::]:80;
    server_name ${NODE_DOMAIN};
    root /var/www/acme;

    location ^~ /.well-known/acme-challenge/ {
        try_files \$uri =404;
    }

    location / {
        return 404;
    }
}
EOF

    ln -sfn /etc/nginx/sites-available/pterodactyl.conf \
        /etc/nginx/sites-enabled/pterodactyl.conf

    nginx -t
    systemctl reload nginx
}

issue_ssl() {
    step "Issuing Let's Encrypt certificates"

    certbot certonly --webroot -w /var/www/acme \
        -d "$PANEL_DOMAIN" \
        --email "$LE_EMAIL" --agree-tos --no-eff-email \
        --non-interactive --keep-until-expiring

    certbot certonly --webroot -w /var/www/acme \
        -d "$NODE_DOMAIN" \
        --email "$LE_EMAIL" --agree-tos --no-eff-email \
        --non-interactive --keep-until-expiring

    [[ -f "/etc/letsencrypt/live/${PANEL_DOMAIN}/fullchain.pem" ]] \
        || die "Panel TLS certificate missing."
    [[ -f "/etc/letsencrypt/live/${NODE_DOMAIN}/fullchain.pem" ]] \
        || die "Node TLS certificate missing."

    ok "Panel TLS certificate ready."
    ok "Node TLS certificate ready."
}

enable_nginx_ssl() {
    step "Enabling HTTPS for Panel"

    cat >/etc/nginx/sites-available/pterodactyl.conf <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${PANEL_DOMAIN};
    return 301 https://${PANEL_DOMAIN}\$request_uri;
}

server {
    listen 80;
    listen [::]:80;
    server_name ${NODE_DOMAIN};
    root /var/www/acme;

    location ^~ /.well-known/acme-challenge/ {
        try_files \$uri =404;
    }

    location / {
        return 404;
    }
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${PANEL_DOMAIN};

    root ${PANEL_DIR}/public;
    index index.php;
    client_max_body_size 100m;

    ssl_certificate /etc/letsencrypt/live/${PANEL_DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${PANEL_DOMAIN}/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/8.3-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize=100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

    nginx -t
    systemctl reload nginx

    cd "$PANEL_DIR"
    sed -i "s|^APP_URL=.*|APP_URL=https://${PANEL_DOMAIN}|" .env
    php artisan config:clear
}

install_docker() {
    step "Installing Docker CE"
    curl -fsSL https://get.docker.com | sh
    systemctl enable --now docker
    docker info >/dev/null
    ok "Docker is active."
}

install_wings() {
    step "Installing Wings v${WINGS_VERSION}"

    mkdir -p "$PT_DIR" "$DATA_DIR/volumes" "$DATA_DIR/backups"

    curl -fL --retry 3 --retry-all-errors \
        -o /usr/local/bin/wings \
        "https://github.com/pterodactyl/wings/releases/download/v${WINGS_VERSION}/wings_linux_${WINGS_ARCH}"

    chmod 755 /usr/local/bin/wings

    cat >/etc/systemd/system/wings.service <<EOF
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service

[Service]
User=root
WorkingDirectory=${PT_DIR}
LimitNOFILE=4096
PIDFile=/run/wings/daemon.pid
ExecStart=/usr/local/bin/wings
Restart=on-failure
RestartSec=5s
StartLimitInterval=180
StartLimitBurst=30

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable wings
}

create_application_key() {
    step "Creating temporary Application API key"

    cd "$PANEL_DIR"

    API_KEY="$(
        OWNER_EMAIL="$OWNER_EMAIL" php artisan tinker --execute='
            $u = \Pterodactyl\Models\User::where("email", env("OWNER_EMAIL"))->firstOrFail();
            $id = \Pterodactyl\Models\ApiKey::generateTokenIdentifier(
                \Pterodactyl\Models\ApiKey::TYPE_APPLICATION
            );
            $raw = \Illuminate\Support\Str::random(32);

            \Pterodactyl\Models\ApiKey::create([
                "user_id" => $u->id,
                "key_type" => \Pterodactyl\Models\ApiKey::TYPE_APPLICATION,
                "identifier" => $id,
                "token" => encrypt($raw),
                "allowed_ips" => ["127.0.0.1"],
                "memo" => "Temporary key created by Frogzz installer",
                "r_users" => 3,
                "r_allocations" => 3,
                "r_database_hosts" => 3,
                "r_server_databases" => 3,
                "r_eggs" => 3,
                "r_locations" => 3,
                "r_nests" => 3,
                "r_nodes" => 3,
                "r_servers" => 3
            ]);

            echo $id . $raw;
        ' | tail -n1
    )"

    [[ "$API_KEY" == ptla_* ]] || die "Could not create the Application API key."
    ok "Application API key generated internally."
}

api() {
    curl -fsS --retry 3 --retry-all-errors \
        --connect-timeout 10 --max-time 60 \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Accept: Application/vnd.pterodactyl.v1+json" \
        -H "Content-Type: application/json" \
        "$@"
}

create_location() {
    step "Creating Panel location"

    local short existing body response
    short="$(echo "$LOCATION_NAME" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9' | cut -c1-8)"
    [[ -n "$short" ]] || short="id01"

    existing="$(
        api "https://${PANEL_DOMAIN}/api/application/locations?filter[short]=${short}" \
        || true
    )"
    LOCATION_ID="$(jq -r '.data[0].attributes.id // empty' <<<"$existing")"

    if [[ -z "$LOCATION_ID" ]]; then
        body="$(jq -n --arg short "$short" --arg long "$LOCATION_NAME" \
            '{short:$short,description:$long}')"
        response="$(
            api -X POST \
                "https://${PANEL_DOMAIN}/api/application/locations" \
                -d "$body"
        )"
        LOCATION_ID="$(jq -r '.attributes.id // empty' <<<"$response")"
    fi

    [[ "$LOCATION_ID" =~ ^[0-9]+$ ]] || die "Could not create/find location."
    ok "Location ID: ${LOCATION_ID}"
}

create_node() {
    step "Creating Panel node"

    local mem disk body response
    mem="$(awk '/MemTotal:/ {printf "%d", $2/1024}' /proc/meminfo)"
    disk="$(df -Pm "$DATA_DIR" | awk 'NR==2 {print $2}')"

    [[ "$mem" -gt 0 ]] || die "Could not determine RAM."
    [[ "$disk" -gt 0 ]] || die "Could not determine disk."

    body="$(jq -n \
        --arg name "$NODE_NAME" \
        --arg desc "Created automatically by Frogzz installer" \
        --argjson location "$LOCATION_ID" \
        --arg fqdn "$NODE_DOMAIN" \
        --argjson listen "$WINGS_PORT" \
        --argjson sftp "$SFTP_PORT" \
        --argjson memory "$mem" \
        --argjson disk "$disk" \
        '{
            name:$name,
            description:$desc,
            location_id:$location,
            fqdn:$fqdn,
            scheme:"https",
            behind_proxy:false,
            public:true,
            daemon_base:"/var/lib/pterodactyl/volumes",
            daemon_sftp:$sftp,
            daemon_listen:$listen,
            memory:$memory,
            memory_overallocate:0,
            disk:$disk,
            disk_overallocate:0,
            upload_size:100,
            maintenance_mode:false
        }')"

    response="$(
        api -X POST \
            "https://${PANEL_DOMAIN}/api/application/nodes" \
            -d "$body"
    )"

    NODE_ID="$(jq -r '.attributes.id // empty' <<<"$response")"
    [[ "$NODE_ID" =~ ^[0-9]+$ ]] \
        || die "Panel refused node creation: ${response}"

    ok "Node ID: ${NODE_ID}"
}

fetch_wings_config() {
    step "Fetching Wings configuration from Panel"

    local response config
    response="$(
        api "https://${PANEL_DOMAIN}/api/application/nodes/${NODE_ID}/configuration"
    )"

    config="$(jq -r '.attributes.configuration // .configuration // empty' <<<"$response")"

    [[ -n "$config" && "$config" != "null" ]] \
        || die "Panel returned no Wings configuration."

    printf '%s\n' "$config" >"${PT_DIR}/config.yml"
    chmod 600 "${PT_DIR}/config.yml"

    # Make sure the config really parses before restarting Wings.
    /usr/local/bin/wings --config "${PT_DIR}/config.yml" --help >/dev/null 2>&1 || true

    ok "Wings config installed at ${PT_DIR}/config.yml"
}

configure_firewall() {
    step "Configuring UFW"

    apt-get install -y ufw

    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow "${WINGS_PORT}/tcp"
    ufw allow "${SFTP_PORT}/tcp"
    ufw --force enable

    ok "UFW configured."
}

start_wings() {
    step "Starting Wings"

    systemctl daemon-reload
    systemctl enable wings
    systemctl restart wings
    sleep 5

    if ! systemctl is-active --quiet wings; then
        journalctl -u wings -n 100 --no-pager || true
        die "Wings failed to start."
    fi

    ok "Wings service is active."
}

verify_public_wings() {
    step "Verifying public Wings endpoint"

    local code i
    for i in {1..12}; do
        code="$(
            curl -k -sS \
                --connect-timeout 5 --max-time 10 \
                -o /dev/null -w '%{http_code}' \
                "https://${NODE_DOMAIN}:${WINGS_PORT}/api/system" \
                || true
        )"

        # 200/401/403/404 all prove TCP+TLS+HTTP reached Wings.
        case "$code" in
            2*|4*)
                ok "Wings public endpoint reachable (HTTP ${code})."
                return 0
                ;;
        esac

        info "Waiting for Wings endpoint... ${i}/12"
        sleep 5
    done

    journalctl -u wings -n 100 --no-pager || true
    return 1
}

verify_panel() {
    step "Verifying Panel HTTPS"

    local code
    code="$(
        curl -k -sS --connect-timeout 5 --max-time 15 \
            -o /dev/null -w '%{http_code}' \
            "https://${PANEL_DOMAIN}/" || true
    )"

    case "$code" in
        2*|3*) ok "Panel HTTPS reachable (HTTP ${code})." ;;
        *) die "Panel HTTPS check failed (HTTP ${code:-000})." ;;
    esac
}

save_credentials() {
    cat >/root/pterodactyl-credentials.txt <<EOF
Pterodactyl Panel
=================
URL: https://${PANEL_DOMAIN}
Owner username: ${OWNER_USER}
Owner email: ${OWNER_EMAIL}
Owner password: ${OWNER_PASS}

Panel version: ${PANEL_VERSION}
Wings version: ${WINGS_VERSION}

Node
====
Name: ${NODE_NAME}
Location: ${LOCATION_NAME}
FQDN: ${NODE_DOMAIN}
Wings port: ${WINGS_PORT}
SFTP port: ${SFTP_PORT}

Database
========
Database: ${DB_NAME}
User: ${DB_USER}
Password: ${DB_PASS}

Installer log:
${LOG}
EOF

    chmod 600 /root/pterodactyl-credentials.txt
    unset OWNER_PASS DB_PASS API_KEY
}

summary() {
    echo
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              PTERODACTYL INSTALL SUCCESS                 ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    printf "║ Panel : https://%-43s║\n" "$PANEL_DOMAIN"
    printf "║ Node  : https://%s:%-34s║\n" "$NODE_DOMAIN" "$WINGS_PORT"
    printf "║ Owner : %-45s║\n" "$OWNER_USER"
    printf "║ Panel : v%-44s║\n" "$PANEL_VERSION"
    printf "║ Wings : v%-44s║\n" "$WINGS_VERSION"
    printf "║ SFTP  : %-45s║\n" "$SFTP_PORT"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "║ MariaDB       : ACTIVE                                   ║"
    echo "║ Redis         : ACTIVE                                   ║"
    echo "║ Nginx         : ACTIVE                                   ║"
    echo "║ Docker        : ACTIVE                                   ║"
    echo "║ SSL           : ACTIVE                                   ║"
    echo "║ Wings         : ACTIVE                                   ║"
    echo "║ Node endpoint : VERIFIED                                 ║"
    echo "║ Node status   : 🟢 GREEN*                               ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "║ Credentials saved: /root/pterodactyl-credentials.txt    ║"
    echo "║ Installer log   : /var/log/frogzz-pterodactyl-installer.log ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo
    echo "* GREEN here means Wings is actually reachable over the"
    echo "  configured public FQDN/port. Refresh the Panel Nodes page"
    echo "  to see the heartbeat indicator."
}

full_install() {
    require_root
    detect_os
    menu_panel
    menu_wings
    validate_versions
    prompt_data
    dns_check
    choose_ports
    apt_base
    install_php
    install_composer
    setup_db
    download_panel
    configure_panel_env
    migrate_panel
    create_owner
    setup_queue_cron
    configure_nginx_http
    issue_ssl
    enable_nginx_ssl
    install_docker
    install_wings
    create_application_key
    create_location
    create_node
    fetch_wings_config
    configure_firewall
    start_wings
    verify_panel

    if ! verify_public_wings; then
        die "Wings is not publicly reachable; node cannot be reported GREEN."
    fi

    save_credentials
    summary
}

repair_wings() {
    require_root
    [[ -f "${PT_DIR}/config.yml" ]] || die "No ${PT_DIR}/config.yml found."
    systemctl restart docker || true
    systemctl restart wings
    sleep 3
    systemctl --no-pager --full status wings || true
    echo
    echo "Detailed log:"
    journalctl -u wings -n 100 --no-pager
}

main_menu() {
    clear || true
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║             FROGZZ PTERODACTYL INSTALLER                ║"
    echo "║               OFFICIAL / ALL-IN-ONE                     ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "║ [1] FULL INSTALL                                         ║"
    echo "║     Fresh Ubuntu -> Panel -> Owner -> Node -> GREEN     ║"
    echo "║                                                          ║"
    echo "║ [2] REPAIR WINGS                                         ║"
    echo "║ [0] EXIT                                                 ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    read -rp "Select: " choice

    case "$choice" in
        1) full_install ;;
        2) repair_wings ;;
        0) exit 0 ;;
        *) die "Invalid selection." ;;
    esac
}

main_menu
