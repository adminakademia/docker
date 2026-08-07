#!/usr/bin/env bash
#
# ============================================================================
#  sprawdz-srodowisko.sh - test odbioru laboratorium
#  Kurs: "Docker i kontenery dla administratorow sieciowych i DevOps"
#  AdminAkademia - lekcja 1
#  Wersja: 1.0 (2026-08-07)
# ============================================================================
#
#  CO ROBI TEN SKRYPT:
#  Sprawdza, czy maszyna nadaje sie do pracy w tym kursie - pamiec, miejsce
#  na dysku, dostep do internetu, uprawnienia administracyjne i obecnosc
#  narzedzi. Nic nie instaluje i niczego nie zmienia.
#
#  CZEGO TEN SKRYPT NIE ROBI (mozesz to sprawdzic, czytajac ponizszy kod):
#  - nie zapisuje ani nie usuwa zadnego pliku,
#  - nie modyfikuje konfiguracji systemu,
#  - nie wymaga Dockera - Docker instalujemy dopiero w lekcji 4,
#  - nie wysyla nigdzie zadnych danych o Twoim komputerze; jedyne polaczenie
#    wychodzace to zwykle zapytanie HTTPS do repozytorium Dockera, ktore
#    sprawdza, czy w ogole masz internet (bedzie potrzebny w lekcji 4).
#
#  URUCHOMIENIE:
#      bash sprawdz-srodowisko.sh
#
#  KOD WYJSCIA: 0 = srodowisko gotowe, 1 = wykryto blad do naprawienia.
#
# ============================================================================

set -u

# --- ustawienia progow -------------------------------------------------------
# Wartosci wynikaja z zalecen z lekcji 1: docker01 potrzebuje 8 GB RAM
# (minimum 4 GB), wezly docker02 i docker03 - po 2 GB.
RAM_ZALECANY_MB=7500      # ponizej tego progu: dziala, ale bez zapasu
RAM_MINIMALNY_MB=3800     # ponizej tego progu: tylko rola wezla
RAM_KRYTYCZNY_MB=1900     # ponizej tego progu: za malo na cokolwiek

DYSK_ZALECANY_GB=20       # wolne miejsce na "/"
DYSK_KRYTYCZNY_GB=10

# Host uzywany do testu internetu. Celowo repozytorium Dockera - to dokladnie
# ten adres, z ktorego w lekcji 4 bedziemy instalowac Docker Engine.
URL_TESTOWY="https://download.docker.com/linux/"

# --- liczniki i funkcje pomocnicze ------------------------------------------
BLEDY=0
OSTRZEZENIA=0

ok()      { printf '[ OK ] %s\n' "$1"; }
uwaga()   { printf '[UWAGA] %s\n' "$1"; OSTRZEZENIA=$((OSTRZEZENIA + 1)); }
blad()    { printf '[BLAD] %s\n' "$1"; BLEDY=$((BLEDY + 1)); }
info()    { printf '[  i ] %s\n' "$1"; }
rada()    { printf '        -> %s\n' "$1"; }

printf '\n== Test odbioru srodowiska laboratoryjnego =====================\n\n'

# --- 1. System i nazwa maszyny ----------------------------------------------
SYSTEM="system nierozpoznany"
if [ -r /etc/os-release ]; then
    SYSTEM=$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d= -f2- | tr -d '"')
fi
NAZWA=$(hostname -f 2>/dev/null || hostname)
ok "System: ${SYSTEM} (${NAZWA})"

case "$NAZWA" in
    docker01*|docker02*|docker03*) : ;;
    *) uwaga "Nazwa hosta to \"${NAZWA}\" - kurs zaklada docker01, docker02 albo docker03."
       rada "Zmien ja: sudo hostnamectl set-hostname docker0X (Krok 8 lekcji 1)" ;;
esac

# --- 2. Pamiec RAM -----------------------------------------------------------
RAM_MB=0
if [ -r /proc/meminfo ]; then
    RAM_KB=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
    RAM_MB=$((RAM_KB / 1024))
fi

if   [ "$RAM_MB" -ge "$RAM_ZALECANY_MB" ]; then
    ok "Pamiec RAM: ${RAM_MB} MB (zalecane 8 GB - jest zapas)"
elif [ "$RAM_MB" -ge "$RAM_MINIMALNY_MB" ]; then
    ok "Pamiec RAM: ${RAM_MB} MB (wariant minimalny - wystarczy mniej wiecej do modulu 7)"
    rada "Na modul monitoringu (lekcje 42-44) warto podniesc do 8 GB"
elif [ "$RAM_MB" -ge "$RAM_KRYTYCZNY_MB" ]; then
    uwaga "Pamiec RAM: ${RAM_MB} MB - tyle wystarczy WEZLOWI (docker02, docker03), ale nie docker01"
    rada "Jesli to docker01: wylacz maszyne i podnies pamiec w ustawieniach hypervisora"
else
    blad "Pamiec RAM: ${RAM_MB} MB - za malo na prace w tym kursie"
    rada "Podnies pamiec maszyny w ustawieniach hypervisora"
fi

# --- 3. Wolne miejsce na dysku ----------------------------------------------
DYSK_GB=$(df -Pm / 2>/dev/null | awk 'NR==2 {print int($4/1024)}')
[ -z "${DYSK_GB:-}" ] && DYSK_GB=0

if   [ "$DYSK_GB" -ge "$DYSK_ZALECANY_GB" ]; then
    ok "Wolne miejsce na dysku: ${DYSK_GB} GB"
elif [ "$DYSK_GB" -ge "$DYSK_KRYTYCZNY_GB" ]; then
    uwaga "Wolne miejsce na dysku: ${DYSK_GB} GB - obrazy i cache budowania szybko to zjedza"
    rada "Zrob miejsce albo powieksz dysk maszyny"
else
    blad "Wolne miejsce na dysku: ${DYSK_GB} GB - to za malo"
    rada "Obrazy Dockera, cache budowania i logi potrafia urosnac o kilkanascie GB"
fi

# --- 4. Dostep do internetu --------------------------------------------------
if ! command -v curl >/dev/null 2>&1; then
    blad "Dostep do internetu: nie sprawdzono, bo brakuje narzedzia \"curl\""
elif curl -fsS --max-time 10 -o /dev/null "$URL_TESTOWY" 2>/dev/null; then
    ok "Dostep do internetu (repozytorium Dockera odpowiada)"
else
    blad "Dostep do internetu: brak polaczenia z ${URL_TESTOWY}"
    rada "Sprawdz warstwami: ip a -> ip route -> ping 9.9.9.9 -> ping deb.debian.org"
fi

# --- 5. Uprawnienia administracyjne -----------------------------------------
GRUPY=$(id -nG 2>/dev/null || echo "")
if ! command -v sudo >/dev/null 2>&1; then
    blad "Uprawnienia sudo: nie ma polecenia \"sudo\""
    rada "Na Debianie: zaloguj sie jako root, zainstaluj sudo i dodaj konto do grupy sudo"
elif sudo -n true 2>/dev/null; then
    ok "Uprawnienia sudo (dzialaja bez pytania o haslo - masz swiezy wpis w pamieci sudo)"
elif printf '%s' " $GRUPY " | grep -qE ' (sudo|wheel|admin) '; then
    ok "Uprawnienia sudo (konto nalezy do wlasciwej grupy; sudo zapyta o haslo)"
else
    blad "Uprawnienia sudo: konto \"$(id -un)\" nie nalezy do grupy sudo ani wheel"
    rada "Debian/Ubuntu: usermod -aG sudo <konto>; Rocky: usermod -aG wheel <konto>"
fi

# --- 6. Narzedzia wymagane ---------------------------------------------------
BRAKUJE=""
for NARZEDZIE in git curl python3; do
    command -v "$NARZEDZIE" >/dev/null 2>&1 || BRAKUJE="${BRAKUJE} ${NARZEDZIE}"
done

if [ -z "$BRAKUJE" ]; then
    ok "Narzedzia: git, curl, python3"
else
    blad "Brakuje narzedzi:${BRAKUJE}"
    rada "Debian/Ubuntu: sudo apt install -y${BRAKUJE}"
    rada "Rocky:         sudo dnf install -y${BRAKUJE}   (UWAGA: curl NIE instaluj - jest jako curl-minimal)"
fi

# --- 7. Narzedzia opcjonalne i stan wyjsciowy (informacyjnie) ---------------
if command -v mc >/dev/null 2>&1; then
    info "Midnight Commander (mcedit) obecny - tego edytora uzywam w nagraniach"
else
    info "Midnight Commander (mcedit) nieobecny - w nagraniach uzywam wlasnie jego"
    rada "Doinstaluj: sudo apt install -y mc   albo   sudo dnf install -y mc"
    rada "Nie jest wymagany - mozesz pracowac w nano, vimie lub czym wolisz"
fi

if command -v docker >/dev/null 2>&1; then
    info "Docker JEST zainstalowany - w lekcji 1 to jeszcze niepotrzebne, ale nie przeszkadza"
else
    info "Dockera nie ma - i tak ma byc po lekcji 1; instalujemy go w lekcji 4"
fi

# --- Podsumowanie ------------------------------------------------------------
printf '\n---------------------------------------------------------------\n'
if [ "$BLEDY" -eq 0 ] && [ "$OSTRZEZENIA" -eq 0 ]; then
    printf 'WYNIK: srodowisko gotowe do kursu.\n\n'
    exit 0
elif [ "$BLEDY" -eq 0 ]; then
    printf 'WYNIK: srodowisko gotowe do kursu (ostrzezen: %d - przeczytaj je).\n\n' "$OSTRZEZENIA"
    exit 0
else
    printf 'WYNIK: srodowisko NIE jest gotowe - bledow do naprawienia: %d.\n' "$BLEDY"
    printf 'Popraw je i uruchom ten skrypt jeszcze raz.\n\n'
    exit 1
fi
