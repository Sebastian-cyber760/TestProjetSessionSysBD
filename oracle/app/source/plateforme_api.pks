---- API PL/SQL DE L'ENTITÉ PLATEFORME : SPÉCIFICATION ----
CREATE OR REPLACE PACKAGE plateforme_api AS
  /**
   * API PL/SQL de l'entité PLATEFORME (architecture SmartDB, Leçon 9).
   * Les plateformes sont des données de référence : les plateformes d'un jeu sont
   * affichées dans sa fiche détaillée (CU-05).
   *
   *   Fonction          | Appel REST (livrable 4)
   *   plateforme_insert | POST   /plateformes
   *   plateforme_update | PUT    /plateformes/{id}
   *   plateforme_delete | DELETE /plateformes/{id}
   *   plateforme_select | GET    /plateformes (paramètres debut et limite)  et  GET /plateformes/{id}
   *
   * Transactions (Leçon 9, diapos 33 à 39) : si p_test vaut 'N' (valeur par défaut),
   * la fonction confirme son travail (COMMIT) ou, en cas d'erreur, l'annule (ROLLBACK).
   * Avec une autre valeur (tests unitaires), elle ne fait ni COMMIT ni ROLLBACK.
   * Une erreur est journalisée avec Logger, puis relancée avec un code du package
   * api_erreurs (-20001 = 404, -20002 = 400, -20003 = 409).
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   */

  -- Nombre maximal de plateformes par page dans plateforme_select (le JSON retourné doit
  -- tenir dans le VARCHAR2(4000) du squelette de la Leçon 9, diapo 31)
  c_limite_max CONSTANT PLS_INTEGER := 10;

  /**
   * Ajoute une plateforme et retourne son identifiant.
   * Si p_id_plateforme est NULL, la BD assigne l'identifiant (colonne identité).
   *
   * @example l_id := plateforme_api.plateforme_insert(p_nom_plateforme => 'Nintendo Switch 2');
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_id_plateforme: identifiant voulu (facultatif, NULL = assigné par la BD)
   * @param p_nom_plateforme: nom de la plateforme (obligatoire, 50 caractères au maximum)
   * @param p_test: paramètre pour ne pas sauvegarder les tests, si 'N' alors commit
   * @return id_plateforme: la clé primaire de la plateforme créée
   * @throws -20002 (400) nom absent, identifiant invalide ou nom trop long
   * @throws -20003 (409) l'identifiant p_id_plateforme est déjà utilisé
   */
  FUNCTION plateforme_insert (
    p_id_plateforme  IN plateforme.id_plateforme%TYPE  DEFAULT NULL,
    p_nom_plateforme IN plateforme.nom_plateforme%TYPE DEFAULT NULL,
    p_test           IN VARCHAR2                       DEFAULT 'N'
  ) RETURN NUMBER;

  /**
   * Modifie le nom d'une plateforme existante. Un nom NULL garde la valeur actuelle (COALESCE).
   *
   * @example l_nbre := plateforme_api.plateforme_update(p_id_plateforme => 4, p_nom_plateforme => 'PC (Windows)');
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_id_plateforme: identifiant de la plateforme à modifier (obligatoire)
   * @param p_nom_plateforme: nouveau nom (NULL = inchangé)
   * @param p_test: paramètre pour ne pas sauvegarder les tests, si 'N' alors commit
   * @return nbre_rangees: le nombre de rangées modifiées (1)
   * @throws -20001 (404) la plateforme n'existe pas
   * @throws -20002 (400) identifiant invalide ou nom trop long
   */
  FUNCTION plateforme_update (
    p_id_plateforme  IN plateforme.id_plateforme%TYPE  DEFAULT NULL,
    p_nom_plateforme IN plateforme.nom_plateforme%TYPE DEFAULT NULL,
    p_test           IN VARCHAR2                       DEFAULT 'N'
  ) RETURN NUMBER;

  /**
   * Supprime une plateforme qui n'est associée à aucun jeu.
   *
   * @example l_nbre := plateforme_api.plateforme_delete(p_id_plateforme => 4);
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_id_plateforme: identifiant de la plateforme à supprimer (obligatoire)
   * @param p_test: paramètre pour ne pas sauvegarder les tests, si 'N' alors commit
   * @return nbre_rangees: le nombre de plateformes supprimées (1)
   * @throws -20001 (404) la plateforme n'existe pas
   * @throws -20002 (400) identifiant absent ou invalide
   * @throws -20003 (409) au moins un jeu est encore associé à cette plateforme
   */
  FUNCTION plateforme_delete (
    p_id_plateforme IN plateforme.id_plateforme%TYPE DEFAULT NULL,
    p_test          IN VARCHAR2                      DEFAULT 'N'
  ) RETURN NUMBER;

  /**
   * Retourne un objet JSON avec une page de plateformes ou une seule plateforme,
   * triées par identifiant.
   * Format : {"limite":5,"debut":0,"taille":4,"resultats":[{"ID_PLATEFORME":1,...},...]}
   * Une page vide donne "taille":0 et "resultats":null (squelette de la
   * Leçon 9, diapos 31 et 32).
   *
   * @example SELECT plateforme_api.plateforme_select(p_id_plateforme => 1) FROM dual;
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_id_plateforme: identifiant de la plateforme (NULL = toutes, page par page)
   * @param p_debut: position de départ de la page (0 par défaut, ignorée si p_id_plateforme est fourni)
   * @param p_limite: nombre maximal de plateformes dans la page (5 par défaut, de 1 à c_limite_max)
   * @return json: l'objet JSON {limite, debut, taille, resultats}
   * @throws -20001 (404) aucune plateforme ne porte l'identifiant p_id_plateforme
   * @throws -20002 (400) identifiant, début ou limite invalide
   */
  FUNCTION plateforme_select (
    p_id_plateforme IN plateforme.id_plateforme%TYPE DEFAULT NULL,
    p_debut         IN PLS_INTEGER                   DEFAULT 0,
    p_limite        IN PLS_INTEGER                   DEFAULT 5
  ) RETURN VARCHAR2;
END plateforme_api;
/
