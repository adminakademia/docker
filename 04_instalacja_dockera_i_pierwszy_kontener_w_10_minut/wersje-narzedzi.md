# Lekcja 4 — wersje narzędzi użytych podczas nagrania

Kurs "Docker i kontenery dla administratorów sieciowych i DevOps" — AdminAkademia.

Cała lekcja została wykonana i sprawdzona na trzech maszynach laboratorium: `docker01`, `docker02`
i `docker03`. Poniżej wersje, na których powstały wydruki cytowane w scenariuszu. Jeśli u Ciebie coś
wygląda inaczej, zacznij od porównania tej listy — Docker Engine wydaje nową wersję co kilka tygodni,
więc numer wersji w Twoim `docker version` niemal na pewno będzie wyższy. Sama procedura instalacji
i to, co robimy po niej, zmieniają się rzadko.

Pomiary: 2026-09-08 (instalacja, wydruki lekcji); komunikaty pułapek repozytorium przemierzone
ponownie 2026-10-16 na `docker01` i `docker03`.

## Maszyny

| Maszyna | System | Jądro | Menedżer pakietów | Zapora / LSM |
|---|---|---|---|---|
| `docker01` | Debian GNU/Linux 13 (trixie) | `6.12.96+deb13-amd64` | apt 3.0.3 | brak zapory, AppArmor |
| `docker02` | Rocky Linux 10.2 (Red Quartz) | `6.12.0-211.49.1.el10_2.x86_64` | dnf 4.20.0, dnf-plugins-core 4.7.0 | firewalld aktywny, SELinux `Enforcing` |
| `docker03` | Ubuntu 26.04.1 LTS (`resolute`) | `7.0.0-31-generic` | apt 3.2.0, snapd (bez zainstalowanych snapów) | ufw nieaktywny, AppArmor |

Wszystkie maszyny: 2 vCPU; `docker01` i `docker03` po 8 GB RAM, `docker02` 2 GB. Konto `kursant`
z `sudo` (na Rocky przez grupę `wheel`). Nazwy `docker01`–`docker03` rozwiązywane z `/etc/hosts`
(lekcja 1, domena `lab.private`).

## Docker Engine z oficjalnego repozytorium (identyczny na trzech maszynach)

| Składnik | Wersja | Skąd |
|---|---|---|
| `docker-ce` (demon `dockerd`) | 29.8.0 | download.docker.com, kanał `stable` |
| `docker-ce-cli` (polecenie `docker`) | 29.8.0, API 1.56 (minimalna 1.40) | j.w. |
| `containerd.io` | 2.3.4, a przy powtórce pomiaru tego samego dnia już 2.3.5 (na `docker03` od razu 2.3.5) — ten pakiet wydawany jest niezależnie od Engine | j.w. |
| `runc` (w pakiecie `containerd.io`) | 1.5.1 | j.w. |
| `docker-init` (tini, w pakiecie `docker-ce`) | 0.19.0 | j.w. |
| `docker-buildx-plugin` | 0.37.0 | j.w. |
| `docker-compose-plugin` | 5.5.1 | j.w. |
| `docker-ce-rootless-extras` | 29.8.0 | doinstalowany automatycznie jako zależność zalecana |

Data zbudowania pakietów 29.8.0: 3 września 2026. Dokumentacja Dockera, względem której powstał
scenariusz, opisuje wydanie 29.6.1 (API 1.55) — różnica dotyczy wyłącznie numerów w wydrukach.

Nazwy pakietów w poszczególnych dystrybucjach:

| Maszyna | `docker-ce` | Zależności doinstalowane przy okazji | Pakietów / pobranie / miejsce |
|---|---|---|---|
| `docker01` (Debian, stan po lekcji 3) | `5:29.8.0-1~debian.13~trixie` | `pigz 2.8-1`, `docker-ce-rootless-extras` | 7 / 99,8 MB / 382 MB |
| `docker01` (Debian od zera, migawka `czysty-system`) | j.w. | dodatkowo `iptables 1.8.11-2`, `libip6tc2`, `libnfnetlink0`, `libnetfilter-conntrack3` | 11 / 99,8 MB / 384 MB |
| `docker02` (Rocky) | `3:29.8.0-1.el10` (CLI: `1:29.8.0-1.el10`) | `container-selinux 2.246.0`, `iptables-nft 1.8.11-16.el10_2`, `tar 1.35`, `docker-ce-rootless-extras` | 9 / 101 MB / 383 MB |
| `docker03` (Ubuntu) | `5:29.8.0-1~ubuntu.26.04~resolute` | `pigz 2.8-1build1`, `docker-ce-rootless-extras` (`iptables 1.8.11-2ubuntu3` był już w systemie) | 7 / 99,8 MB / 382 MB |

Wydruk w scenariuszu pochodzi z maszyny w stanie **po lekcji 3**, czyli z `iptables` zainstalowanym
własnoręcznie w poprzedniej lekcji — dlatego siedem pakietów, tak samo jak na Ubuntu. Na Debianie
postawionym od zera `iptables` i trzy biblioteki do śledzenia połączeń przyjechałyby jako zależność
`docker-ce` i pakietów byłoby jedenaście.

**Debian 13 i Ubuntu 26.04 mają obie apt w wersji 3** (odpowiednio 3.0.3 i 3.2.0), więc wydruk
instalacji ma na obu ten sam układ: „Instalowane:", „Instalowane zależności:", „Podsumowanie:".
Starsze wydania Ubuntu pokazywały tu „Zostaną zainstalowane następujące NOWE pakiety" i wiersz
„0 aktualizowanych, 7 nowo instalowanych…". Apt 3 zmienił też prefiksy komunikatów końcowych:
zamiast krótkich `W:` i `E:` pisze pełne słowa — po angielsku `Warning:` i `Error:`, po polsku
`Ostrzeżenie:` i `Błąd:`. Większość poradników w sieci cytuje jeszcze stary zapis. Prefiksy wierszy
pobierania są po polsku przetłumaczone: `Pobr:` (Get), `Było:` (Hit), `Zign:` (Ign), `Błąd:` (Err).
Kilka nowych komunikatów apt 3 nie ma jeszcze tłumaczenia, więc polski wydruk bywa mieszany, np.
`Ostrzeżenie: OpenPGP signature verification failed: …`.

## Co pokazuje `docker info` po świeżej instalacji

| Pole | `docker01` | `docker02` | `docker03` |
|---|---|---|---|
| Storage Driver | `overlayfs` + `driver-type: io.containerd.snapshotter.v1` | j.w. | j.w. |
| Cgroup Driver / Version | `systemd` / 2 | `systemd` / 2 | `systemd` / 2 |
| Security Options | apparmor, seccomp, cgroupns | seccomp, cgroupns (SELinux `Enforcing`, ale Docker domyślnie nie włącza integracji — w `docker info` go nie widać) | apparmor, seccomp, cgroupns |
| Firewall Backend | `iptables` | `iptables+firewalld` | `iptables` |
| Docker Root Dir | `/var/lib/docker` | `/var/lib/docker` | `/var/lib/docker` |
| Dane obrazów (containerd image store) | `/var/lib/containerd` | `/var/lib/containerd` | `/var/lib/containerd` |

Po pobraniu obrazów `hello-world` i `nginx`: `/var/lib/docker` ≈ 0,3 MB, `/var/lib/containerd` ≈ 242 MB.

## Usługa systemd

| Maszyna | Po instalacji pakietów | Po `systemctl enable --now docker` |
|---|---|---|
| `docker01`, `docker03` | `docker.service` i `docker.socket` **enabled + active** od razu | (niepotrzebne) |
| `docker02` | `docker.service` **disabled + inactive**, brak `/var/run/docker.sock` | `enabled + active` |

Komunikat klienta przy braku gniazda (Rocky przed włączeniem usługi, CLI 29.8.0):
`failed to connect to the docker API at unix:///var/run/docker.sock; check if the path is correct and if the daemon is running: dial unix /var/run/docker.sock: connect: no such file or directory`

Komunikat, gdy gniazdo istnieje, ale nikt na nim nie słucha (zatrzymane `docker.socket` i `docker.service`):
`Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?`

Komunikat bez uprawnień do gniazda (konto poza grupą `docker`):
`permission denied while trying to connect to the docker API at unix:///var/run/docker.sock`

## Obrazy pobrane w lekcji (Docker Hub, bez logowania)

| Obraz | Digest | `docker image ls`: DISK USAGE / CONTENT SIZE | Uwagi |
|---|---|---|---|
| `hello-world:latest` | `sha256:5dd0d3e6e255913fc30f90b9f2b1d359cc2cbdb48090cc4b65f1676e203243cc` | 25,9 kB / 9,49 kB | jedna warstwa |
| `nginx:latest` | `sha256:05b8cb60c354a44ab824ea6e7dc69b46d50762cdbe728a347a5b656e6fb3d7c4` | 253 MB / 69,2 MB | nginx 1.31.5 na Debianie 13; 7 warstw |

Na `docker02` (Rocky) kolumna DISK USAGE pokazuje odpowiednio 21,8 kB i 250 MB — inny system plików
gospodarza, ta sama zawartość.

Limit pobrań Docker Huba bez konta: 100 pobrań na 6 godzin na adres IPv4 lub podsieć IPv6 /64
(lekcja 6 zakłada już własne konto).

## Sieć domyślna Dockera (do porównania z lekcją 3)

| Element | Lekcja 3 (ręcznie) | Docker |
|---|---|---|
| mostek | `br-lab` 10.100.0.1/24 | `docker0` 172.17.0.1/16 |
| adres kontenera | 10.100.0.2/24 | 172.17.0.2/16 |
| interfejs po stronie gospodarza | `veth-lab` | `veth<losowe>@if…` |
| reguła DNAT | ręcznie w `PREROUTING` i `OUTPUT` | w łańcuchu `DOCKER` tabeli `nat`, odwołanym z `PREROUTING` i `OUTPUT` |
| nasłuch na 8080 gospodarza | nikt (`ss -ltnp` puste) | proces `docker-proxy` (IPv4 i IPv6) |
| grupa kontrolna | `/sys/fs/cgroup/nginx-lab` | `/sys/fs/cgroup/system.slice/docker-<ID>.scope` |
| przestrzenie nazw kontenera | mnt, uts, ipc, pid, cgroup, net (6) | mnt, uts, ipc, pid, cgroup, net, **time** (7); `user` wspólny |

Na Rocky Docker rejestruje w firewalld strefę `docker` (interfejs `docker0`, target `ACCEPT`) i politykę
`docker-forwarding` (z dowolnej strefy do strefy `docker`) — dlatego port 8080 był osiągalny z `docker01`
mimo aktywnego firewalld.

## Pakiety nieoficjalne, których w lekcji świadomie NIE instalujemy (stan repozytoriów 2026-09-08)

| Źródło | Pakiet | Wersja |
|---|---|---|
| Debian 13, repozytorium dystrybucji | `docker.io` | 26.1.5+dfsg1-9+deb13u1 |
| Ubuntu 26.04, repozytorium dystrybucji | `docker.io` | 29.1.3-0ubuntu4.1 (z `resolute-updates/universe`) |
| Ubuntu, snap (Canonical) | `docker` | 29.6.1 |

Skrypt convenience (`https://get.docker.com`, commit `4e16be8…`) w trybie `--dry-run` wypisał te same
kroki, które wykonujemy ręcznie, ale z czterema różnicami: zapisuje repozytorium w starszym,
jednowierszowym formacie `docker.list` zamiast `docker.sources`; instaluje wprost także
`docker-ce-rootless-extras` i `docker-model-plugin`; używa `apt-get -qq` (cicho, bez pytania);
oraz sam wykonuje `systemctl enable --now docker.service`. Na maszynie, na której Docker już jest,
skrypt najpierw ostrzega („the docker command appears to already exist") i odczekuje 20 sekund.

## Klucz GPG repozytorium Dockera

| Element | Wartość |
|---|---|
| plik na Debianie/Ubuntu | `/etc/apt/keyrings/docker.asc`, 3817 bajtów, zaczyna się od `-----BEGIN PGP PUBLIC KEY BLOCK-----` |
| odcisk klucza RPM (dnf pokazuje przy imporcie) | `060A 61C5 1B55 8A7F 742B 77AA C52F EB6B 621E 9F35` |
| komunikat przy brakującym lub pustym kluczu | Ubuntu 26.04: `NO_PUBKEY 7EA0A9C3F273FCD8`; Debian 13: `Missing key 7EA0A9C3F273FCD8, which is needed to verify signature.` |

## Komunikaty trzech pułapek repozytorium (apt 3.x, zmierzone 2026-10-16 na `docker01` i `docker03`)

Pomiar w odizolowanym katalogu z własną bazą pakietów, bez zmian w systemie. Wyniki są takie same na
obu dystrybucjach, z wyjątkiem pierwszej pułapki.

**Pułapka 1 — klucz pusty albo zamiast klucza strona `<html>`** (repozytorium dodawane po raz pierwszy).
Ostatni wiersz jest wszędzie ten sam: `Błąd: Repozytorium "https://download.docker.com/linux/… InRelease" nie jest podpisane.`
(po angielsku: `Error: The repository '…' is not signed.`). Różni się wiersz z przyczyną, bo podpis
sprawdzają różne narzędzia:

| Maszyna | Pusty plik klucza | Plik z `<html>` |
|---|---|---|
| `docker03` (Ubuntu, gpgv) | `Następujące podpisy nie mogły zostać zweryfikowane z powodu braku klucza publicznego: NO_PUBKEY 7EA0A9C3F273FCD8` | to samo, plus ostrzeżenie `The key(s) in the keyring … are ignored as the file has an unsupported filetype.` |
| `docker01` (Debian, sqv) | `Missing key 7EA0A9C3F273FCD8, which is needed to verify signature.` | `Error: Failed to parse keyring "…"` |

Komunikaty `sqv` są zawsze po angielsku. Jeżeli repozytorium wcześniej działało, a klucz zepsuł się
później, apt nie przerywa: ostrzega `Nie udało się pobrać …` oraz `Nie udało się pobrać niektórych
plików indeksu, zostały one zignorowane lub użyto ich starszej wersji.` i używa starych list pakietów.

**Pułapka 2 — literówka w `Suites`:** `Zign:` przy `InRelease`, `404  Not Found` przy `Release` i na
końcu `Błąd: Repozytorium "… resolut Release" nie ma pliku Release.` (po angielsku: `Error: The
repository '… resolut Release' does not have a Release file.`). Na Debianie identycznie, z `trixi`.

**Pułapka 3 — architektura, dla której pakietu nie ma** (`apt update` przechodzi bez błędu):

| Stan maszyny | `apt install docker-ce` | `apt policy docker-ce` |
|---|---|---|
| Dockera nigdy nie było | `Błąd: Nie udało się odnaleźć pakietu docker-ce` (EN: `Error: Unable to locate package docker-ce`) | nic nie wypisuje |
| Docker był i został usunięty (`apt remove`, stan `rc`) | `Pakiet docker-ce nie ma dostępnej wersji, ale odnosi się do niego inny pakiet. …` i `Błąd: Pakiet "docker-ce" nie ma kandydata do instalacji` (EN: `Error: Package 'docker-ce' has no installation candidate`) | `Kandydująca: (brak)` |
| wyczyszczony tylko `docker-ce`, reszta Dockera została | jak wyżej, z dopiskiem `Jednak następujące pakiety go zastępują: docker-ce-cli` | `Kandydująca: (brak)` |
| Docker jest zainstalowany | brak błędu: `docker-ce jest już w najnowszej wersji` | wersja z bazy dpkg |

`7EA0A9C3F273FCD8` to identyfikator **podklucza podpisującego** Dockera — dlatego nie zgadza się
z odciskiem klucza głównego podawanym w opisach klucza. Wartość zmierzona, nie wyliczona.

## Komunikaty i lokalizacja

Maszyny kursu pracują z `LANG=pl_PL.UTF-8`. Komunikaty `apt` i `dnf` są po polsku, komunikaty
polecenia `docker`, demona, jądra i `sqv` (sprawdzanie podpisów na Debianie 13) — po angielsku. Scenariusz podaje polską wersję komunikatu tam,
gdzie wypisuje go menedżer pakietów, i angielską tam, gdzie wypisuje go Docker.
