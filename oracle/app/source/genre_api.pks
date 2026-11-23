---- API PL/SQL DE L'ENTITÉ GENRE : SPÉCIFICATION ----
CREATE OR REPLACE PACKAGE genre_api AS
  /**
   * API PL/SQL de l'entité GENRE (architecture SmartDB, Leçon 9).
   * Les genres sont des données de référence : la liste des genres sert au
   * formulaire des CU-06 et CU-07, et le nom du genre est affiché au CU-05.
   *
   *   Fonction     | Appel REST (livrable 4)
   *   genre_insert | POST   /genres
   *   genre_update | PUT    /genres/{id}
   *   genre_delete | DELETE /genres/{id}
   *   genre_select | GET    /genres (paramètres debut et limite)  et  GET /genres/{id}
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

  -- Nombre maximal de genres par page dans genre_select (le JSON retourné doit
  -- tenir dans le VARCHAR2(4000) du squelette de la Leçon 9, diapo 31)
  c_limite_max CONSTANT PLS_INTEGER := 10;

  /**
   * Ajoute un genre et retourne son identifiant.
   * Si p_id_genre est NULL, la BD assigne l'identifiant (colonne identité).
   *
   * @example l_id_genre := genre_api.genre_insert(p_nom_genre => 'Course', p_description => 'Jeux de course');
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_id_genre: identifiant voulu (facultatif, NULL = assigné par la BD)
   * @param p_nom_genre: nom du genre (obligatoire, 50 caractères au maximum)
   * @param p_description: description du genre (facultative, 255 caractères au maximum)
   * @param p_test: paramètre pour ne pas sauvegarder les tests, si 'N' alors commit
   * @return id_genre: la clé primaire du genre créé
   * @throws -20002 (400) nom absent, identifiant invalide ou texte trop long
   * @throws -20003 (409) l'identifiant p_id_genre est déjà utilisé
   */
  FUNCTION genre_insert (
    p_id_genre    IN genre.id_genre%TYPE    DEFAULT NULL,
    p_nom_genre   IN genre.nom_genre%TYPE   DEFAULT NULL,
    p_description IN genre.description%TYPE DEFAULT NULL,
    p_test        IN VARCHAR2               DEFAULT 'N'
  ) RETURN NUMBER;

  /**
   * Modifie un genre existant. Un paramètre NULL garde la valeur actuelle (COALESCE).
   *
   * @example l_nbre := genre_api.genre_update(p_id_genre => 3, p_nom_genre => 'Sports');
   *
   * @issue Avec COALESCE, on ne peut pas remettre la description à NULL.
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_id_genre: identifiant du genre à modifier (obligatoire)
   * @param p_nom_genre: nouveau nom (NULL = inchangé)
   * @param p_description: nouvelle description (NULL = inchangée)
   * @param p_test: paramètre pour ne pas sauvegarder les tests, si 'N' alors commit
   * @return nbre_rangees: le nombre de rangées modifiées (1)
   * @throws -20001 (404) le genre n'existe pas
   * @throws -20002 (400) identifiant invalide ou texte trop long
   */
  FUNCTION genre_update (
    p_id_genre    IN genre.id_genre%TYPE    DEFAULT NULL,
    p_nom_genre   IN genre.nom_genre%TYPE   DEFAULT NULL,
    p_description IN genre.description%TYPE DEFAULT NULL,
    p_test        IN VARCHAR2               DEFAULT 'N'
  ) RETURN NUMBER;

  /**
   * Supprime un genre qui n'est utilisé par aucun jeu.
   *
   * @example l_nbre := genre_api.genre_delete(p_id_genre => 4);
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_id_genre: identifiant du genre à supprimer (obligatoire)
   * @param p_test: paramètre pour ne pas sauvegarder les tests, si 'N' alors commit
   * @return nbre_rangees: le nombre de genres supprimés (1)
   * @throws -20001 (404) le genre n'existe pas
   * @throws -20002 (400) identifiant absent ou invalide
   * @throws -20003 (409) au moins un jeu utilise encore ce genre
   */
  FUNCTION genre_delete (
    p_id_genre IN genre.id_genre%TYPE DEFAULT NULL,
    p_test     IN VARCHAR2            DEFAULT 'N'
  ) RETURN NUMBER;

  /**
   * Retourne un objet JSON avec une page de genres ou un seul genre, triés par identifiant.
   * Format : {"limite":5,"debut":0,"taille":4,"resultats":[{"ID_GENRE":1,"NOM_GENRE":"Action",...},...]}
   * Une page vide donne "taille":0 et "resultats":null (squelette de la
   * Leçon 9, diapos 31 et 32).
   *
   * @example SELECT genre_api.genre_select(p_id_genre => 1) FROM dual;
   *
   * @issue Le JSON retourné doit tenir dans 4000 octets (VARCHAR2(4000) du squelette de
   *        la Leçon 9, diapo 31) : une page de genres aux longues descriptions peut
   *        dépasser cette taille.
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_id_genre: identifiant du genre (NULL = tous les genres, page par page)
   * @param p_debut: position de départ de la page (0 par défaut, ignorée si p_id_genre est fourni)
   * @param p_limite: nombre maximal de genres dans la page (5 par défaut, de 1 à c_limite_max)
   * @return json: l'objet JSON {limite, debut, taille, resultats}
   * @throws -20001 (404) aucun genre ne porte l'identifiant p_id_genre
   * @throws -20002 (400) identifiant, début ou limite invalide
   */
  FUNCTION genre_select (
    p_id_genre IN genre.id_genre%TYPE DEFAULT NULL,
    p_debut    IN PLS_INTEGER         DEFAULT 0,
    p_limite   IN PLS_INTEGER         DEFAULT 5
  ) RETURN VARCHAR2;
END genre_api;
/
