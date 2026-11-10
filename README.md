# Analiza Wydatków i Kosztów Firmy – Dashboard BI

Kompleksowy projekt z zakresu inżynierii danych oraz analityki biznesowej (BI), przedstawiający analizę kosztów i wydatków firmy w wybranej ramie czasowej. Projekt ukazuje proces pracy od utworzenia surowych, chaotycznych danych źródłowych aż po interaktywny dashboard.

---

## O projekcie

Praca skupia się na dwóch głównych filarach:
1. **Inżynieria Danych (SQL & ETL):** wprowadzenie, przetworzenie, oczyszczenie i normalizacja danych przy użyciu PostgreSQL oraz TablePlus wraz z zaprojektowaniem i wdrożeniem relacyjnego modelu gwiazdy. Dodatkowe poprawki i usprawnienia kategorii tekstowych zostały domknięte w Power Query.
2. **Analityka i Wizualizacja:** stworzenie miar w języku DAX oraz zaprojektowanie dashboardu w Power BI.

---

## Zastosowane narzędzia

* **PostgreSQL & TablePlus:** główna inżynieria danych – tworzenie struktur, relacyjny model gwiazdy, czyszczenie i transformacja danych na poziomie bazy SQL.
* **Power Query:** dodatkowe wsparcie przy tworzeniu kategorii tekstowych.
* **DAX:** miary agregujące, obsługa przeliczeń walutowych w locie oraz obliczenia udziałów procentowych.
* **Power BI:** wizualizacja danych, karty, analiza pareto kontrahentów, struktura walutowa oraz analiza w czasie.

---

## Kluczowe elementy raportu

* **Całkowite koszty i wolumen:** śledzenie sumarycznych wydatków netto po przeliczeniu na PLN oraz liczby transakcji.
* **Analiza struktury kosztów:** podział wydatków według kategorii opisowych (m.in. Infrastruktura, Logistyka, Wsparcie biznesu).
* **Top Kontrahentów:** ukazanie kluczowych dostawców generujących największe obciążenie budżetowe firmy wraz z ich udziałem procentowym.
* **Kontrola statusów i walut:** monitorowanie transakcji opłaconych, w toku oraz anulowanych, a także struktura rozliczeń w walutach obcych (EUR, USD, PLN).

### Utworzone miary DAX:

**Całkowita kwota netto w PLN:**
```dax
Całkowita kwota netto w PLN = 
SUMX(transakcje, transakcje[kwota_netto] * RELATED(waluty[kurs_do_pln]))
```
**Liczba transakcji:**
```dax
Liczba transakcji = 
COUNTROWS(transakcje)
```
**Proc. udział kontrahenta:**
```dax
Proc. udział kontrahenta = 
VAR Kwota = [Całkowita kwota netto w PLN]
VAR CalaKwota = CALCULATE([Całkowita kwota netto w PLN], REMOVEFILTERS(kontrahenci[kontrahent]))
RETURN
DIVIDE(Kwota, CalaKwota, 0)
```
**Status - udział w całkowitej kwocie netto:**
```dax
Status - udział w całkowitej kwocie netto = 
VAR KwotaStatus = [Całkowita kwota netto w PLN]
VAR AllKwotaStatus = CALCULATE([Całkowita kwota netto w PLN], REMOVEFILTERS(transakcje[status]))
RETURN
DIVIDE(KwotaStatus, AllKwotaStatus, 0)
```
**Kalendarz:**
```dax
Kalendarz = 
CALENDAR(MIN(transakcje[data_operacji]), MAX(transakcje[data_operacji]))
```

---

## Struktura projektu

- `01_schema.sql` — tworzenie schematu bazy danych.
- `02_seed_data.sql` — wprowadzanie surowych danych.
- `03_star_schema.sql` — transformacje.
- `dashboard.pbix` — plik raportu Power BI.


### Zrzuty ekranu z projektu:

#### Podgląd raportu
<img width="1315" height="742" alt="zrzut_ekranu_podglad_raportu" src="https://github.com/user-attachments/assets/8cbfa481-bf19-4fa8-8957-4aa7f97a81e4" />

#### Model danych (relacje)
<img width="1318" height="774" alt="zrzut_ekranu_relacje" src="https://github.com/user-attachments/assets/c457214d-0f5f-4327-b211-a1509df47825" />

