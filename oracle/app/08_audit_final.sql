---- CONNEXION ----
SELECT USER AS utilisateur, SYS_CONTEXT('USERENV','CON_NAME') AS conteneur FROM dual;

---- TABLES ----
SELECT table_name FROM user_tables
WHERE table_name IN ('GENRE','CONCEPTEUR','PLATEFORME','JEU','JEU_PLATEFORME','UTILISATEUR','DROIT','UTILISATEUR_DROIT','SESSION','DEMANDE_VENDEUR')
ORDER BY table_name;

---- DONNEES ----
SELECT 'GENRE' AS table_nom, COUNT(*) AS total FROM genre
UNION ALL SELECT 'CONCEPTEUR', COUNT(*) FROM concepteur
UNION ALL SELECT 'PLATEFORME', COUNT(*) FROM plateforme
UNION ALL SELECT 'JEU', COUNT(*) FROM jeu
UNION ALL SELECT 'JEU_PLATEFORME', COUNT(*) FROM jeu_plateforme
UNION ALL SELECT 'UTILISATEUR', COUNT(*) FROM utilisateur
UNION ALL SELECT 'DROIT', COUNT(*) FROM droit
UNION ALL SELECT 'UTILISATEUR_DROIT', COUNT(*) FROM utilisateur_droit
UNION ALL SELECT 'SESSION', COUNT(*) FROM "SESSION"
UNION ALL SELECT 'DEMANDE_VENDEUR', COUNT(*) FROM demande_vendeur;

---- CONTRAINTES ----
SELECT table_name, constraint_name, constraint_type, status
FROM user_constraints
WHERE table_name IN ('GENRE','CONCEPTEUR','PLATEFORME','JEU','JEU_PLATEFORME','UTILISATEUR','DROIT','UTILISATEUR_DROIT','SESSION','DEMANDE_VENDEUR')
ORDER BY table_name, constraint_type;

---- PACKAGES ----
SELECT object_name, object_type, status FROM user_objects
WHERE object_type IN ('PACKAGE','PACKAGE BODY')
AND (object_name IN ('LOGGER', 'API_ERREURS') OR object_name LIKE '%_API' OR object_name LIKE '%_API_TEST')
ORDER BY object_name, object_type;

---- ERREURS ----
SELECT name, type, line, position, text FROM user_errors ORDER BY name, sequence;

---- LOGGER ----
SELECT id, logger_level, text FROM logger_logs ORDER BY id DESC FETCH FIRST 20 ROWS ONLY;
