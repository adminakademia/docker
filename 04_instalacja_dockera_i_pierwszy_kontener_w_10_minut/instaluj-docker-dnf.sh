#!/bin/bash
# instaluj-docker-dnf.sh — Docker Engine z OFICJALNEGO repozytorium Dockera na Rocky Linux
# i reszcie rodziny RHEL (dnf). To dokładnie te kroki, które w lekcji 4 wykonujemy ręcznie na
# docker02 — tylko zebrane w jednym miejscu. Najpierw raz zrób je z palca, potem używaj skryptu.
#
# Kurs "Docker i kontenery dla administratorów sieciowych i DevOps" — AdminAkademia, lekcja 4.
# Źródło procedury: docs.docker.com, "Install Docker Engine on RHEL" (oraz "on CentOS").
#
# Użycie (jako administrator):
#     sudo bash instaluj-docker-dnf.sh
#
# Czego skrypt NIE robi — świadomie:
#   - nie dodaje nikogo do grupy "docker" (to uprawnienia równoważne rootowi; decyzję podejmujesz sam:
#     sudo usermod -aG docker $USER, a potem ponowne logowanie),
#   - nie usuwa pakietów kolidujących (podman, runc, stare "docker-*") — jeśli je ma, zatrzymuje się
#     i mówi, co usunąć.
#
# Różnica wobec rodziny apt, o której mówi lekcja: po instalacji usługa NIE startuje sama —
# dlatego ostatni krok to jawne "systemctl enable --now docker".

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Ten skrypt trzeba uruchomić z uprawnieniami administratora: sudo bash $0" >&2
    exit 1
fi

. /etc/os-release
case "${ID:-}" in
    rhel|rocky|almalinux|ol)  REPO_URL="https://download.docker.com/linux/rhel/docker-ce.repo" ;;
    centos)                   REPO_URL="https://download.docker.com/linux/centos/docker-ce.repo" ;;
    *)
        echo "Ten skrypt obsługuje rodzinę RHEL: Rocky, RHEL, AlmaLinux, CentOS Stream (wykryto: ${ID:-nieznana})." >&2
        echo "Na Debianie i Ubuntu użyj skryptu instaluj-docker-apt.sh." >&2
        exit 1
        ;;
esac

if command -v docker >/dev/null 2>&1; then
    echo "Polecenie \"docker\" już istnieje na tej maszynie: $(docker --version 2>/dev/null || true)" >&2
    echo "Skrypt kończy pracę, żeby nie mieszać dwóch instalacji. Sprawdź: rpm -qa | grep -i docker" >&2
    exit 1
fi
for p in docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate \
         docker-logrotate docker-engine podman runc; do
    if rpm -q "$p" >/dev/null 2>&1; then
        echo "Zainstalowany jest pakiet kolidujący: $p" >&2
        echo "Usuń go najpierw (sudo dnf remove $p), tak jak zaleca dokumentacja Dockera." >&2
        exit 1
    fi
done

echo "[1/4] Narzędzia do zarządzania repozytoriami (dnf-plugins-core)"
dnf -y install dnf-plugins-core

echo "[2/4] Repozytorium Dockera -> /etc/yum.repos.d/docker-ce.repo"
if dnf config-manager --help 2>&1 | grep -q -- '--add-repo'; then
    dnf config-manager --add-repo "$REPO_URL"            # dnf 4 (Rocky/RHEL 8-10)
else
    dnf config-manager addrepo --from-repofile="$REPO_URL"   # dnf 5 (nowsze wydania)
fi

echo "[3/4] Pakiety Docker Engine: docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
echo "      (dnf zaimportuje klucz GPG Dockera; odcisk wg dokumentacji: 060A 61C5 1B55 8A7F 742B 77AA C52F EB6B 621E 9F35)"
dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "[4/4] Usługa docker — w rodzinie RHEL trzeba ją włączyć jawnie"
systemctl enable --now docker
systemctl is-active --quiet docker || { echo "Usługa docker nie działa — sprawdź: systemctl status docker" >&2; exit 1; }

echo
docker version
echo
echo "GOTOWE: Docker Engine z oficjalnego repozytorium jest zainstalowany, usługa włączona i uruchomiona."
echo "Do czasu dodania konta do grupy docker polecenia wpisujesz z sudo, np.: sudo docker run hello-world"
echo "Grupa docker (świadoma decyzja, uprawnienia równoważne rootowi): sudo usermod -aG docker \$USER"
