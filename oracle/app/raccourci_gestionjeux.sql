---- RACCOURCIS : COMMANDES À EXÉCUTER CONNECTÉ COMME GESTIONJEUX DANS FREEPDB1 ----
/*
 * Équivalent de raccourci_tp1l2.sql dans l'exemple cours.zip (Leçon 9, diapo 65) :
 * créer l'environnement et exécuter les tests. Ce n'est pas un script à lancer
 * d'un bloc : sélectionnez une commande (ou un groupe), puis exécutez-la avec le
 * bouton execute script. Remplacez les chemins par les vôtres.
 */

-- 1. Une seule fois par poste : installer Logger 3.1.1 dans GESTIONJEUX
--    (document « Installation et utilisation de Logger », étapes 4 et 5; les
--    droits de l'étape 3 sont donnés par creer_gestionjeux.sql)
-- À spécifier : le chemin du dossier de Logger (exemple : C:\Users\sebastian\cours3GB\logger_3.1.1)
cd "chemin"
@logger_install.sql
SELECT * FROM logger_logs;

-- 2. Vérifier utPLSQL (document « Installation et utilisation de utPLSQ-framework »,
--    étape 4) et les droits du débogueur (document « Configuration du débogueur »)
SELECT substr(ut.version(),1,60) AS ut_version FROM dual;

SELECT *
  FROM USER_SYS_PRIVS
 WHERE PRIVILEGE LIKE 'DEBUG%';

-- 3. Créer tout l'environnement (tables, données, API, tests) et exécuter les tests.
--    Le fichier resultat.log est écrit dans le dossier oracle/app du projet.
-- À spécifier : le chemin du dossier oracle\app du projet (exemple : C:\Users\sebastian\cours3GB\Projet-session-Groupe-1\oracle\app)
cd "chemin"
@@creer_env.sql

-- 4. Réexécuter seulement les tests unitaires
@@exec_tests.sql

-- 5. Démonstration des appels de l'API (tout est annulé à la fin)
@@exemples_appels_api.sql

-- 6. Les 20 traces Logger les plus récentes
SELECT id, logger_level, scope, text, extra
  FROM logger_logs
 ORDER BY id DESC
 FETCH FIRST 20 ROWS ONLY;
