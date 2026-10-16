#!/bin/bash
# sprawdz-docker.sh — test odbioru instalacji Dockera na JEDNEJ maszynie (lekcja 4).
# Uruchamiasz go jako zwykły użytkownik (kursant) osobno na docker01, docker02 i docker03:
#     bash sprawdz-docker.sh
# Skrypt niczego nie zmienia w systemie. Jedyny skutek uboczny: jeśli obrazu hello-world jeszcze
# nie ma, zostanie pobrany (kilka kilobajtów).
#
# Kurs "Docker i kontenery dla administratorów sieciowych i DevOps" — AdminAkademia, lekcja 4.

ok=0; bledy=0
OK()   { echo "[ OK ] $*"; ok=$((ok+1)); }
BLAD() { echo "[BŁĄD] $*"; bledy=$((bledy+1)); }
INFO() { echo "[info] $*"; }

echo "== sprawdzam maszynę: $(hostname) ($(. /etc/os-release && echo "$PRETTY_NAME"))"

# 1. Polecenie docker
if command -v docker >/dev/null 2>&1; then
    OK "polecenie docker: $(docker --version)"
else
    BLAD "brak polecenia docker — Docker nie jest zainstalowany (lekcja 4, sekcja instalacji)"
    echo "WYNIK: $bledy problem(y). Docker NIE jest gotowy na tej maszynie."
    exit 1
fi

# 2. Usługa: działa i jest włączona na starcie
if systemctl is-active --quiet docker; then
    OK "usługa docker: active"
else
    BLAD "usługa docker nie działa — na Rocky/RHEL: sudo systemctl enable --now docker; wszędzie: systemctl status docker"
fi
if systemctl is-enabled --quiet docker 2>/dev/null; then
    OK "usługa docker: enabled (wstanie po restarcie maszyny)"
else
    BLAD "usługa docker nie jest włączona na starcie — sudo systemctl enable docker"
fi

# 3. Grupa docker: wpis w /etc/group (trwały) oraz bieżąca sesja (po ponownym zalogowaniu)
if getent group docker | grep -qw "$USER"; then
    OK "konto $USER jest wpisane do grupy docker"
    if id -nG | grep -qw docker; then
        OK "bieżąca sesja widzi grupę docker (docker bez sudo)"
    else
        BLAD "ta sesja jeszcze nie widzi grupy docker — wyloguj się i zaloguj ponownie (albo: newgrp docker)"
    fi
else
    BLAD "konto $USER nie należy do grupy docker — świadoma decyzja z lekcji 4: sudo usermod -aG docker \$USER"
fi

# 4. Klient dogaduje się z demonem (sekcja Server w docker version)
if docker version >/dev/null 2>&1; then
    OK "docker version: klient i demon odpowiadają (Server: $(docker version -f '{{.Server.Version}}'))"
else
    BLAD "docker version nie dociera do demona: $(docker version 2>&1 | tail -1)"
fi

# 5. Test odbioru: hello-world
if docker run --rm hello-world 2>/dev/null | grep -q "Hello from Docker!"; then
    OK "docker run --rm hello-world: kontener wypisał \"Hello from Docker!\""
else
    BLAD "docker run --rm hello-world nie zadziałał (brak internetu? demon? uprawnienia?)"
fi

# 6. Informacyjnie: magazyn obrazów i wersje składników
if docker info >/dev/null 2>&1; then
    INFO "magazyn obrazów: $(docker info -f '{{ .DriverStatus }}' 2>/dev/null)   (containerd image store = io.containerd.snapshotter.v1)"
    INFO "cgroup: v$(docker info -f '{{ .CgroupVersion }}' 2>/dev/null), sterownik $(docker info -f '{{ .CgroupDriver }}' 2>/dev/null); containerd $(docker version -f '{{ (index .Server.Components 1).Version }}' 2>/dev/null); runc $(docker version -f '{{ (index .Server.Components 2).Version }}' 2>/dev/null)"
fi

echo
if [ "$bledy" -eq 0 ]; then
    echo "WYNIK: docker gotowy na tej maszynie ($ok sprawdzeń OK)."
    exit 0
else
    echo "WYNIK: $bledy problem(y), $ok sprawdzeń OK. Docker NIE jest jeszcze gotowy na tej maszynie."
    exit 1
fi
