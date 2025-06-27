# 💳 Credit Card Default – Projet SQL complet

Ce projet SQL repose sur le dataset **[Credit Card Clients](https://www.kaggle.com/datasets/farahananda/credit-card-clients-data)** pour modéliser une base de données relationnelle, importer les données, effectuer des contrôles qualité et produire des analyses client & scoring de risque.

## 🗃️ Objectifs

- Modéliser une base de données relationnelle pour gérer les données de clients de cartes de crédit
- Charger et normaliser les données depuis une table brute
- Vérifier la qualité, la cohérence et la complétude des données
- Créer des vues et requêtes analytiques sur le comportement client
- Réaliser un **scoring de risque de défaut de paiement**

## 📐 1. Modélisation des tables

Les données sont réparties en 6 tables principales :

- `clients` : Informations personnelles (sexe, âge, éducation, etc.)
- `credit_limits` : Limite de crédit autorisée
- `repayment_status` : Historique des retards de paiement (sur 6 mois)
- `bill_statements` : Montants facturés chaque mois
- `payments` : Montants payés chaque mois
- `default_payments` : Statut de défaut de paiement pour le mois suivant

## 🔄 2. Chargement des données

Les données sont extraites depuis la table brute `credit_card_data` puis insérées dans les tables relationnelles avec :

- Casting des types (`DECIMAL`, `VARCHAR`, etc.)
- Normalisation mensuelle des colonnes temporelles (`PAY_0`, `BILL_AMT1`, etc.)

## ✅ 3. Contrôles qualité

Des contrôles sont effectués pour garantir l’intégrité des données :

- Comptage total des enregistrements par table
- Détection de valeurs `NULL` dans les colonnes critiques
- Recherche de doublons `(client_id, month)` dans la table `payments`

## 🔍 4. Vue analytique

Une vue `v_client_plafond_defaut` regroupe les informations clés :

- Informations client
- Plafond de crédit
- Statut de défaut

## 📊 5. Analyses démographiques

- Âge moyen par sexe
- Taux de défaut par tranche d’âge :
  - Moins de 25 ans
  - 25–34 ans
  - 35–50 ans
  - 51–65 ans
  - Plus de 65 ans

## 💸 6. Écarts de paiement

Écart cumulé entre les montants facturés et payés sur 6 mois, client par client.

## 📈 7. Analyse temporelle des paiements

- Variation mensuelle des paiements
- Classement par montant (`DENSE_RANK`)
- Cumul des paiements
- Moyenne mobile sur 3 mois

## ⚠️ 8. Scoring de risque

Chaque client reçoit un score de risque selon la moyenne de ses retards :

| Moyenne de retards (6 mois) | Score de risque     |
|-----------------------------|---------------------|
| 0                           | risque_minimum      |
| ≤ 1                         | risque_moyen        |
| > 1                         | risque_élevé        |

## 📁 Fichier inclus

- `credit_card_default_model.sql` : script SQL complet avec création des tables, insertion, contrôles qualité, vues et analyses.

## 🧠 Dataset utilisé

📎 [Credit Card Clients – Kaggle](https://www.kaggle.com/datasets/farahananda/credit-card-clients-data)

## 🛠️ Prérequis

- SGBD : MySQL 8.x ou compatible
- Table brute `credit_card_data` chargée au préalable

---

Projet réalisé à des fins d’apprentissage et de démonstration de compétences SQL avancées (modélisation, ETL, analyse métier).
