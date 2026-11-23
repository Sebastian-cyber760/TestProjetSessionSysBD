---- TESTS UNITAIRES DE genre_api (utPLSQL) : SPÉCIFICATION ----
CREATE OR REPLACE PACKAGE genre_api_test AS
  --%suite(genre_api : tests unitaires de l'API de l'entité GENRE)

  /**
   * Tests unitaires de genre_api avec utPLSQL (Leçon 9, diapos 60 à 63), selon le
   * même modèle que jeu_api_test : arrange, act (p_test => 'O'), assert.
   * Une erreur attendue est attrapée dans un sous-bloc (Leçon 7, diapo 32), puis
   * ut.expect vérifie son code. utPLSQL annule tout après chaque test : la base
   * reste inchangée.
   * Proposition de la partie API, à relire et à compléter par le membre de
   * l'équipe responsable de l'entité GENRE.
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   */

  --%test(genre_insert ajoute un genre valide et retourne l'identifiant généré)
  PROCEDURE genre_insert_valide;

  --%test(un nom absent donne l'erreur -20002, statut 400)
  PROCEDURE genre_insert_nom_absent;

  --%test(un identifiant déjà utilisé donne l'erreur -20003, statut 409)
  PROCEDURE genre_insert_id_existant;

  --%test(genre_update change le nom et garde la description - COALESCE)
  PROCEDURE genre_update_valide;

  --%test(modifier un genre inexistant donne l'erreur -20001, statut 404)
  PROCEDURE genre_update_introuvable;

  --%test(genre_delete supprime un genre qui n'est utilisé par aucun jeu)
  PROCEDURE genre_delete_valide;

  --%test(supprimer un genre utilisé par un jeu donne l'erreur -20003, statut 409)
  PROCEDURE genre_delete_utilise;

  --%test(genre_select retourne un genre lu par son identifiant)
  PROCEDURE genre_select_par_id;

  --%test(un genre inexistant donne l'erreur -20001, statut 404)
  PROCEDURE genre_select_introuvable;
END genre_api_test;
/
