---- API PL/SQL DE L'ENTITÉ GENRE : CORPS ----
CREATE OR REPLACE PACKAGE BODY genre_api AS
  -- Préfixe de la portée Logger : « genre_api. » (gabarit Logger du cours)
  gc_scope_prefix CONSTANT VARCHAR2(31) := LOWER($$plsql_unit) || '.';
  -- Valeur de p_test qui confirme la transaction (gabarit Javadoc : « si 'N' alors commit »)
  c_confirmer CONSTANT VARCHAR2(1) := 'N';

  /**
   * Vérifie l'identifiant d'un genre : entier obligatoire, plus grand que 0.
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_id_genre: identifiant à vérifier
   * @throws -20002 (400) identifiant absent, non entier ou plus petit que 1
   */
  PROCEDURE valider_id (
    p_id_genre IN genre.id_genre%TYPE
  ) AS
  BEGIN
    -- MOD (Leçon 6) : le reste de la division par 1 est 0 pour un entier.
    IF p_id_genre IS NULL OR p_id_genre <= 0 OR MOD(p_id_genre, 1) <> 0 THEN
      RAISE_APPLICATION_ERROR(api_erreurs.c_donnee_invalide,
        'L''identifiant du genre est obligatoire et doit être un entier plus grand que 0.');
    END IF;
  END valider_id;

  /**
   * Vérifie le nom d'un nouveau genre (validation proactive, sans lire la BD,
   * comme ins_client de la Leçon 9, diapo 23).
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_nom_genre: nom du genre
   * @throws -20002 (400) nom absent
   */
  PROCEDURE valider_nom (
    p_nom_genre IN genre.nom_genre%TYPE
  ) AS
  BEGIN
    IF p_nom_genre IS NULL THEN
      RAISE_APPLICATION_ERROR(api_erreurs.c_donnee_invalide,
        'Le nom du genre est obligatoire.');
    END IF;
  END valider_nom;

  FUNCTION genre_insert (
    p_id_genre    IN genre.id_genre%TYPE    DEFAULT NULL,
    p_nom_genre   IN genre.nom_genre%TYPE   DEFAULT NULL,
    p_description IN genre.description%TYPE DEFAULT NULL,
    p_test        IN VARCHAR2               DEFAULT 'N'
  ) RETURN NUMBER AS
    l_scope    logger_logs.scope%TYPE := gc_scope_prefix || 'genre_insert';
    l_params   logger.tab_param;
    l_id_genre genre.id_genre%TYPE;
  BEGIN
    logger.append_param(l_params, 'p_id_genre', p_id_genre);
    logger.append_param(l_params, 'p_nom_genre', p_nom_genre);
    logger.append_param(l_params, 'p_description', p_description);
    logger.append_param(l_params, 'p_test', p_test);
    logger.log('>>> Début', l_scope, NULL, l_params);

    IF p_id_genre IS NOT NULL THEN
      valider_id(p_id_genre);
    END IF;
    valider_nom(p_nom_genre);

    -- Validation réactive : la clé primaire refuse un identifiant déjà utilisé.
    -- RETURNING récupère l'identifiant assigné par la BD (colonne identité).
    INSERT INTO genre (id_genre, nom_genre, description)
    VALUES (p_id_genre, p_nom_genre, p_description)
    RETURNING id_genre INTO l_id_genre;

    logger.log_information('<<< Fin : genre ' || l_id_genre || ' ajouté.', l_scope);

    IF p_test = c_confirmer THEN
      COMMIT;
    END IF;

    RETURN l_id_genre;
  EXCEPTION
    -- ROLLBACK seulement si p_test vaut 'N' : en mode test, l'appelant garde le
    -- contrôle de sa transaction (Leçon 9, diapos 38 et 39; Leçon 7, diapo 41).
    WHEN api_erreurs.e_donnee_invalide THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_warning(SQLERRM, l_scope, NULL, l_params);
      RAISE;
    WHEN DUP_VAL_ON_INDEX THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_warning(SQLERRM, l_scope, NULL, l_params);
      RAISE_APPLICATION_ERROR(api_erreurs.c_conflit,
        'L''identifiant de genre ' || COALESCE(TO_CHAR(p_id_genre), 'généré par la BD')
        || ' est déjà utilisé.');
    WHEN api_erreurs.e_valeur_null_non_permise THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_warning(SQLERRM, l_scope, NULL, l_params);
      RAISE_APPLICATION_ERROR(api_erreurs.c_donnee_invalide,
        'Une valeur obligatoire du genre est absente (par exemple l''identifiant, '
        || 'si la table GENRE n''a pas de colonne identité).');
    WHEN api_erreurs.e_valeur_trop_grande THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_warning(SQLERRM, l_scope, NULL, l_params);
      RAISE_APPLICATION_ERROR(api_erreurs.c_donnee_invalide,
        'Le nom ou la description du genre dépasse la longueur permise.');
    WHEN OTHERS THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_error('Erreur imprévue', l_scope, NULL, l_params);
      RAISE;
  END genre_insert;

  FUNCTION genre_update (
    p_id_genre    IN genre.id_genre%TYPE    DEFAULT NULL,
    p_nom_genre   IN genre.nom_genre%TYPE   DEFAULT NULL,
    p_description IN genre.description%TYPE DEFAULT NULL,
    p_test        IN VARCHAR2               DEFAULT 'N'
  ) RETURN NUMBER AS
    l_scope        logger_logs.scope%TYPE := gc_scope_prefix || 'genre_update';
    l_params       logger.tab_param;
    rec_genre      genre%ROWTYPE;
    l_nbre_rangees NUMBER;
  BEGIN
    logger.append_param(l_params, 'p_id_genre', p_id_genre);
    logger.append_param(l_params, 'p_nom_genre', p_nom_genre);
    logger.append_param(l_params, 'p_description', p_description);
    logger.append_param(l_params, 'p_test', p_test);
    logger.log('>>> Début', l_scope, NULL, l_params);

    valider_id(p_id_genre);

    -- Lecture des valeurs actuelles, puis une seule mise à jour (Leçon 9, diapo 24).
    BEGIN
      SELECT *
        INTO rec_genre
        FROM genre
       WHERE id_genre = p_id_genre;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(api_erreurs.c_introuvable,
          'Le genre ' || p_id_genre || ' est introuvable.');
    END;

    -- COALESCE garde la valeur actuelle quand un paramètre est NULL.
    UPDATE genre
       SET nom_genre   = COALESCE(p_nom_genre, rec_genre.nom_genre),
           description = COALESCE(p_description, rec_genre.description)
     WHERE id_genre = p_id_genre;

    l_nbre_rangees := SQL%ROWCOUNT;

    logger.log_information('<<< Fin : genre ' || p_id_genre || ' modifié.', l_scope);

    IF p_test = c_confirmer THEN
      COMMIT;
    END IF;

    RETURN l_nbre_rangees;
  EXCEPTION
    WHEN api_erreurs.e_introuvable OR api_erreurs.e_donnee_invalide THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_warning(SQLERRM, l_scope, NULL, l_params);
      RAISE;
    WHEN api_erreurs.e_valeur_trop_grande THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_warning(SQLERRM, l_scope, NULL, l_params);
      RAISE_APPLICATION_ERROR(api_erreurs.c_donnee_invalide,
        'Le nom ou la description du genre dépasse la longueur permise.');
    WHEN OTHERS THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_error('Erreur imprévue', l_scope, NULL, l_params);
      RAISE;
  END genre_update;

  FUNCTION genre_delete (
    p_id_genre IN genre.id_genre%TYPE DEFAULT NULL,
    p_test     IN VARCHAR2            DEFAULT 'N'
  ) RETURN NUMBER AS
    l_scope        logger_logs.scope%TYPE := gc_scope_prefix || 'genre_delete';
    l_params       logger.tab_param;
    l_nbre_rangees NUMBER;
  BEGIN
    logger.append_param(l_params, 'p_id_genre', p_id_genre);
    logger.append_param(l_params, 'p_test', p_test);
    logger.log('>>> Début', l_scope, NULL, l_params);

    valider_id(p_id_genre);

    -- Validation réactive : la clé étrangère jeu_genre_fk refuse la suppression
    -- d'un genre encore utilisé par un jeu (ORA-02292).
    DELETE FROM genre
     WHERE id_genre = p_id_genre;

    l_nbre_rangees := SQL%ROWCOUNT;

    IF l_nbre_rangees = 0 THEN
      RAISE_APPLICATION_ERROR(api_erreurs.c_introuvable,
        'Le genre ' || p_id_genre || ' est introuvable.');
    END IF;

    logger.log_information('<<< Fin : genre ' || p_id_genre || ' supprimé.', l_scope);

    IF p_test = c_confirmer THEN
      COMMIT;
    END IF;

    RETURN l_nbre_rangees;
  EXCEPTION
    WHEN api_erreurs.e_introuvable OR api_erreurs.e_donnee_invalide THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_warning(SQLERRM, l_scope, NULL, l_params);
      RAISE;
    WHEN api_erreurs.e_enfants_existants THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_warning(SQLERRM, l_scope, NULL, l_params);
      RAISE_APPLICATION_ERROR(api_erreurs.c_conflit,
        'Le genre ' || p_id_genre || ' est encore utilisé par au moins un jeu.');
    WHEN OTHERS THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_error('Erreur imprévue', l_scope, NULL, l_params);
      RAISE;
  END genre_delete;

  FUNCTION genre_select (
    p_id_genre IN genre.id_genre%TYPE DEFAULT NULL,
    p_debut    IN PLS_INTEGER         DEFAULT 0,
    p_limite   IN PLS_INTEGER         DEFAULT 5
  ) RETURN VARCHAR2 AS
    l_scope        logger_logs.scope%TYPE := gc_scope_prefix || 'genre_select';
    l_params       logger.tab_param;
    -- NULL reçu de Node.js (paramètre absent de l'URL) = valeur par défaut
    l_debut        PLS_INTEGER := COALESCE(p_debut, 0);
    l_limite       PLS_INTEGER := COALESCE(p_limite, 5);
    l_nbre_rangees NUMBER;
    l_json         VARCHAR2(4000);
  BEGIN
    logger.append_param(l_params, 'p_id_genre', p_id_genre);
    logger.append_param(l_params, 'p_debut', p_debut);
    logger.append_param(l_params, 'p_limite', p_limite);
    logger.log('>>> Début', l_scope, NULL, l_params);

    IF p_id_genre IS NOT NULL THEN
      valider_id(p_id_genre);

      -- Validation proactive (Leçon 7, diapo 17) : le genre demandé existe-t-il?
      SELECT COUNT(*)
        INTO l_nbre_rangees
        FROM genre
       WHERE id_genre = p_id_genre;

      IF l_nbre_rangees = 0 THEN
        RAISE_APPLICATION_ERROR(api_erreurs.c_introuvable,
          'Le genre ' || p_id_genre || ' est introuvable.');
      END IF;

      l_debut := 0;  -- un seul genre demandé : la pagination ne s'applique pas
    END IF;

    IF l_debut < 0 THEN
      RAISE_APPLICATION_ERROR(api_erreurs.c_donnee_invalide,
        'La position de départ (debut) doit être positive ou nulle.');
    END IF;

    IF l_limite < 1 OR l_limite > c_limite_max THEN
      RAISE_APPLICATION_ERROR(api_erreurs.c_donnee_invalide,
        'La limite doit être un nombre de 1 à ' || c_limite_max || '.');
    END IF;

    -- Squelette du cours (Leçon 9, diapos 31 et 32) : le WITH lit la page demandée,
    -- puis JSON_OBJECT(*) transforme chaque rangée en objet JSON.
    -- Une page vide donne "taille":0 et "resultats":null.
    SELECT JSON_OBJECT(*)
      INTO l_json
      FROM (
        WITH genre_data AS (
          SELECT *
            FROM genre
           WHERE id_genre = COALESCE(p_id_genre, id_genre)
           ORDER BY id_genre
          OFFSET l_debut ROWS FETCH NEXT l_limite ROWS ONLY
        )
        SELECT l_limite "limite", l_debut "debut", COUNT(*) "taille",
               JSON_ARRAYAGG(JSON_OBJECT(*)) "resultats"
          FROM genre_data
      );

    logger.log('<<< Fin', l_scope);
    RETURN l_json;
  EXCEPTION
    WHEN api_erreurs.e_introuvable OR api_erreurs.e_donnee_invalide THEN
      logger.log_warning(SQLERRM, l_scope, NULL, l_params);
      RAISE;
    WHEN OTHERS THEN
      logger.log_error('Erreur imprévue', l_scope, NULL, l_params);
      RAISE;
  END genre_select;
END genre_api;
/
