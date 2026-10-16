#!/bin/bash
# instaluj-docker-apt.sh — Docker Engine z OFICJALNEGO repozytorium Dockera na Debianie i Ubuntu
# (rodzina apt). To dokładnie te kroki, które w lekcji 4 wykonujemy ręcznie — tylko zebrane w jednym
# miejscu. Najpierw raz zrób je z palca, potem używaj skryptu.
#
# Kurs "Docker i kontenery dla administratorów sieciowych i DevOps" — AdminAkademia, lekcja 4.
# Źródło procedury: docs.docker.com, "Install Docker Engine on Debian" / "on Ubuntu".
#
# Użycie (jako administrator):
#     sudo bash instaluj-docker-apt.sh
#
# Czego skrypt NIE robi — świadomie:
#   - nie dodaje nikogo do grupy "docker" (to uprawnienia równoważne rootowi; decyzję podejmujesz sam,
#     poleceniem: sudo usermod -aG docker $USER, a potem ponowne logowanie),
#   - nie usuwa pakietów nieoficjalnych (docker.io, podman-docker, ...) — jeśli je ma, zatrzymuje się
#     i mówi, co usunąć; dokumentacja Dockera wymaga ich usunięcia PRZED instalacją wersji oficjalnej.

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Ten skrypt trzeba uruchomić z uprawnieniami administratora: sudo bash $0" >&2
    exit 1
fi

# Rozpoznanie dystrybucji — z niej wynika adres repozytorium i nazwa wydania.
. /etc/os-release
case "${ID:-}" in
    debian|ubuntu) ;;
    *)
        echo "Ten skrypt obsługuje wyłącznie Debiana i Ubuntu (wykryto: ${ID:-nieznana})." >&2
        echo "Na Rocky Linux i resztę rodziny RHEL użyj skryptu instaluj-docker-dnf.sh." >&2
        exit 1
        ;;
esac
if [ -z "${VERSION_CODENAME:-}" ]; then
    echo "Nie udało się odczytać nazwy wydania (VERSION_CODENAME) z /etc/os-release." >&2
    exit 1
fi

# Zabezpieczenie: nie mieszamy dwóch Dockerów na jednej maszynie.
if command -v docker >/dev/null 2>&1; then
    echo "Polecenie \"docker\" już istnieje na tej maszynie: $(docker --version 2>/dev/null || true)" >&2
    echo "Skrypt kończy pracę, żeby nie mieszać dwóch instalacji. Sprawdź: apt policy docker-ce docker.io" >&2
    exit 1
fi
# Liczy się tylko pakiet faktycznie zainstalowany: "dpkg -s" zgłasza też pakiet usunięty bez
# czyszczenia (stan "rc" — zostały po nim same pliki konfiguracyjne), a taki już niczemu nie przeszkadza.
for p in docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc; do
    if [ "$(dpkg-query -W -f='${db:Status-Status}' "$p" 2>/dev/null)" = "installed" ]; then
        echo "Zainstalowany jest pakiet nieoficjalny lub kolidujący: $p" >&2
        echo "Usuń go najpierw (sudo apt remove $p), tak jak zaleca dokumentacja Dockera." >&2
        exit 1
    fi
done

echo "[1/5] Aktualizacja listy pakietów i narzędzia do pobrania klucza (ca-certificates, curl)"
apt-get update
apt-get install -y ca-certificates curl

echo "[2/5] Klucz GPG repozytorium Dockera -> /etc/apt/keyrings/docker.asc"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL "https://download.docker.com/linux/${ID}/gpg" -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
if ! head -c 40 /etc/apt/keyrings/docker.asc | grep -q "BEGIN PGP PUBLIC KEY BLOCK"; then
    echo "Pobrany plik nie wygląda na klucz PGP (proxy? portal logowania?). Zobacz: head /etc/apt/keyrings/docker.asc" >&2
    exit 1
fi

echo "[3/5] Wpis repozytorium -> /etc/apt/sources.list.d/docker.sources (wydanie: ${VERSION_CODENAME}, architektura: $(dpkg --print-architecture))"
tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/${ID}
Suites: ${VERSION_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
chmod 644 /etc/apt/sources.list.d/docker.sources
apt-get update

echo "[4/5] Pakiety Docker Engine: docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "[5/5] Usługa docker (na Debianie i Ubuntu startuje sama po instalacji — to tylko upewnienie)"
systemctl enable --now docker >/dev/null 2>&1 || true
systemctl is-active --quiet docker || { echo "Usługa docker nie działa — sprawdź: systemctl status docker" >&2; exit 1; }

echo
docker version
echo
echo "GOTOWE: Docker Engine z oficjalnego repozytorium jest zainstalowany i działa."
echo "Do czasu dodania konta do grupy docker polecenia wpisujesz z sudo, np.: sudo docker run hello-world"
echo "Grupa docker (świadoma decyzja, uprawnienia równoważne rootowi): sudo usermod -aG docker \$USER"
