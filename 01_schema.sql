-- =================================
-- Tabela: surowe_dane_finansowe
-- =================================
CREATE TABLE surowe_dane_finansowe
(id_transakcji VARCHAR(20),
data_operacji VARCHAR(20),
typ_dokumentu VARCHAR(50),
kontrahent_pelna_nazwa VARCHAR(50),
nip VARCHAR(50),
kwota_netto VARCHAR(20),
waluta VARCHAR(10),
kategoria_opisowa VARCHAR(50),
status VARCHAR(20),
notatki_systemowe VARCHAR(100));