🚀 CARA INSTALL DARI AWAL — VPS FRESH

Panduan lengkap menjalankan FROGZZ Pterodactyl Installer V5 mulai dari VPS Ubuntu fresh sampai Panel dan Wings siap digunakan.

1. SIAPKAN VPS

Gunakan VPS dengan:

- Ubuntu 22.04 LTS atau Ubuntu 24.04 LTS
- Akses root
- Public IPv4
- Virtualisasi KVM atau virtualisasi yang mendukung Docker
- Domain untuk Panel
- Domain untuk Node
- DNS yang bisa diarahkan ke IP VPS

Contoh domain:

Panel : panel.example.com
Node  : node.example.com

2. ARAHKAN DOMAIN KE VPS

Buka pengaturan DNS domain kamu dan buat record berikut:

Type    Name    Value
A       panel   IP-VPS
A       node    IP-VPS

Contoh:

panel.example.com → 123.123.123.123
node.example.com  → 123.123.123.123

Pastikan kedua domain sudah mengarah ke IP VPS sebelum menjalankan installer.

Jika menggunakan Cloudflare, gunakan DNS Only terlebih dahulu selama proses instalasi.

3. LOGIN KE VPS

Buka aplikasi SSH seperti Termius, JuiceSSH, PuTTY, atau terminal komputer.

Masuk menggunakan:

ssh root@IP-VPS

Contoh:

ssh root@123.123.123.123

Masukkan password root VPS kamu.

Jika berhasil, kamu akan masuk ke terminal Ubuntu.

4. UPDATE SISTEM

Jalankan:

apt update && apt upgrade -y

Pastikan proses update selesai tanpa error.

5. INSTALL GIT

Jika Git belum tersedia, jalankan:

apt install git -y

6. DOWNLOAD INSTALLER DARI GITHUB

Clone repository resmi proyek:

git clone https://github.com/YogzzOktz/InstallerV5ByFrogzzNew.git

Masuk ke folder repository:

cd InstallerV5ByFrogzzNew

Lihat isi folder:

ls -lah

Pastikan file installer tersedia:

install-pterodactyl-frogzz.sh

7. JALANKAN INSTALLER

Berikan izin eksekusi:

chmod +x install-pterodactyl-frogzz.sh

Jalankan installer:

./install-pterodactyl-frogzz.sh

Atau:

bash install-pterodactyl-frogzz.sh

8. PILIH MENU FULL INSTALL

Setelah installer terbuka, pilih:

[1] FULL INSTALL

Installer akan menjalankan proses instalasi Panel, database, Docker, Wings, SSL, dan pembuatan Node.

9. PILIH VERSI PANEL

Pilih versi Panel yang tersedia pada menu installer.

Contoh:

[1] v1.15.1

Kemudian tekan Enter.

10. PILIH VERSI WINGS

Pilih versi Wings yang tersedia pada menu installer.

Contoh:

[1] v1.13.3

Kemudian tekan Enter.

Gunakan kombinasi versi yang kompatibel dengan dokumentasi Pterodactyl.

11. ISI INFORMASI DOMAIN

Contoh pengisian:

Panel domain : panel.example.com
Node domain  : node.example.com

Kemudian masukkan email untuk Let's Encrypt:

Let's Encrypt email : admin@example.com

Email ini digunakan untuk sertifikat SSL.

12. ISI OWNER PANEL

Masukkan data akun administrator Panel:

First name : Frogzz
Last name  : Official
Username   : frogzz
Email      : admin@example.com
Password   : PASSWORD-ADMIN-KAMU

Gunakan password yang kuat dan jangan membagikannya.

13. ISI INFORMASI NODE

Contoh:

Node name : Node-01
Location  : Indonesia

Database password bisa dibuat otomatis jika dikosongkan, sesuai mekanisme installer.

Port Wings dan SFTP dipilih otomatis oleh installer.

14. TUNGGU PROSES INSTALASI

Installer akan memasang dan mengonfigurasi komponen yang diperlukan:

Ubuntu dependencies
PHP
MariaDB
Redis
Nginx
Composer
Pterodactyl Panel
Owner/Admin
SSL
Docker
Wings
Location
Node
Wings configuration
UFW
Systemd

Jangan mematikan VPS atau menutup proses installer saat proses berjalan.

15. CEK HASIL INSTALASI

Jika instalasi berhasil, buka alamat Panel:

https://panel.example.com

Login menggunakan akun Owner yang telah dibuat.

Kemudian buka menu:

Admin Panel → Nodes

Pilih Node yang baru dibuat dan periksa status koneksinya.

16. CEK WINGS MELALUI SSH

Periksa status service:

systemctl status wings

Periksa Docker:

systemctl status docker

Periksa Nginx:

systemctl status nginx

Lihat log Wings:

journalctl -u wings -n 100 --no-pager

17. FILE PENTING

Installer menyimpan informasi berikut:

Panel:
 /var/www/pterodactyl

Wings:
 /etc/pterodactyl

Wings config:
 /etc/pterodactyl/config.yml

Wings binary:
 /usr/local/bin/wings

Installer log:
 /var/log/frogzz-pterodactyl-installer.log

Credentials:
 /root/pterodactyl-credentials.txt

18. JIKA NODE OFFLINE

Jalankan:

systemctl restart wings

Kemudian periksa:

journalctl -u wings -n 100 --no-pager

Periksa juga:

- Domain Node mengarah ke IP VPS yang benar.
- Port Wings dapat diakses dari internet.
- Firewall VPS mengizinkan port Wings dan SFTP.
- Docker sedang aktif.
- Konfigurasi Wings sesuai dengan Node pada Panel.

Jika masih bermasalah, baca log installer:

cat /var/log/frogzz-pterodactyl-installer.log

⚠️ PERINGATAN

Installer ditujukan untuk VPS Ubuntu fresh.

Jangan menjalankannya pada server produksi yang sudah memiliki Pterodactyl, Nginx, MariaDB, Docker, atau Wings tanpa memahami perubahan yang akan dilakukan.

Selalu backup data penting sebelum melakukan instalasi atau konfigurasi ulang.

---

🔗 REPOSITORY

GitHub:

https://github.com/YogzzOktz/InstallerV5ByFrogzzNew

FROGZZ PTERODACTYL INSTALLER V5

Developed by Yogzz / Frogzz.
