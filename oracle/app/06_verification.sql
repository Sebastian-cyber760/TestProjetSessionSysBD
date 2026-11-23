---- VERIFICATION DES DONNEES ----
SELECT 'GENRE' AS table_nom, COUNT(*) AS total FROM genre
UNION ALL
SELECT 'CONCEPTEUR' AS table_nom, COUNT(*) AS total FROM concepteur
UNION ALL
SELECT 'PLATEFORME' AS table_nom, COUNT(*) AS total FROM plateforme
UNION ALL
SELECT 'JEU' AS table_nom, COUNT(*) AS total FROM jeu
UNION ALL
SELECT 'JEU_PLATEFORME' AS table_nom, COUNT(*) AS total FROM jeu_plateforme
UNION ALL
SELECT 'UTILISATEUR' AS table_nom, COUNT(*) AS total FROM utilisateur
UNION ALL
SELECT 'DROIT' AS table_nom, COUNT(*) AS total FROM droit
UNION ALL
SELECT 'UTILISATEUR_DROIT' AS table_nom, COUNT(*) AS total FROM utilisateur_droit
UNION ALL
SELECT 'SESSION' AS table_nom, COUNT(*) AS total FROM "SESSION"
UNION ALL
SELECT 'DEMANDE_VENDEUR' AS table_nom, COUNT(*) AS total FROM demande_vendeur;
