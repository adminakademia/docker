# Lekcja 3 — wersje narzędzi użytych podczas lekcji

Kurs "Docker i kontenery dla administratorów sieciowych i DevOps" — AdminAkademia.

Cała lekcja została wykonana i sprawdzona na maszynie `docker01`. Poniżej wersje, na których
powstała lekcja. Jeśli u Ciebie coś wygląda inaczej, zacznij od porównania
tej listy.

## Maszyna

| Element | Wersja |
|---|---|
| System | Debian GNU/Linux 13 (trixie) |
| Jądro | `6.12.96+deb13-amd64` |
| Biblioteka standardowa | glibc `2.41-12+deb13u3` |
| Hierarchia cgroup | v2 (unified), montowana w `/sys/fs/cgroup` |
| Kontrolery udostępniane przez jądro | `cpuset cpu io memory hugetlb pids rdma misc` |
| Kontrolery przekazane przez korzeń hierarchii | `cpu memory pids` |
| Procesory / pamięć maszyny | 2 vCPU / 8 GB RAM, swap włączony |

## Pakiety doinstalowane w lekcji

| Pakiet | Wersja | Po co |
|---|---|---|
| `nginx` | `1.26.3-3+deb13u7` | usługa, z której plików budujemy obraz |
| `busybox-static` | `1:1.37.0-6+b8` | powłoka i podstawowe narzędzia wewnątrz obrazu |
| `iptables` | `1.8.11-2` | publikacja portu kontenera (klocek 8) |

Uwaga o `iptables` na Debianie 13: pakiet instaluje mechanizm alternatyw i domyślnie ustawia
`iptables-nft`. Reguły z tej lekcji trafiają więc do nftables, choć wpisujemy je składnią iptables —
dokładnie tak samo robi to Docker.

## Pakiety, które były już w systemie

| Pakiet | Wersja | Polecenia z lekcji |
|---|---|---|
| `iproute2` | `6.15.0-1` | `ip`, `ss`, `bridge` |
| `util-linux` | z Debiana 13 — sprawdź: `unshare --version` | `unshare`, `nsenter`, `lsns`, `ipcmk`, `ipcs`, `ipcrm` |
| `coreutils` | z Debiana 13 | `head`, `tail`, `readlink`, `install` |
| `curl` | `8.14.1` | testy HTTP |

## Obraz zbudowany skryptem `zbuduj-rootfs.sh`

| Element | Wartość |
|---|---|
| Rozmiar katalogu `/srv/nginx-lab/rootfs` | ~15 MB |
| Liczba plików | 17 |
| Biblioteki skopiowane z listy `ldd` | `libcrypt.so.1`, `libpcre2-8.so.0`, `libssl.so.3`, `libcrypto.so.3`, `libz.so.1`, `libc.so.6`, `libzstd.so.1`, `ld-linux-x86-64.so.2` |
| Dodatkowo | `libnss_files.so.2` — bez niej nginx nie rozwiąże nazwy użytkownika `www-data` |
| Węzły urządzeń | `/dev/null`, `/dev/zero`, `/dev/random`, `/dev/urandom` |

## Adresacja użyta w klocku 8

| Element | Wartość |
|---|---|
| Mostek `br-lab` (brama kontenera) | `10.100.0.1/24` |
| Kontener, interfejs `eth0` | `10.100.0.2/24` |
| Port wewnątrz kontenera | `80` |
| Port opublikowany na gospodarzu | `8080` |

Sieć `10.100.0.0/24` została dobrana tak, żeby nie kolidowała z siecią laboratorium
(`192.168.100.0/23`). Jeśli u Ciebie ten zakres jest zajęty, zmień wszystkie cztery wystąpienia —
mechanizm pozostaje identyczny.

## Pozostałe maszyny laboratorium

Namespaces, cgroups, `veth`, mostek i reguły NAT działają tak samo na `docker02` (Rocky Linux)
i `docker03` (Ubuntu) — to mechanizmy jądra. Różni się wyłącznie instalacja pakietów:
na Rocky `busybox` mieszka w repozytorium EPEL, a usługa `nginx` nie startuje sama po instalacji.

## Komunikaty i lokalizacja

Maszyny kursu pracują z `LANG=pl_PL.UTF-8`. W scenariuszu podane są obie wersje tam, gdzie to
istotne. Reguła: komunikaty powłoki gospodarza są polskie, komunikaty busyboksa z obrazu i samego
nginx-a są angielskie, komunikaty jądra (`dmesg`) są zawsze angielskie.
