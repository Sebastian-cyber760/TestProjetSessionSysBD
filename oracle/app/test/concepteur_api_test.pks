---- TESTS UNITAIRES DE concepteur_api (utPLSQL) : SPÉCIFICATION ----
CREATE OR REPLACE PACKAGE concepteur_api_test AS
  --%suite(concepteur_api : tests unitaires de l'API de l'entité CONCEPTEUR)

  /**
   * Tests unitaires de concepteur_api avec utPLSQL (Leçon 9, diapos 60 à 63), selon
   * le même modèle que jeu_api_test : arrange, act (p_test => 'O'), assert.
   * Une erreur attendue est attrapée dans un sous-bloc (Leçon 7, diapo 32), puis
   * ut.expect vérifie son code. utPLSQL annule tout après chaque test : la base
   * reste inchangée.
   * Proposition de la partie API, à relire et à compléter par le membre de
   * l'équipe responsable de l'entité CONCEPTEUR.
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   */

  --%test(concepteur_insert ajoute un concepteur valide et retourne l'identifiant généré)
  PROCEDURE concepteur_insert_valide;

  --%test(un nom absent donne l'erreur -20002, statut 400)
  PROCEDURE concepteur_insert_nom_absent;

  --%test(un identifiant déjà utilisé donne l'erreur -20003, statut 409)
  PROCEDURE concepteur_insert_id_existant;

  --%test(concepteur_update change le pays et garde le nom - COALESCE)
  PROCEDURE concepteur_update_valide;

  --%test(modifier un concepteur inexistant donne l'erreur -20001, statut 404)
  PROCEDURE concepteur_update_introuvable;

  --%test(concepteur_delete supprime un concepteur lié à aucun jeu)
  PROCEDURE concepteur_delete_valide;

  --%test(supprimer un concepteur lié à un jeu donne l'erreur -20003, statut 409)
  PROCEDURE concepteur_delete_utilise;

  --%test(concepteur_select retourne un concepteur lu par son identifiant)
  PROCEDURE concepteur_select_par_id;

  --%test(un concepteur inexistant donne l'erreur -20001, statut 404)
  PROCEDURE concepteur_select_introuvable;
END concepteur_api_test;
/
