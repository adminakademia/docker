# Karta pracy: namespace -> EFEKT

Kurs "Docker i kontenery dla administratorow sieciowych i DevOps" - AdminAkademia, lekcja 3.

## Jak wypełnić tę kartę

Dla każdego z SIEDMIU namespace'ów jądra Linuksa wpisz dwie rzeczy:

- **EFEKT** — jednym zdaniem: co konkretnie ZOBACZYSZ, jeśli ten namespace jest odseparowany.
  Nie "izoluje procesy", tylko np. "wewnątrz `ps aux` pokazuje dwa procesy zamiast stu".
- **POLECENIE** — polecenie, którym ten efekt pokażesz komuś, kto Ci nie wierzy.

Zastąp każde pole oznaczone jako **TU WPISZ** (w nawiasach ostrokątnych) własną treścią.
Nie usuwaj nagłówków ani wypunktowań — sprawdzarka szuka ich po nazwach.

Pięć pierwszych namespace'ów (`pid`, `mnt`, `uts`, `ipc`, `cgroup`) robiliśmy w lekcji 3 —
masz je w swoim terminalu i w sekcji "MATERIAŁ REFERENCYJNY (ŚCIĄGA)". Dla `net` (moduł 3)
i `user` (moduł 10) wpisujesz **zapowiedź**: czego się spodziewasz, zanim to zobaczysz.
Nikt nie sprawdza, czy zgadłeś — chodzi o to, żebyś miał własną hipotezę, do której wrócisz.

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

## net — własny stos sieciowy (moduł 3 — wpisz zapowiedź)

- EFEKT: <TU WPISZ>
- POLECENIE: <TU WPISZ>

## user — własne mapowanie użytkowników (moduł 10 — wpisz zapowiedź)

- EFEKT: <TU WPISZ>
- POLECENIE: <TU WPISZ>

---

## Pytanie na koniec (nie sprawdza go żaden skrypt)

Który z tych siedmiu namespace'ów Docker nadaje kontenerowi **domyślnie**, a który trzeba
włączyć świadomie? Odpowiedź poznasz w module 4 i w module 10 — ale spróbuj obstawić już teraz.
