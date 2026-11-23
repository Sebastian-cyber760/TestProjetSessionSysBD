---- CODES D'ERREUR COMMUNS AUX QUATRE PACKAGES D'API (SPÉCIFICATION SEULEMENT) ----
CREATE OR REPLACE PACKAGE api_erreurs AS
  /**
   * Codes d'erreur communs aux quatre packages d'API : genre_api, concepteur_api,
   * plateforme_api et jeu_api. Ce package n'a pas de corps : il contient seulement
   * des constantes et des exceptions nommées.
   *
   * Une fonction de l'API lève une erreur d'affaires avec RAISE_APPLICATION_ERROR
   * et un de ces codes. Le serveur Node.js (livrable 4) lit le numéro de l'erreur
   * et répond avec le statut HTTP correspondant (codes HTTP de la Leçon 10, diapo 40) :
   *
   *   Code Oracle | Constante         | Statut HTTP     | Exemples
   *   -20001      | c_introuvable     | 404 Not Found   | jeu, genre, concepteur ou plateforme inexistant
   *   -20002      | c_donnee_invalide | 400 Bad Request | titre vide, prix négatif, genre inexistant
   *   -20003      | c_conflit         | 409 Conflict    | identifiant déjà utilisé, genre encore utilisé
   *   autre       | (erreur imprévue) | 500             | erreur d'Oracle non prévue
   *
   * Chaque code a aussi une exception nommée (PRAGMA EXCEPTION_INIT, leçon 7) :
   * on écrit « WHEN api_erreurs.e_introuvable THEN » plutôt que de tester SQLCODE.
   *
   * @example RAISE_APPLICATION_ERROR(api_erreurs.c_introuvable, 'Le jeu 99 est introuvable.');
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   */

  -- Codes des erreurs d'affaires (plage réservée de -20000 à -20999, leçon 7)
  c_introuvable     CONSTANT PLS_INTEGER := -20001;  -- HTTP 404
  c_donnee_invalide CONSTANT PLS_INTEGER := -20002;  -- HTTP 400
  c_conflit         CONSTANT PLS_INTEGER := -20003;  -- HTTP 409

  -- Exceptions nommées associées à ces codes
  e_introuvable EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_introuvable, -20001);

  e_donnee_invalide EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_donnee_invalide, -20002);

  e_conflit EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_conflit, -20003);

  -- Erreurs d'Oracle sans nom prédéfini, nommées pour la validation réactive (leçon 7)
  e_valeur_null_non_permise EXCEPTION;  -- ORA-01400 : NULL dans une colonne obligatoire
  PRAGMA EXCEPTION_INIT(e_valeur_null_non_permise, -1400);

  e_parent_introuvable EXCEPTION;       -- ORA-02291 : la clé étrangère vise une rangée inexistante
  PRAGMA EXCEPTION_INIT(e_parent_introuvable, -2291);

  e_enfants_existants EXCEPTION;        -- ORA-02292 : d'autres rangées utilisent encore cette rangée
  PRAGMA EXCEPTION_INIT(e_enfants_existants, -2292);

  e_valeur_trop_grande EXCEPTION;       -- ORA-12899 : texte trop long pour la colonne
  PRAGMA EXCEPTION_INIT(e_valeur_trop_grande, -12899);
END api_erreurs;
/
