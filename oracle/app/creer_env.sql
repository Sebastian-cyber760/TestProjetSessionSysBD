---- CRÉATION DE L'ENVIRONNEMENT DU PROJET GESTIONJEUX ----
/*
 * Script qui appelle tous les autres scripts, dans l'ordre (structure de
 * l'exemple cours.zip, Leçon 9, diapo 65). Il doit être lancé avec @@ :
 *   cd "<dossier oracle/app du projet>"
 *   @@creer_env.sql
 * À exécuter connecté comme GESTIONJEUX (jamais comme SYS). Il peut être relancé :
 * il commence par supprimer les objets du projet (Logger est conservé).
 * Tout ce qu'il affiche est aussi écrit dans resultat.log (Leçon 9, diapo 65).
 * Prérequis (une fois par poste) :
 *   - utPLSQL installé comme SYS dans FREEPDB1 (document « Installation et
 *     utilisation de utPLSQ-framework », voir raccourci_sys.sql);
 *   - creer_gestionjeux.sql exécuté comme SYS (voir raccourci_sys.sql);
 *   - Logger 3.1.1 installé dans GESTIONJEUX (document « Installation et
 *     utilisation de Logger », voir raccourci_gestionjeux.sql).
 */
SET SERVEROUTPUT ON
SPOOL resultat.log

---- 0. Prérequis : Logger (rangées LOGGER, statut VALID) et utPLSQL (version affichée) ----
SELECT object_name, object_type, status
  FROM user_objects
 WHERE object_type IN ('PACKAGE', 'PACKAGE BODY')
   AND object_name = 'LOGGER'
 ORDER BY object_name, object_type;

SELECT substr(ut.version(),1,60) AS ut_version FROM dual;

---- 1. Suppression des objets du projet (Logger est conservé) ----
@@supprimer_objets.sql

---- 2. Tables ----
@@01_creation.sql

---- 3. Données initiales ----
@@02_peuplement.sql

---- 4. Packages de l'API (répertoire source) ----
@@source/api_erreurs.pks
@@source/genre_api.pks
@@source/genre_api.pkb
@@source/concepteur_api.pks
@@source/concepteur_api.pkb
@@source/plateforme_api.pks
@@source/plateforme_api.pkb
@@source/jeu_api.pks
@@source/jeu_api.pkb

---- 5. Packages de tests unitaires (répertoire test) ----
@@test/genre_api_test.pks
@@test/genre_api_test.pkb
@@test/concepteur_api_test.pks
@@test/concepteur_api_test.pkb
@@test/plateforme_api_test.pks
@@test/plateforme_api_test.pkb
@@test/jeu_api_test.pks
@@test/jeu_api_test.pkb

---- 6. Packages (statut VALID attendu) et erreurs de compilation (aucune rangée attendue) ----
-- Mêmes requêtes que 08_audit_final.sql de l'équipe.
SELECT object_name, object_type, status
  FROM user_objects
 WHERE object_type IN ('PACKAGE', 'PACKAGE BODY')
   AND (object_name IN ('LOGGER', 'API_ERREURS') OR object_name LIKE '%_API' OR object_name LIKE '%_API_TEST')
 ORDER BY object_name, object_type;

SELECT name, type, line, position, text FROM user_errors ORDER BY name, sequence;

---- 7. Tests unitaires ----
@@exec_tests.sql

SPOOL OFF
