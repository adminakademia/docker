#!/usr/bin/env bash
#
# ============================================================================
#  sprawdz-karte.sh - sprawdzarka karty pracy "namespace -> EFEKT"
#  Kurs: "Docker i kontenery dla administratorow sieciowych i DevOps"
#  AdminAkademia - lekcja 3, zadanie samodzielne nr 1
#  Wersja: 2.0 (2026-08-28) - dostosowana do lekcji 3 w wersji "nginx golymi rekami":
#                            szesc namespace'ow robimy na zywo, tylko "user" jest zapowiedzia.
# ============================================================================
#
#  CO ROBI TEN SKRYPT:
#  Czyta plik "karta-namespace-efekt.md" z biezacego katalogu i sprawdza, czy
#  dla kazdego z siedmiu namespace'ow wypelniles pola EFEKT i POLECENIE.
#  Szesc z nich (pid, mnt, uts, ipc, cgroup, net) dokladales do nginx-a w lekcji 3,
#  wiec wpisujesz to, co widziales. Siodmy (user) to zapowiedz - lekcja 41.
#  Dodatkowo podpowiada - jako UWAGA, nigdy jako blad - gdy wpisane polecenie
#  nie zawiera zadnego narzedzia typowego dla danego namespace'u.
#
#  CZEGO TEN SKRYPT NIE ROBI (mozesz to sprawdzic, czytajac ponizszy kod):
#  - nie ocenia, czy Twoja odpowiedz jest MERYTORYCZNIE poprawna - to Twoja karta,
#  - nie URUCHAMIA polecen, ktore wpisales; czyta je wylacznie jako tekst,
#  - nie zapisuje, nie zmienia i nie usuwa zadnego pliku,
#  - nie laczy sie z siecia i nic nigdzie nie wysyla,
#  - nie wymaga Dockera ani uprawnien roota.
#
#  URUCHOMIENIE:
#      bash sprawdz-karte.sh                       # czyta karte-namespace-efekt.md
#      bash sprawdz-karte.sh <sciezka-do-karty>    # albo wskazany plik
#
#  KOD WYJSCIA: 0 = karta wypelniona, 1 = zostalo cos do uzupelnienia.
#
# ============================================================================

set -u

PLIK="${1:-karta-namespace-efekt.md}"
ZNACZNIK="<TU WPISZ>"
NAMESPACES="pid mnt uts ipc cgroup net user"

# Progi "czy to na pewno odpowiedz, a nie znak zapytania".
MIN_EFEKT=15       # znakow - jedno zdanie ma prawo byc krotkie, ale nie jednoliterowe
MIN_POLECENIE=2    # najkrotsze sensowne polecenie to np. "id"

BLEDY=0
OSTRZEZENIA=0

ok()    { printf '[ OK ] %s\n' "$1"; }
uwaga() { printf '[UWAGA] %s\n' "$1"; OSTRZEZENIA=$((OSTRZEZENIA + 1)); }
blad()  { printf '[BLAD] %s\n' "$1"; BLEDY=$((BLEDY + 1)); }
info()  { printf '[  i ] %s\n' "$1"; }
rada()  { printf '        -> %s\n' "$1"; }

# Wyciaga wartosc pola (EFEKT albo POLECENIE) z sekcji danego namespace'u.
# Sekcja zaczyna sie naglowkiem "## <nazwa>", a konczy nastepnym "## " albo linia "---".
pole() {
    awk -v ns="$1" -v nazwa="$2" '
        $0 ~ "^## " ns "([^a-zA-Z0-9_-]|$)" { w = 1; next }
        w && /^## /                         { exit }
        w && /^---/                         { exit }
        w && $0 ~ "^[[:space:]]*[-*][[:space:]]*[*]{0,2}" nazwa "[*]{0,2}[[:space:]]*:" {
            sub("^[[:space:]]*[-*][[:space:]]*[*]{0,2}" nazwa "[*]{0,2}[[:space:]]*:[[:space:]]*", "")
            gsub(/$/, "")            # karta edytowana w Windowsie moze miec CRLF
            sub(/[[:space:]]+$/, "")
            print
            exit
        }
    ' "$PLIK"
}

# Narzedzia, ktorych spodziewamy sie w poleceniu dla danego namespace'u.
# To wylacznie PODPOWIEDZ - inna, dzialajaca droga do tego samego dowodu jest w porzadku.
wzorzec() {
    case "$1" in
        pid)    printf '%s' 'unshare|nsenter|lsns|readlink|ps|[$][$]' ;;
        mnt)    printf '%s' 'unshare|nsenter|lsns|mount|findmnt|/proc' ;;
        uts)    printf '%s' 'unshare|nsenter|lsns|hostname|uname' ;;
        ipc)    printf '%s' 'unshare|nsenter|lsns|ipcs|ipcmk|ipcrm' ;;
        cgroup) printf '%s' 'unshare|nsenter|lsns|cgroup' ;;
        net)    printf '%s' 'unshare|nsenter|lsns|ip |ifconfig|ss |netstat|ping|curl|veth|bridge' ;;
        user)   printf '%s' 'unshare|nsenter|lsns|id|uid_map|gid_map|newuidmap' ;;
    esac
}

opis() {
    case "$1" in
        pid)    printf '%s' 'wlasna numeracja procesow' ;;
        mnt)    printf '%s' 'wlasne punkty montowania' ;;
        uts)    printf '%s' 'wlasna nazwa hosta' ;;
        ipc)    printf '%s' 'wlasne kolejki System V' ;;
        cgroup) printf '%s' 'wlasny widok hierarchii cgroup' ;;
        net)    printf '%s' 'wlasny stos sieciowy - klocek 8 lekcji 3' ;;
        user)   printf '%s' 'wlasne mapowanie uzytkownikow - zapowiedz, lekcja 41' ;;
    esac
}

printf '\n== Karta pracy "namespace -> EFEKT" - sprawdzenie wypelnienia ==\n\n'

# --- 0. Czy jest co sprawdzac ------------------------------------------------
if [ ! -f "$PLIK" ]; then
    blad "Nie znalazlem pliku \"$PLIK\" w biezacym katalogu."
    rada "Rozpakuj paczke z katalogu lekcji 3 w repozytorium kursu wlasnie tutaj,"
    rada "albo wskaz sciezke: bash sprawdz-karte.sh /sciezka/do/karta-namespace-efekt.md"
    printf '\n---------------------------------------------------------------\n'
    printf 'WYNIK: nie ma czego sprawdzic.\n\n'
    exit 1
fi

if [ ! -r "$PLIK" ]; then
    blad "Plik \"$PLIK\" istnieje, ale nie mam prawa go odczytac."
    rada "Sprawdz uprawnienia: ls -l \"$PLIK\""
    printf '\n---------------------------------------------------------------\n'
    printf 'WYNIK: nie ma czego sprawdzic.\n\n'
    exit 1
fi

info "Sprawdzam plik: $PLIK"
printf '\n'

# --- 1. Siedem namespace'ow --------------------------------------------------
for NS in $NAMESPACES; do
    OPIS=$(opis "$NS")

    if ! grep -qE "^## $NS([^a-zA-Z0-9_-]|$)" "$PLIK"; then
        blad "$NS ($OPIS): brak sekcji \"## $NS\" w karcie"
        rada "Nie usuwaj naglowkow z karty - sprawdzarka szuka ich po nazwach"
        continue
    fi

    EFEKT=$(pole "$NS" "EFEKT")
    POLEC=$(pole "$NS" "POLECENIE")
    UWAGA_TEJ_SEKCJI=0

    # --- pole EFEKT ---
    BRAK=0
    case "$EFEKT" in
        ''|*"$ZNACZNIK"*) BRAK=1 ;;
    esac
    if [ "$BRAK" -eq 1 ]; then
        blad "$NS ($OPIS): pole EFEKT jest niewypelnione"
        rada "Napisz JEDNYM zdaniem, co konkretnie widac, gdy ten namespace jest odseparowany"
        continue
    fi
    if [ "${#EFEKT}" -lt "$MIN_EFEKT" ]; then
        uwaga "$NS ($OPIS): pole EFEKT jest bardzo krotkie (\"$EFEKT\")"
        rada "Efekt to OBSERWACJA, nie nazwa mechanizmu - napisz, co zobaczysz na ekranie"
        UWAGA_TEJ_SEKCJI=1
    fi

    # --- pole POLECENIE ---
    BRAK=0
    case "$POLEC" in
        ''|*"$ZNACZNIK"*) BRAK=1 ;;
    esac
    if [ "$BRAK" -eq 1 ]; then
        blad "$NS ($OPIS): pole POLECENIE jest niewypelnione"
        rada "Wpisz polecenie, ktorym pokazesz ten efekt komus, kto Ci nie wierzy"
        continue
    fi
    if [ "${#POLEC}" -lt "$MIN_POLECENIE" ]; then
        blad "$NS ($OPIS): pole POLECENIE wyglada na niepelne (\"$POLEC\")"
        rada "Podaj cale polecenie - takie, ktore mozesz wkleic do terminala"
        continue
    fi

    # --- podpowiedz merytoryczna (nigdy jako blad) ---
    if printf '%s' "$POLEC" | grep -qE "$(wzorzec "$NS")"; then
        [ "$UWAGA_TEJ_SEKCJI" -eq 0 ] && ok "$NS ($OPIS): efekt i polecenie wypelnione"
    else
        uwaga "$NS ($OPIS): w poleceniu nie widze narzedzia typowego dla tego namespace'u"
        rada "Wpisales: $POLEC"
        rada "Masz wlasna, dzialajaca droge do tego dowodu? Zostaw ja i zignoruj te uwage"
    fi
done

# --- 2. Czy nie zostal gdzies znacznik ---------------------------------------
POZOSTALE=$(grep -c -F "$ZNACZNIK" "$PLIK" 2>/dev/null || true)
[ -z "${POZOSTALE:-}" ] && POZOSTALE=0
if [ "$POZOSTALE" -gt 0 ]; then
    info "W pliku zostalo jeszcze $POZOSTALE znacznikow \"$ZNACZNIK\""
fi

# --- Podsumowanie ------------------------------------------------------------
printf '\n---------------------------------------------------------------\n'
if [ "$BLEDY" -eq 0 ] && [ "$OSTRZEZENIA" -eq 0 ]; then
    printf 'WYNIK: karta wypelniona w calosci.\n'
    printf 'Przenies ja do repozytorium portfolio i zapisz w historii:\n'
    printf '  cp %s ~/kurs-docker/\n' "$PLIK"
    printf '  git -C ~/kurs-docker add -A\n'
    printf '  git -C ~/kurs-docker commit -m "lekcja 3: karta namespace -> efekt"\n\n'
    exit 0
elif [ "$BLEDY" -eq 0 ]; then
    printf 'WYNIK: karta wypelniona (uwag: %d - przeczytaj je, ale nic nie musisz zmieniac).\n' "$OSTRZEZENIA"
    printf 'Przenies ja do repozytorium portfolio: cp %s ~/kurs-docker/\n\n' "$PLIK"
    exit 0
else
    printf 'WYNIK: karta NIE jest jeszcze gotowa - pol do uzupelnienia: %d.\n' "$BLEDY"
    printf 'Uzupelnij je i uruchom ten skrypt jeszcze raz.\n\n'
    exit 1
fi
