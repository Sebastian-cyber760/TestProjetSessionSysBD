---- TESTS UNITAIRES DE plateforme_api (utPLSQL) : SPÉCIFICATION ----
CREATE OR REPLACE PACKAGE plateforme_api_test AS
  --%suite(plateforme_api : tests unitaires de l'API de l'entité PLATEFORME)

  /**
   * Tests unitaires de plateforme_api avec utPLSQL (Leçon 9, diapos 60 à 63), selon
   * le même modèle que jeu_api_test : arrange, act (p_test => 'O'), assert.
   * Une erreur attendue est attrapée dans un sous-bloc (Leçon 7, diapo 32), puis
   * ut.expect vérifie son code. utPLSQL annule tout après chaque test : la base
   * reste inchangée.
   * Proposition de la partie API, à relire et à compléter par le membre de
   * l'équipe responsable de l'entité PLATEFORME.
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   */

  --%test(plateforme_insert ajoute une plateforme valide et retourne l'identifiant généré)
  PROCEDURE plateforme_insert_valide;

  --%test(un nom absent donne l'erreur -20002, statut 400)
  PROCEDURE plateforme_insert_nom_absent;

  --%test(un identifiant déjà utilisé donne l'erreur -20003, statut 409)
  PROCEDURE plateforme_insert_id_existant;

  --%test(plateforme_update change le nom de la plateforme)
  PROCEDURE plateforme_update_valide;

  --%test(modifier une plateforme inexistante donne l'erreur -20001, statut 404)
  PROCEDURE plateforme_update_introuvable;

  --%test(plateforme_delete supprime une plateforme associée à aucun jeu)
  PROCEDURE plateforme_delete_valide;

  --%test(supprimer une plateforme associée à un jeu donne l'erreur -20003, statut 409)
  PROCEDURE plateforme_delete_associee;

  --%test(plateforme_select retourne une plateforme lue par son identifiant)
  PROCEDURE plateforme_select_par_id;

  --%test(une plateforme inexistante donne l'erreur -20001, statut 404)
  PROCEDURE plateforme_select_introuvable;
END plateforme_api_test;
/
