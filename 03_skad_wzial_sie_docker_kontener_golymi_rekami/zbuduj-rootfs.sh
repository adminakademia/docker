#!/bin/bash
# ============================================================================
#  zbuduj-rootfs.sh - sklada minimalny "obraz" dla serwera nginx
#  Kurs: Docker i kontenery dla administratorow sieciowych i DevOps
#  Lekcja 3: Kontener golymi rekami
#
#  Skrypt NIE tworzy kontenera. Nie robi namespace'ow i nie ustawia limitow.
#  Kopiuje wylacznie PLIKI, ktorych potrzebuje nginx, do jednego katalogu.
#  Uzycie:  sudo bash zbuduj-rootfs.sh [katalog-docelowy]
# ============================================================================
set -euo pipefail
umask 022

ROOTFS="${1:-/srv/nginx-lab/rootfs}"
NGINX_BIN="/usr/sbin/nginx"

[ "$(id -u)" -eq 0 ] || { echo "BLAD: uruchom przez sudo"; exit 1; }
[ -x "$NGINX_BIN" ]  || { echo "BLAD: brak $NGINX_BIN - zainstaluj pakiet nginx"; exit 1; }

echo "[1/8] szkielet katalogow w $ROOTFS"
install -d -m 0755 "$ROOTFS"/{bin,usr/sbin,etc/nginx,var/log/nginx,var/lib/nginx,var/www/html,run,proc,sys,dev,tmp}

echo "[2/8] program, ktory ma dzialac w kontenerze"
install -m 0755 "$NGINX_BIN" "$ROOTFS/usr/sbin/nginx"

echo "[3/8] biblioteki, ktorych zada ten program (lista z ldd)"
ldd "$NGINX_BIN" | grep -oE '/[^ ]+\.so[^ ]*' | while read -r lib; do
    install -D -m 0755 "$lib" "$ROOTFS$lib"
    echo "      + $lib"
done

echo "[4/8] biblioteka NSS - bez niej nginx nie rozwiaze nazwy uzytkownika www-data"
NSS="/lib/x86_64-linux-gnu/libnss_files.so.2"
if [ -e "$NSS" ]; then install -D -m 0755 "$NSS" "$ROOTFS$NSS"; echo "      + $NSS"; fi

echo "[5/8] wlasny /etc/passwd i /etc/group OBRAZU (to nie sa konta hosta)"
grep -E '^(root|www-data):' /etc/passwd > "$ROOTFS/etc/passwd"
grep -E '^(root|www-data):' /etc/group  > "$ROOTFS/etc/group"
printf 'passwd: files\ngroup:  files\nhosts:  files dns\n' > "$ROOTFS/etc/nsswitch.conf"

echo "[6/8] konfiguracja nginx i strona"
install -m 0644 /etc/nginx/mime.types "$ROOTFS/etc/nginx/mime.types"
cat > "$ROOTFS/etc/nginx/nginx.conf" <<'NGINXCONF'
daemon off;
user  www-data;
worker_processes  1;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log warn;

events {
    worker_connections  128;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    access_log    /var/log/nginx/access.log;

    server {
        listen       80;
        server_name  _;
        root  /var/www/html;
        index index.html;
    }
}
NGINXCONF

cat > "$ROOTFS/var/www/html/index.html" <<'HTMLDOC'
<!doctype html>
<html lang="pl">
<head><meta charset="utf-8"><title>Kontener golymi rekami</title></head>
<body>
<h1>nginx dziala bez Dockera</h1>
<p>Ten serwer siedzi we wlasnym systemie plikow, we wlasnych przestrzeniach nazw
   i we wlasnej grupie kontrolnej cgroup.</p>
</body>
</html>
HTMLDOC

echo "[7/8] wezly urzadzen (to NIE sa kopie - to wskazniki do urzadzen jadra)"
[ -e "$ROOTFS/dev/null" ]    || mknod -m 0666 "$ROOTFS/dev/null"    c 1 3
[ -e "$ROOTFS/dev/zero" ]    || mknod -m 0666 "$ROOTFS/dev/zero"    c 1 5
[ -e "$ROOTFS/dev/random" ]  || mknod -m 0666 "$ROOTFS/dev/random"  c 1 8
[ -e "$ROOTFS/dev/urandom" ] || mknod -m 0666 "$ROOTFS/dev/urandom" c 1 9

echo "[8/8] powloka i podstawowe narzedzia (jeden plik: busybox)"
install -m 0755 /usr/bin/busybox "$ROOTFS/bin/busybox"
for a in sh ls cat ps hostname id ip mount sleep top wget grep; do
    ln -sf busybox "$ROOTFS/bin/$a"
done

chmod 0644 "$ROOTFS/etc/nginx/nginx.conf" "$ROOTFS/etc/nginx/mime.types" \
           "$ROOTFS/var/www/html/index.html" "$ROOTFS/etc/passwd" \
           "$ROOTFS/etc/group" "$ROOTFS/etc/nsswitch.conf"
chmod 1777 "$ROOTFS/tmp"
chown -R root:root "$ROOTFS"

echo
echo "GOTOWE. Caly obraz: $(du -sh "$ROOTFS" | cut -f1), plikow: $(find "$ROOTFS" -type f | wc -l)"
