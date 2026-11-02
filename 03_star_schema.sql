-- ===============================================================
-- Tabela: kontrahenci (wymiar)
-- ===============================================================
-- Cel: utworzenie tabeli wymiaru z tabeli surowa_dane_finansowe

CREATE TABLE kontrahenci AS WITH czysty_kontrahent AS (SELECT 
TRIM(kontrahent_pelna_nazwa) AS kontrahent,
COALESCE(REGEXP_REPLACE(nip, '[^0-9]', '', 'g'), CONCAT(TRIM(kontrahent_pelna_nazwa), ' / Brak NIP')) AS numer_nip,
ROW_NUMBER() OVER(PARTITION BY COALESCE(REGEXP_REPLACE(nip, '[^0-9]', '', 'g'), CONCAT(TRIM(kontrahent_pelna_nazwa), ' / Brak NIP')) ORDER BY LENGTH(TRIM(kontrahent_pelna_nazwa)) DESC) AS nr_wiersza
FROM surowe_dane_finansowe)
SELECT
ROW_NUMBER() OVER(ORDER BY numer_nip) AS id_kontrahenta,
kontrahent,
numer_nip
FROM czysty_kontrahent
WHERE nr_wiersza = 1;

-- ==============================================================
-- Tabela: waluty (wymiar)
-- ==============================================================
-- Cel: utworzenie tabeli wymiaru z tabeli surowa_dane_finansowe

CREATE TABLE waluty AS
WITH czysta_waluta AS (SELECT distinct
CASE
WHEN UPPER(TRIM(waluta)) ='ZŁ' THEN 'PLN'
ELSE UPPER(TRIM(waluta))
END AS waluta
FROM surowe_dane_finansowe)
SELECT
ROW_NUMBER() OVER(ORDER BY waluta) AS id_waluty,
waluta,
CASE
WHEN waluta = 'USD' THEN 3.50
WHEN waluta = 'EUR' THEN 4.30
ELSE 1
END AS kurs_do_pln
FROM czysta_waluta;

-- ==============================================================
-- Tabela: typ_dokumentu (wymiar)
-- ==============================================================
-- Cel: utworzenie tabeli wymiaru z tabeli surowa_dane_finansowe

CREATE TABLE typ_dokumentu AS
WITH czysty_typ_dokumentu AS
(SELECT DISTINCT
INITCAP(TRIM(typ_dokumentu)) AS dokument
FROM surowe_dane_finansowe)
SELECT
ROW_NUMBER() OVER(ORDER BY dokument) AS id_dokumentu,
dokument
FROM czysty_typ_dokumentu;

-- ==============================================================
-- Tabela: transakcje (fakty)
-- ==============================================================
-- Cel: utworzenie tabeli faktów z tabeli surowa_dane_finansowe

CREATE TABLE transakcje AS
WITH czyste_dane AS
(SELECT 
id_transakcji,
CASE
WHEN REGEXP_REPLACE(TRIM(data_operacji), '[.,/]', '-', 'g') LIKE '____-__-__' THEN TO_DATE(REGEXP_REPLACE(TRIM(data_operacji), '[.,/]', '-', 'g'), 'YYYY-MM-DD')
WHEN REGEXP_REPLACE(TRIM(data_operacji), '[.,/]', '-', 'g') LIKE '__-__-____' THEN TO_DATE(REGEXP_REPLACE(TRIM(data_operacji), '[.,/]', '-', 'g'), 'DD-MM-YYYY')
ELSE NULL
END AS data_operacji,
INITCAP(TRIM(typ_dokumentu)) AS typ_dokumentu,
TRIM(kontrahent_pelna_nazwa) AS kontrahent,
COALESCE(REGEXP_REPLACE(TRIM(nip),'[^0-9]', '', 'g'), CONCAT(TRIM(kontrahent_pelna_nazwa), ' / Brak NIP')) AS numer_nip,
REPLACE(TRIM(kwota_netto), ',', '.')::DECIMAL(12,2) AS kwota_netto,
CASE
WHEN UPPER(TRIM(waluta)) = 'ZŁ' THEN 'PLN'
ELSE UPPER(TRIM(waluta))
END AS waluta,
COALESCE(INITCAP(TRIM(kategoria_opisowa)), 'Inne') AS kategoria_opisowa,
CASE
WHEN INITCAP(TRIM(status)) IN ('Paid', 'Zapłacone', 'Zaksięgowane', 'Opłacona') THEN 'Opłacone'
WHEN INITCAP(TRIM(status)) IN ('Częściowo Opłacona', 'W Toku') THEN 'W Trakcie'
WHEN INITCAP(TRIM(status)) = 'Anulowana' THEN 'Anulowane'
ELSE INITCAP(TRIM(status))
END AS status,
COALESCE(TRIM(notatki_systemowe), '--') AS notatki_systemowe
FROM surowe_dane_finansowe),
zestawienie AS
(SELECT czd.id_transakcji,
czd.data_operacji,
czd.typ_dokumentu,
k.id_kontrahenta,
czd.kwota_netto,
czd.waluta,
czd.kategoria_opisowa,
czd.status,
czd.notatki_systemowe
FROM czyste_dane czd
LEFT JOIN kontrahenci k
ON czd.numer_nip = k.numer_nip),
zestawienie_2 AS
(SELECT
z.id_transakcji,
z.data_operacji,
z.typ_dokumentu,
z.id_kontrahenta,
z.kwota_netto,
w.id_waluty,
z.kategoria_opisowa,
z.status,
z.notatki_systemowe
FROM zestawienie z
LEFT JOIN waluty w
ON z.waluta = w.waluta)
SELECT
z2.id_transakcji,
z2.data_operacji,
tp.id_dokumentu,
z2.id_kontrahenta,
z2.kwota_netto,
z2.id_waluty,
z2.kategoria_opisowa,
z2.status,
z2.notatki_systemowe
FROM zestawienie_2 z2
LEFT JOIN typ_dokumentu tp
ON z2.typ_dokumentu = tp.dokument;