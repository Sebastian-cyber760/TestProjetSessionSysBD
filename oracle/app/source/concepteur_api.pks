---- API PL/SQL DE L'ENTITÉ CONCEPTEUR : SPÉCIFICATION ----
CREATE OR REPLACE PACKAGE concepteur_api AS
  /**
   * API PL/SQL de l'entité CONCEPTEUR (architecture SmartDB, Leçon 9).
   * Les concepteurs sont des données de référence : la liste des concepteurs sert
   * au formulaire des CU-06 et CU-07, et le nom du concepteur est affiché au CU-05.
   *
   *   Fonction          | Appel REST (livrable 4)
   *   concepteur_insert | POST   /concepteurs
   *   concepteur_update | PUT    /concepteurs/{id}
   *   concepteur_delete | DELETE /concepteurs/{id}
   *   concepteur_select | GET    /concepteurs (paramètres debut et limite)  et  GET /concepteurs/{id}
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

  -- Nombre maximal de concepteurs par page dans concepteur_select (le JSON retourné doit
  -- tenir dans le VARCHAR2(4000) du squelette de la Leçon 9, diapo 31)
  c_limite_max CONSTANT PLS_INTEGER := 10;

  /**
   * Ajoute un concepteur et retourne son identifiant.
   * Si p_id_concepteur est NULL, la BD assigne l'identifiant (colonne identité).
   *
   * @example l_id := concepteur_api.concepteur_insert(p_nom_concepteur => 'Capcom', p_pays => 'Japon');
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_id_concepteur: identifiant voulu (facultatif, NULL = assigné par la BD)
   * @param p_nom_concepteur: nom du concepteur (obligatoire, 100 caractères au maximum)
   * @param p_pays: pays du concepteur (facultatif, 500 caractères au maximum)
   * @param p_test: paramètre pour ne pas sauvegarder les tests, si 'N' alors commit
   * @return id_concepteur: la clé primaire du concepteur créé
   * @throws -20002 (400) nom absent, identifiant invalide ou texte trop long
   * @throws -20003 (409) l'identifiant p_id_concepteur est déjà utilisé
   */
  FUNCTION concepteur_insert (
    p_id_concepteur  IN concepteur.id_concepteur%TYPE  DEFAULT NULL,
    p_nom_concepteur IN concepteur.nom_concepteur%TYPE DEFAULT NULL,
    p_pays           IN concepteur.pays%TYPE           DEFAULT NULL,
    p_test           IN VARCHAR2                       DEFAULT 'N'
  ) RETURN NUMBER;

  /**
   * Modifie un concepteur existant. Un paramètre NULL garde la valeur actuelle (COALESCE).
   *
   * @example l_nbre := concepteur_api.concepteur_update(p_id_concepteur => 2, p_pays => 'Canada');
   *
   * @issue Avec COALESCE, on ne peut pas remettre le pays à NULL.
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_id_concepteur: identifiant du concepteur à modifier (obligatoire)
   * @param p_nom_concepteur: nouveau nom (NULL = inchangé)
   * @param p_pays: nouveau pays (NULL = inchangé)
   * @param p_test: paramètre pour ne pas sauvegarder les tests, si 'N' alors commit
   * @return nbre_rangees: le nombre de rangées modifiées (1)
   * @throws -20001 (404) le concepteur n'existe pas
   * @throws -20002 (400) identifiant invalide ou texte trop long
   */
  FUNCTION concepteur_update (
    p_id_concepteur  IN concepteur.id_concepteur%TYPE  DEFAULT NULL,
    p_nom_concepteur IN concepteur.nom_concepteur%TYPE DEFAULT NULL,
    p_pays           IN concepteur.pays%TYPE           DEFAULT NULL,
    p_test           IN VARCHAR2                       DEFAULT 'N'
  ) RETURN NUMBER;

  /**
   * Supprime un concepteur qui n'est lié à aucun jeu.
   *
   * @example l_nbre := concepteur_api.concepteur_delete(p_id_concepteur => 4);
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_id_concepteur: identifiant du concepteur à supprimer (obligatoire)
   * @param p_test: paramètre pour ne pas sauvegarder les tests, si 'N' alors commit
   * @return nbre_rangees: le nombre de concepteurs supprimés (1)
   * @throws -20001 (404) le concepteur n'existe pas
   * @throws -20002 (400) identifiant absent ou invalide
   * @throws -20003 (409) au moins un jeu est encore lié à ce concepteur
   */
  FUNCTION concepteur_delete (
    p_id_concepteur IN concepteur.id_concepteur%TYPE DEFAULT NULL,
    p_test          IN VARCHAR2                      DEFAULT 'N'
  ) RETURN NUMBER;

  /**
   * Retourne un objet JSON avec une page de concepteurs ou un seul concepteur,
   * triés par identifiant.
   * Format : {"limite":5,"debut":0,"taille":4,"resultats":[{"ID_CONCEPTEUR":1,...},...]}
   * Une page vide donne "taille":0 et "resultats":null (squelette de la
   * Leçon 9, diapos 31 et 32).
   *
   * @example SELECT concepteur_api.concepteur_select(p_id_concepteur => 1) FROM dual;
   *
   * @issue Le JSON retourné doit tenir dans 4000 octets (VARCHAR2(4000) du squelette de
   *        la Leçon 9, diapo 31) : une page de concepteurs aux longues descriptions peut
   *        dépasser cette taille.
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_id_concepteur: identifiant du concepteur (NULL = tous, page par page)
   * @param p_debut: position de départ de la page (0 par défaut, ignorée si p_id_concepteur est fourni)
   * @param p_limite: nombre maximal de concepteurs dans la page (5 par défaut, de 1 à c_limite_max)
   * @return json: l'objet JSON {limite, debut, taille, resultats}
   * @throws -20001 (404) aucun concepteur ne porte l'identifiant p_id_concepteur
   * @throws -20002 (400) identifiant, début ou limite invalide
   */
  FUNCTION concepteur_select (
    p_id_concepteur IN concepteur.id_concepteur%TYPE DEFAULT NULL,
    p_debut         IN PLS_INTEGER                   DEFAULT 0,
    p_limite        IN PLS_INTEGER                   DEFAULT 5
  ) RETURN VARCHAR2;
END concepteur_api;
/
