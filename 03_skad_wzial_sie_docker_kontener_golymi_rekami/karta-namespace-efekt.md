# Karta pracy: namespace -> EFEKT

Kurs "Docker i kontenery dla administratorow sieciowych i DevOps" - AdminAkademia, lekcja 3.

## Jak wypełnić tę kartę

Dla każdego z SIEDMIU namespace'ów jądra Linuksa wpisz dwie rzeczy:

- **EFEKT** — jednym zdaniem: co konkretnie ZOBACZYSZ, jeśli ten namespace jest odseparowany.
  Nie "izoluje procesy", tylko np. "wewnątrz `ps` pokazuje trzy procesy zamiast stu".
- **POLECENIE** — polecenie, którym ten efekt pokażesz komuś, kto Ci nie wierzy.

Zastąp każde pole oznaczone jako **TU WPISZ** (w nawiasach ostrokątnych) własną treścią.
Nie usuwaj nagłówków ani wypunktowań — sprawdzarka szuka ich po nazwach.

SZEŚĆ namespace'ów (`pid`, `mnt`, `uts`, `ipc`, `cgroup`, `net`) dokładaliśmy w lekcji 3 do naszego
nginx-a, klocek po klocku — masz je w swoim terminalu i w sekcji "MATERIAŁ REFERENCYJNY (ŚCIĄGA)".
Wpisz to, co RZECZYWIŚCIE zobaczyłeś, a nie definicję z podręcznika.

Został jeden: `user`. Jego jako jedynego dziś nie dołożyliśmy — ma własną lekcję (41). Dla niego
wpisujesz **zapowiedź**: czego się spodziewasz, zanim to zobaczysz. Nikt nie sprawdza, czy zgadłeś —
chodzi o to, żebyś miał własną hipotezę, do której wrócisz. Podpowiedź jest w lekcji 3, w sekcji
"CO ZOSTAJE WSPÓLNE Z GOSPODARZEM": sprawdź, co pokazało polecenie `id` w kontenerze.

> **Dlaczego siedem, skoro `lsns` pokazuje osiem wierszy?** Ta karta obejmuje siedem przestrzeni
> nazw, z których składamy kontener. Jądro ma jeszcze jedną, najmłodszą — `time`, dodaną
> w jądrze 5.6 w 2020 roku — która pozwala podać procesowi inny czas rozruchu i inny zegar
> monotoniczny. Docker jej domyślnie nie używa i my też nie, dlatego w wyniku `lsns` widzimy
> w tym wierszu przestrzeń gospodarza. Karty o nią nie uzupełniamy.

Sprawdzenie wypełnienia:

    bash sprawdz-karte.sh

Na koniec przenieś wypełnioną kartę do swojego repozytorium portfolio `~/kurs-docker`
i zrób commit — to jeden z pierwszych dowodów, które zbierasz przez cały kurs.

---

## pid — własna numeracja procesów

- EFEKT: <TU WPISZ>
- POLECENIE: <TU WPISZ>

## mnt — własne punkty montowania

- EFEKT: <TU WPISZ>
- POLECENIE: <TU WPISZ>

## uts — własna nazwa hosta i domeny

- EFEKT: <TU WPISZ>
- POLECENIE: <TU WPISZ>

## ipc — własne kolejki komunikatów i pamięć współdzielona System V

- EFEKT: <TU WPISZ>
- POLECENIE: <TU WPISZ>

## cgroup — własny widok hierarchii grup kontrolnych

- EFEKT: <TU WPISZ>
- POLECENIE: <TU WPISZ>

## net — własny stos sieciowy (dokładaliśmy go w klocku 8; pogłębienie w module 3)

- EFEKT: <TU WPISZ>
- POLECENIE: <TU WPISZ>

## user — własne mapowanie użytkowników (lekcja 41 — wpisz zapowiedź)

- EFEKT: <TU WPISZ>
- POLECENIE: <TU WPISZ>

---

## Dwa pytania na koniec (nie sprawdza ich żaden skrypt)

**1.** Który z tych siedmiu namespace'ów Docker nadaje kontenerowi **domyślnie**, a który trzeba
włączyć świadomie? Odpowiedź poznasz w lekcji 4 i w module 10 — ale spróbuj obstawić już teraz.

**2.** W lekcji 3 nałożyliśmy na nginx-a limit pamięci i procesora. Czy to też był namespace?
Jeśli nie — to co, i czym się różni od wszystkich siedmiu pozycji z tej karty? Odpowiedz jednym
zdaniem, używając słów "widzi" i "zużyć". To jest rozróżnienie, które w tym kursie wraca
przy każdej diagnozie.
