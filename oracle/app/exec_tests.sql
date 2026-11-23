---- EXÉCUTION DES TESTS UNITAIRES (utPLSQL) ----
/*
 * Exécute tous les tests du schéma, soit les 4 suites (une par entité), comme
 * dans le document « Installation et utilisation de utPLSQ-framework » :
 * « Exécuter tous les tests : BEGIN ut.run(); END; » (Leçon 9, diapos 60 à 63).
 * Appelé à la fin de creer_env.sql. Peut aussi être lancé seul, connecté comme
 * GESTIONJEUX : @@exec_tests.sql
 * Dernière ligne attendue : « 44 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s) ».
 */
SET SERVEROUTPUT ON

BEGIN
  ut.run();
END;
/
