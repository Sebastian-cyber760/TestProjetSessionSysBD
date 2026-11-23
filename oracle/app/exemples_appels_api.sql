---- EXEMPLES D'APPELS DE L'API PL/SQL (DÉMONSTRATION) ----
/*
 * À exécuter connecté comme GESTIONJEUX, avec le bouton execute script, après
 * creer_env.sql. Chaque appel correspond à une route REST que le serveur Node.js
 * appellera.
 * Les fonctions _select sont appelées dans un SELECT ... FROM dual. Les fonctions
 * qui modifient des données sont appelées dans un bloc anonyme, qui affiche le
 * résultat avec DBMS_OUTPUT.PUT_LINE (Leçon 9, diapo 21).
 * Les étapes 5 à 13 passent p_test => 'O' : l'API ne fait ni COMMIT ni ROLLBACK,
 * et le ROLLBACK de l'étape 14 annule toute la démonstration.
 * L'étape 15 montre le vrai comportement SmartDB (COMMIT fait par l'API), puis
 * remet la base dans son état de départ.
 * Les appels marqués « ERREUR ATTENDUE » doivent afficher ORA-20001, ORA-20002
 * ou ORA-20003 : c'est le comportement voulu (404, 400 ou 409).
 *
 * @author Sebastian Sanchez Gonzalez
 * @created 2026-11-01
 */
SET SERVEROUTPUT ON

---- 1. CU-03 : première page de la liste des jeux (GET /jeux, debut 0, limite 5) ----
SELECT jeu_api.jeu_select(p_debut => 0, p_limite => 5) AS jeux FROM dual;

---- 2. CU-03 : page de 2 jeux à partir du 3e (GET /jeux, debut 2, limite 2) ----
SELECT jeu_api.jeu_select(p_debut => 2, p_limite => 2) AS jeux FROM dual;

---- 3. CU-04 et CU-05 : fiche détaillée du jeu 1 (GET /jeux/1) ----
SELECT jeu_api.jeu_select(p_id_jeu => 1) AS jeu FROM dual;

---- 4. Listes du formulaire « Ajouter un jeu » (GET /genres et GET /concepteurs) ----
SELECT genre_api.genre_select(p_limite => 10) AS genres FROM dual;
SELECT concepteur_api.concepteur_select(p_limite => 10) AS concepteurs FROM dual;

---- 5 et 6. CU-06 : ajouter un jeu sans identifiant, la BD l'assigne (POST /jeux);
----         CU-07 : changer seulement son prix (PUT /jeux/{id}) ----
DECLARE
  l_id_jeu jeu.id_jeu%TYPE;
  l_nbre   NUMBER;
BEGIN
  l_id_jeu := jeu_api.jeu_insert(
                p_titre                    => 'The Legend of Zelda: Tears of the Kingdom',
                p_description              => 'Aventure dans le royaume d''Hyrule',
                p_date_sortie              => DATE '2023-05-12',
                p_prix                     => 89.99,
                p_genre_id_genre           => 2,
                p_concepteur_id_concepteur => 3,
                p_test                     => 'O');
  DBMS_OUTPUT.PUT_LINE('Jeu ajouté : ' || l_id_jeu);

  l_nbre := jeu_api.jeu_update(p_id_jeu => l_id_jeu, p_prix => 79.99, p_test => 'O');
  DBMS_OUTPUT.PUT_LINE('Jeux modifiés : ' || l_nbre);
  DBMS_OUTPUT.PUT_LINE(jeu_api.jeu_select(p_id_jeu => l_id_jeu));
END;
/

---- 7. ERREUR ATTENDUE ORA-20001 (404) : jeu inexistant (GET /jeux/999) ----
SELECT jeu_api.jeu_select(p_id_jeu => 999) AS jeu FROM dual;

---- 8. ERREUR ATTENDUE ORA-20002 (400) : identifiant invalide (GET /jeux/0) ----
SELECT jeu_api.jeu_select(p_id_jeu => 0) AS jeu FROM dual;

---- 9. ERREUR ATTENDUE ORA-20002 (400) : prix négatif (PUT /jeux/1) ----
DECLARE
  l_nbre NUMBER;
BEGIN
  l_nbre := jeu_api.jeu_update(p_id_jeu => 1, p_prix => -1, p_test => 'O');
END;
/

---- 10. ERREUR ATTENDUE ORA-20002 (400) : genre 99 inexistant (POST /jeux) ----
DECLARE
  l_id_jeu jeu.id_jeu%TYPE;
BEGIN
  l_id_jeu := jeu_api.jeu_insert(p_titre => 'Jeu sans genre', p_prix => 10,
                                 p_genre_id_genre => 99, p_concepteur_id_concepteur => 3,
                                 p_test => 'O');
END;
/

---- 11. ERREUR ATTENDUE ORA-20003 (409) : identifiant 1 déjà utilisé (POST /jeux) ----
DECLARE
  l_id_jeu jeu.id_jeu%TYPE;
BEGIN
  l_id_jeu := jeu_api.jeu_insert(p_id_jeu => 1, p_titre => 'Doublon', p_prix => 10,
                                 p_genre_id_genre => 1, p_concepteur_id_concepteur => 1,
                                 p_test => 'O');
END;
/

---- 12. ERREUR ATTENDUE ORA-20003 (409) : le genre 1 est utilisé par un jeu (DELETE /genres/1) ----
DECLARE
  l_nbre NUMBER;
BEGIN
  l_nbre := genre_api.genre_delete(p_id_genre => 1, p_test => 'O');
END;
/

---- 13. CU-08 : supprimer le jeu 1 et ses plateformes (DELETE /jeux/1) ----
DECLARE
  l_nbre NUMBER;
BEGIN
  l_nbre := jeu_api.jeu_delete(p_id_jeu => 1, p_test => 'O');
  DBMS_OUTPUT.PUT_LINE('Jeux supprimés : ' || l_nbre);
END;
/
SELECT COUNT(*) AS liens_restants FROM jeu_plateforme WHERE jeu_id_jeu = 1;

---- 14. Annuler les étapes 5 à 13 (aucun COMMIT n'a été fait avec p_test => 'O') ----
ROLLBACK;
SELECT COUNT(*) AS nb_jeux_apres_rollback FROM jeu;

---- 15. SmartDB : avec p_test = 'N' (valeur par défaut), l'API confirme elle-même ----
DECLARE
  l_id_jeu jeu.id_jeu%TYPE;
  l_nbre   NUMBER;
  l_compte NUMBER;
BEGIN
  l_id_jeu := jeu_api.jeu_insert(p_titre => 'Jeu confirmé par l''API', p_prix => 5,
                                 p_genre_id_genre => 1, p_concepteur_id_concepteur => 1);
  ROLLBACK;

  -- Le jeu est toujours là : un ROLLBACK n'annule pas un COMMIT déjà fait par l'API.
  SELECT COUNT(*)
    INTO l_compte
    FROM jeu
   WHERE id_jeu = l_id_jeu;
  DBMS_OUTPUT.PUT_LINE('Jeu ' || l_id_jeu || ' encore présent après le ROLLBACK : ' || l_compte);

  -- Retour à l'état de départ : l'API supprime le jeu et confirme (p_test = 'N').
  l_nbre := jeu_api.jeu_delete(p_id_jeu => l_id_jeu);
  DBMS_OUTPUT.PUT_LINE('Jeux supprimés : ' || l_nbre);
END;
/
SELECT COUNT(*) AS nb_jeux FROM jeu;

---- 16. Traces Logger de jeu_api (les plus récentes en premier) ----
SELECT id, logger_level, scope, text, extra
  FROM logger_logs
 WHERE scope LIKE 'jeu_api.%'
 ORDER BY id DESC
 FETCH FIRST 20 ROWS ONLY;
