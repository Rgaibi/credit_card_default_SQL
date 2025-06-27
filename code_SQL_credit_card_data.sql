
-- 1_Modélisation & Chargement des données

-- Création des tables principales
CREATE TABLE IF NOT EXISTS clients (
    client_id INT PRIMARY KEY,
    sex VARCHAR(255),
    education VARCHAR(255),
    marriage VARCHAR(255),
    age INT
);

CREATE TABLE IF NOT EXISTS credit_limits (
  credit_id INT PRIMARY KEY AUTO_INCREMENT,
  client_id INT UNIQUE,
  limit_bal DECIMAL(10,2),
  FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

CREATE TABLE IF NOT EXISTS repayment_status (
  status_id INT PRIMARY KEY AUTO_INCREMENT,
  client_id INT,
  `month` DATE,
  pay INT,
  FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

CREATE TABLE IF NOT EXISTS bill_statements (
  statement_id INT PRIMARY KEY AUTO_INCREMENT,
  client_id INT,
  `month` DATE,
  bill_amt DECIMAL(10,2),
  FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

CREATE TABLE IF NOT EXISTS payments (
  payment_id INT PRIMARY KEY AUTO_INCREMENT,
  client_id INT ,
  `month` DATE,
  pay_amt DECIMAL(10,2),
  FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

CREATE TABLE IF NOT EXISTS default_payments (
    default_id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT UNIQUE,
    default_payment_next_month INT,
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

DESCRIBE credit_card_data;

-- 2_Insertion des données depuis le dataset Kaggle 'https://www.kaggle.com/datasets/farahananda/credit-card-clients-data'

INSERT INTO clients (client_id, sex, education, marriage, age)
SELECT
  ID,
  CAST(SEX AS CHAR(255)),
  CAST(EDUCATION AS CHAR(255)),
  CAST(MARRIAGE AS CHAR(255)),
  AGE
FROM credit_card_data; 

INSERT INTO credit_limits (client_id, limit_bal)
SELECT
  ID,
  CAST(LIMIT_BAL AS DECIMAL(10,2))
FROM credit_card_data; 

INSERT INTO repayment_status (client_id, `month`, pay )          
SELECT
  ID, '2005-09-01',  PAY_0
FROM credit_card_data
UNION ALL
SELECT
  ID, '2005-08-01',  PAY_2
FROM credit_card_data 
UNION ALL
SELECT
  ID, '2005-07-01',  PAY_3
FROM credit_card_data
UNION ALL
SELECT
  ID, '2005-06-01',  PAY_4
FROM credit_card_data 
UNION ALL
SELECT
  ID, '2005-05-01',  PAY_5
FROM credit_card_data 
UNION ALL
SELECT
  ID, '2005-04-01',  PAY_6
FROM credit_card_data;

INSERT INTO bill_statements (client_id, `month`, bill_amt) 
SELECT
  ID, '2005-09-01', CAST(BILL_AMT1 AS DECIMAL(10,2))
FROM credit_card_data
UNION ALL
SELECT
  ID, '2005-08-01', CAST(BILL_AMT2 AS DECIMAL(10,2))
FROM credit_card_data 
UNION ALL
SELECT
  ID, '2005-07-01', CAST(BILL_AMT3 AS DECIMAL(10,2))
FROM credit_card_data 
UNION ALL
SELECT
  ID, '2005-06-01', CAST(BILL_AMT4 AS DECIMAL(10,2))
FROM credit_card_data
UNION ALL
SELECT
  ID, '2005-05-01', CAST(BILL_AMT5 AS DECIMAL(10,2))
FROM credit_card_data
UNION ALL
SELECT
  ID, '2005-04-01', CAST(BILL_AMT6 AS DECIMAL(10,2))
FROM credit_card_data;

INSERT INTO payments (client_id, `month`, pay_amt)
SELECT
  ID, '2005-09-01', CAST(PAY_AMT1 AS DECIMAL(10,2))
FROM credit_card_data
UNION ALL
SELECT
  ID, '2005-08-01', CAST(PAY_AMT2 AS DECIMAL(10,2))
FROM credit_card_data 
UNION ALL
SELECT
  ID, '2005-07-01', CAST(PAY_AMT3 AS DECIMAL(10,2))
FROM credit_card_data 
UNION ALL
SELECT
  ID, '2005-06-01', CAST(PAY_AMT4 AS DECIMAL(10,2))
FROM credit_card_data
UNION ALL
SELECT
  ID, '2005-05-01', CAST(PAY_AMT5 AS DECIMAL(10,2))
FROM credit_card_data
UNION ALL
SELECT
  ID, '2005-04-01', CAST(PAY_AMT6 AS DECIMAL(10,2))
FROM credit_card_data;


INSERT INTO default_payments (client_id, default_payment_next_month)
SELECT
  ID,
  default_payment_next_month
FROM credit_card_data;

-- 3_Contrôle qualité des données
-- Objectif métier : garantir l’intégrité et la complétude avant toute analyse

-- Aperçu des tables principales
SELECT * FROM clients       LIMIT 10;
SELECT * FROM credit_limits LIMIT 10;
SELECT * FROM bill_statements LIMIT 10;
SELECT * FROM payments      LIMIT 10;
SELECT * FROM default_payments LIMIT 10;

--  Comptage global des enregistrements
SELECT 
  (SELECT COUNT(*) FROM clients)         AS total_clients,
  (SELECT COUNT(*) FROM credit_limits)   AS total_credit_limits,
  (SELECT COUNT(*) FROM bill_statements) AS total_bill_records,
  (SELECT COUNT(*) FROM payments)        AS total_payments,
  (SELECT COUNT(*) FROM default_payments)AS total_default_records,
  (SELECT COUNT(*) FROM repayment_status)AS total_repayment_status;

-- Vérification des valeurs manquantes et doublons
-- Valeurs NULL au sein de la table clients
SELECT 
  SUM(CASE WHEN sex IS NULL THEN 1 ELSE 0 END) AS null_sex,
  SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS null_age
FROM clients;

SELECT 
  SUM(CASE WHEN pay_amt IS NULL THEN 1 ELSE 0 END) AS null_pay_amt
FROM payments;

-- Doublons sur client_id dans payments (doit être unique)
SELECT client_id, `month`, COUNT(*) AS occurrences
FROM payments
GROUP BY client_id, `month`
HAVING COUNT(*) > 1;

-- 4_Création de Vue
-- Préparer des vues intermédiaires pour faciliter les analyses. 

--  Vue fusionnée : Profil client + plafond de crédit + statut de défaut
CREATE VIEW v_client_plafond_defaut AS
SELECT 
  c.client_id,
  c.sex,
  c.age,
  cl.limit_bal,
  dp.default_payment_next_month
FROM clients c 
INNER JOIN credit_limits cl ON c.client_id = cl.client_id
INNER JOIN default_payments dp ON c.client_id = dp.client_id
ORDER BY limit_bal DESC;

-- 5_Segmentation Clientèle & Analyse Démographique
-- Objectif : Découper le portefeuille en segments et mesurer les comportements

-- Âge moyen par sexe
SELECT 
 sex,
 avg(age) AS age_moyen,
 count(*) nombre_clients
FROM clients
GROUP BY sex;

-- Segmentation par Tranche d’Âge et Taux de Défaut de Paiement
SELECT
  CASE
   WHEN age < 25 THEN 'mois 25 ans'
   WHEN age between 25 AND 34 THEN 'entre 25 et 34'
   WHEN age between 35 AND 50 THEN 'entre 35 et 50'
   WHEN age between 51 AND 65 THEN 'entre 51 et 65'
   WHEN age > 65 THEN 'plus 65 ans'
  END AS age_segment,
  COUNT(c.client_id) AS nombre_clients,
  SUM(CASE WHEN default_payment_next_month = 1 THEN 1 ELSE 0 END) AS nombre_defauts,
  SUM(CASE WHEN default_payment_next_month = 1 THEN 1 ELSE 0 END)/COUNT(c.client_id) AS taux_defaut,
  ROUND(SUM(CASE WHEN default_payment_next_month = 1 THEN 1 ELSE 0 END) * 100 / COUNT(c.client_id), 2) AS pourcentage_default
FROM clients c
INNER JOIN default_payments dp ON c.client_id = dp.client_id
GROUP BY age_segment;

-- 6_Analyse des écarts facturation vs paiement
-- Objectif métier : identifier les clients en retard sur les 6 derniers mois

SELECT
  bs.client_id,
  SUM((bill_amt - pay_amt)) AS ecart_facturation_paiement
FROM bill_statements bs
INNER JOIN payments p ON bs.client_id = p.client_id
GROUP BY bs.client_id;

-- 7_Analyses temporelles des paiements

-- variation,Rangs, cumul et moyenne mobile de 3mois

SELECT
  client_id,
  `month`,
  pay_amt,
  ROUND((pay_amt - LAG(pay_amt, 1) OVER (PARTITION BY client_id ORDER BY `month` ASC)) * 100 / NULLIF(LAG(pay_amt, 1) OVER (PARTITION BY client_id ORDER BY `month` ASC), 0),2)AS pourcentage_variation,
  DENSE_RANK() OVER (PARTITION BY client_id ORDER BY pay_amt ASC) AS rangs,
  SUM(pay_amt) OVER (PARTITION BY client_id ORDER BY `month` ASC) AS cumul,
  ROUND(AVG(pay_amt) OVER (PARTITION BY client_id ORDER BY `month` ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moyenne_mobile_3mois
FROM payments
ORDER BY client_id, `month`;

-- 8_Scoring de risque client
with retards AS (
SELECT
  client_id,
  SUM(CASE WHEN pay > 0 THEN pay ELSE 0 END) AS nombre_mois_retards,
  (SUM(CASE WHEN pay > 0 THEN pay ELSE 0 END)) / 6.0 AS avg_nombre_mois_retards
FROM repayment_status
GROUP BY client_id
)
SELECT 
  r.client_id,
  CASE
    WHEN avg_nombre_mois_retards = 0 THEN 'risque_minimum'
    WHEN avg_nombre_mois_retards <= 1 THEN 'risque_moyen'
    ELSE 'risque_elevé'
  END AS score_risque
FROM retards r
INNER JOIN default_payments dp ON r.client_id = dp.client_id;



