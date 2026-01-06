# 📝 Návod pro generování otázek do Českého Kvízu

## Formát CSV souboru

```
kategorie;otazka;odpoved_a;odpoved_b;odpoved_c;odpoved_d;spravna;obtiznost;vedeli_jste
```

### Sloupce:
1. **kategorie** - jedna z: Historie, Zeměpis, Osobnosti, Kultura, Sport
2. **otazka** - text otázky
3. **odpoved_a až d** - 4 odpovědi (správná je vždy A pro jednoduchost)
4. **spravna** - vždy "A" (správnou odpověď dej na první místo)
5. **obtiznost** - číslo 1-4:
   - 1 = ⭐ Začátečník (základní znalosti, každý Čech musí vědět)
   - 2 = ⭐⭐ Mírně pokročilý (středoškolské znalosti)
   - 3 = ⭐⭐⭐ Pokročilý (hlubší znalosti, zajímavosti)
   - 4 = ⭐⭐⭐⭐ Expert (specialista, historik, fanoušek)
6. **vedeli_jste** - zajímavost "Věděli jste, že..." (NEPOVINNÉ, může být prázdné)

## 💡 Pravidla pro "Věděli jste, že..."

### Kdy přidat zajímavost:
- U historických událostí s překvapivým kontextem
- U osobností se zajímavými fakty
- U zeměpisných míst s unikátní historií
- U kulturních témat s neznámými detaily
- **NE u každé otázky** - přibližně u 30-40% otázek

### Jak psát zajímavosti:
- Začni "Věděli jste, že..." nebo zkráceně faktem
- Maximálně 2 věty
- Musí souviset s otázkou
- Přidej hodnotu - něco co čtenář pravděpodobně neví

### Příklady dobrých zajímavostí:
- ✅ "Karel IV. mluvil pěti jazyky a byl považován za nejlépe vzdělaného panovníka své doby."
- ✅ "Sněžka je pojmenována podle sněhu, který na jejím vrcholu zůstává nejdéle v Česku."
- ✅ "Antonín Dvořák komponoval symfonii Z Nového světa během pobytu v New Yorku, kde mu chyběla domovina."
- ❌ "Praha je hlavní město." (příliš jednoduché, každý ví)

## Pravidla pro otázky

### Obecné:
- Každá otázka musí mít JEDNU správnou odpověď
- Špatné odpovědi musí být věrohodné (ne nesmysly)
- Otázky musí být fakticky správné a ověřitelné
- Používej správnou češtinu s diakritikou

### Pro obtížnost 1 (Začátečník):
- Státní svátky, symboly
- Nejvyšší hora, nejdelší řeka
- Hlavní město, sousední země
- Základní historické události (1918, 1989, 1993)
- Nejznámější osobnosti (Havel, Jágr, Dvořák)

### Pro obtížnost 2 (Mírně pokročilý):
- Středoškolské učivo
- Méně známé osobnosti
- Detaily z historie (roky, místa)
- Regionální znalosti

### Pro obtížnost 3-4 (Pokročilý, Expert):
- Specifická data a čísla
- Méně známé fakty
- Detaily z historie a kultury
- Odborné znalosti

## Kategorie a příklady témat

### Historie
- České dějiny od Přemyslovců
- Husitství, 30letá válka
- 1. a 2. světová válka
- Komunismus, Sametová revoluce
- Prezidenti, králové, významné osobnosti

### Zeměpis  
- Hory, řeky, jezera
- Města, kraje, regiony
- Národní parky, UNESCO památky
- Sousední země, hranice
- Statistiky (rozloha, obyvatelé)

### Osobnosti
- Hudební skladatelé (Dvořák, Smetana, Janáček)
- Spisovatelé (Čapek, Hašek, Kundera, Kafka)
- Vědci a vynálezci (Wichterle, Heyrovský)
- Sportovci (Jágr, Zátopek, Čáslavská)
- Politici, umělci, herci

### Kultura
- Tradice a svátky
- Jídlo a pití (pivo, kuchyně)
- Hudba, literatura, film
- Architektura, umění
- České zvyky (Vánoce, Velikonoce)

### Sport
- Hokej (MS, NHL, olympiáda)
- Fotbal (ligy, hráči)
- Tenis (Wimbledon, grandslamy)
- Atletika (olympionici)
- Ostatní sporty (lyžování, cyklistika)

## Příklad dobré otázky

```csv
Historie;Ve kterém roce vznikla Československá republika?;1918;1920;1914;1945;A;1;Československo vzniklo 28. října 1918 po rozpadu Rakouska-Uherska na konci 1. světové války.
```

- ✅ Jasná otázka
- ✅ Správná odpověď je první
- ✅ Špatné odpovědi jsou věrohodná data
- ✅ Obtížnost 1 - základní znalost
- ✅ Zajímavost přidává kontext

## Kolik otázek generovat

- Celkem cíl: **500+ otázek**
- Rozložení podle obtížnosti:
  - Obtížnost 1: 40% (200 otázek)
  - Obtížnost 2: 35% (175 otázek)
  - Obtížnost 3: 20% (100 otázek)
  - Obtížnost 4: 5% (25 otázek)

- Rozložení podle kategorií (přibližně rovnoměrně):
  - Historie: 100 otázek
  - Zeměpis: 100 otázek
  - Osobnosti: 100 otázek
  - Kultura: 100 otázek
  - Sport: 100 otázek

- **Zajímavosti**: přibližně u 30-40% otázek (150-200 otázek)

## Kam uložit

Soubory uložit do: `/Users/superman/Desktop/ceskykvizhra2/admin-panel/`

Názvy souborů:
- `questions_batch1.csv` (prvních 100)
- `questions_batch2.csv` (dalších 100)
- atd.

## Nahrání do databáze

1. Otevři admin panel (Vercel URL nebo localhost)
2. Přihlaš se kódem: `kviz2026`
3. Jdi na záložku "Nahrát CSV"
4. Přetáhni nebo vyber CSV soubor
5. Zkontroluj náhled
6. Klikni "Nahrát do databáze"
