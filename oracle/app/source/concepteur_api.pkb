---- API PL/SQL DE L'ENTITÉ CONCEPTEUR : CORPS ----
CREATE OR REPLACE PACKAGE BODY concepteur_api AS
  -- Préfixe de la portée Logger : « concepteur_api. » (gabarit Logger du cours)
  gc_scope_prefix CONSTANT VARCHAR2(31) := LOWER($$plsql_unit) || '.';
  -- Valeur de p_test qui confirme la transaction (gabarit Javadoc : « si 'N' alors commit »)
  c_confirmer CONSTANT VARCHAR2(1) := 'N';

  /**
   * Vérifie l'identifiant d'un concepteur : entier obligatoire, plus grand que 0.
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_id_concepteur: identifiant à vérifier
   * @throws -20002 (400) identifiant absent, non entier ou plus petit que 1
   */
  PROCEDURE valider_id (
    p_id_concepteur IN concepteur.id_concepteur%TYPE
  ) AS
  BEGIN
    -- MOD (Leçon 6) : le reste de la division par 1 est 0 pour un entier.
    IF p_id_concepteur IS NULL OR p_id_concepteur <= 0
       OR MOD(p_id_concepteur, 1) <> 0 THEN
      RAISE_APPLICATION_ERROR(api_erreurs.c_donnee_invalide,
        'L''identifiant du concepteur est obligatoire et doit être un entier plus grand que 0.');
    END IF;
  END valider_id;

  /**
   * Vérifie le nom d'un nouveau concepteur (validation proactive, sans lire la BD,
   * comme ins_client de la Leçon 9, diapo 23).
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_nom_concepteur: nom du concepteur
   * @throws -20002 (400) nom absent
   */
  PROCEDURE valider_nom (
    p_nom_concepteur IN concepteur.nom_concepteur%TYPE
  ) AS
  BEGIN
    IF p_nom_concepteur IS NULL THEN
      RAISE_APPLICATION_ERROR(api_erreurs.c_donnee_invalide,
        'Le nom du concepteur est obligatoire.');
    END IF;
  END valider_nom;

  FUNCTION concepteur_insert (
    p_id_concepteur  IN concepteur.id_concepteur%TYPE  DEFAULT NULL,
    p_nom_concepteur IN concepteur.nom_concepteur%TYPE DEFAULT NULL,
    p_pays           IN concepteur.pays%TYPE           DEFAULT NULL,
    p_test           IN VARCHAR2                       DEFAULT 'N'
  ) RETURN NUMBER AS
    l_scope         logger_logs.scope%TYPE := gc_scope_prefix || 'concepteur_insert';
    l_params        logger.tab_param;
    l_id_concepteur concepteur.id_concepteur%TYPE;
  BEGIN
    logger.append_param(l_params, 'p_id_concepteur', p_id_concepteur);
    logger.append_param(l_params, 'p_nom_concepteur', p_nom_concepteur);
    logger.append_param(l_params, 'p_pays', p_pays);
    logger.append_param(l_params, 'p_test', p_test);
    logger.log('>>> Début', l_scope, NULL, l_params);

    IF p_id_concepteur IS NOT NULL THEN
      valider_id(p_id_concepteur);
    END IF;
    valider_nom(p_nom_concepteur);

    -- Validation réactive : la clé primaire refuse un identifiant déjà utilisé.
    -- RETURNING récupère l'identifiant assigné par la BD (colonne identité).
    INSERT INTO concepteur (id_concepteur, nom_concepteur, pays)
    VALUES (p_id_concepteur, p_nom_concepteur, p_pays)
    RETURNING id_concepteur INTO l_id_concepteur;

    logger.log_information('<<< Fin : concepteur ' || l_id_concepteur || ' ajouté.', l_scope);

    IF p_test = c_confirmer THEN
      COMMIT;
    END IF;

    RETURN l_id_concepteur;
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
        'L''identifiant de concepteur ' || COALESCE(TO_CHAR(p_id_concepteur), 'généré par la BD')
        || ' est déjà utilisé.');
    WHEN api_erreurs.e_valeur_null_non_permise THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_warning(SQLERRM, l_scope, NULL, l_params);
      RAISE_APPLICATION_ERROR(api_erreurs.c_donnee_invalide,
        'Une valeur obligatoire du concepteur est absente (par exemple l''identifiant, '
        || 'si la table CONCEPTEUR n''a pas de colonne identité).');
    WHEN api_erreurs.e_valeur_trop_grande THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_warning(SQLERRM, l_scope, NULL, l_params);
      RAISE_APPLICATION_ERROR(api_erreurs.c_donnee_invalide,
        'Le nom ou le pays du concepteur dépasse la longueur permise.');
    WHEN OTHERS THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_error('Erreur imprévue', l_scope, NULL, l_params);
      RAISE;
  END concepteur_insert;

  FUNCTION concepteur_update (
    p_id_concepteur  IN concepteur.id_concepteur%TYPE  DEFAULT NULL,
    p_nom_concepteur IN concepteur.nom_concepteur%TYPE DEFAULT NULL,
    p_pays           IN concepteur.pays%TYPE           DEFAULT NULL,
    p_test           IN VARCHAR2                       DEFAULT 'N'
  ) RETURN NUMBER AS
    l_scope        logger_logs.scope%TYPE := gc_scope_prefix || 'concepteur_update';
    l_params       logger.tab_param;
    rec_concepteur concepteur%ROWTYPE;
    l_nbre_rangees NUMBER;
  BEGIN
    logger.append_param(l_params, 'p_id_concepteur', p_id_concepteur);
    logger.append_param(l_params, 'p_nom_concepteur', p_nom_concepteur);
    logger.append_param(l_params, 'p_pays', p_pays);
    logger.append_param(l_params, 'p_test', p_test);
    logger.log('>>> Début', l_scope, NULL, l_params);

    valider_id(p_id_concepteur);

    -- Lecture des valeurs actuelles, puis une seule mise à jour (Leçon 9, diapo 24).
    BEGIN
      SELECT *
        INTO rec_concepteur
        FROM concepteur
       WHERE id_concepteur = p_id_concepteur;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(api_erreurs.c_introuvable,
          'Le concepteur ' || p_id_concepteur || ' est introuvable.');
    END;

    -- COALESCE garde la valeur actuelle quand un paramètre est NULL.
    UPDATE concepteur
       SET nom_concepteur = COALESCE(p_nom_concepteur, rec_concepteur.nom_concepteur),
           pays           = COALESCE(p_pays, rec_concepteur.pays)
     WHERE id_concepteur = p_id_concepteur;

    l_nbre_rangees := SQL%ROWCOUNT;

    logger.log_information('<<< Fin : concepteur ' || p_id_concepteur || ' modifié.', l_scope);

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
        'Le nom ou le pays du concepteur dépasse la longueur permise.');
    WHEN OTHERS THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_error('Erreur imprévue', l_scope, NULL, l_params);
      RAISE;
  END concepteur_update;

  FUNCTION concepteur_delete (
    p_id_concepteur IN concepteur.id_concepteur%TYPE DEFAULT NULL,
    p_test          IN VARCHAR2                      DEFAULT 'N'
  ) RETURN NUMBER AS
    l_scope        logger_logs.scope%TYPE := gc_scope_prefix || 'concepteur_delete';
    l_params       logger.tab_param;
    l_nbre_rangees NUMBER;
  BEGIN
    logger.append_param(l_params, 'p_id_concepteur', p_id_concepteur);
    logger.append_param(l_params, 'p_test', p_test);
    logger.log('>>> Début', l_scope, NULL, l_params);

    valider_id(p_id_concepteur);

    -- Validation réactive : la clé étrangère jeu_concepteur_fk refuse la suppression
    -- d'un concepteur encore lié à un jeu (ORA-02292).
    DELETE FROM concepteur
     WHERE id_concepteur = p_id_concepteur;

    l_nbre_rangees := SQL%ROWCOUNT;

    IF l_nbre_rangees = 0 THEN
      RAISE_APPLICATION_ERROR(api_erreurs.c_introuvable,
        'Le concepteur ' || p_id_concepteur || ' est introuvable.');
    END IF;

    logger.log_information('<<< Fin : concepteur ' || p_id_concepteur || ' supprimé.', l_scope);

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
        'Le concepteur ' || p_id_concepteur || ' est encore lié à au moins un jeu.');
    WHEN OTHERS THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_error('Erreur imprévue', l_scope, NULL, l_params);
      RAISE;
  END concepteur_delete;

  FUNCTION concepteur_select (
    p_id_concepteur IN concepteur.id_concepteur%TYPE DEFAULT NULL,
    p_debut         IN PLS_INTEGER                   DEFAULT 0,
    p_limite        IN PLS_INTEGER                   DEFAULT 5
  ) RETURN VARCHAR2 AS
    l_scope        logger_logs.scope%TYPE := gc_scope_prefix || 'concepteur_select';
    l_params       logger.tab_param;
    -- NULL reçu de Node.js (paramètre absent de l'URL) = valeur par défaut
    l_debut        PLS_INTEGER := COALESCE(p_debut, 0);
    l_limite       PLS_INTEGER := COALESCE(p_limite, 5);
    l_nbre_rangees NUMBER;
    l_json         VARCHAR2(4000);
  BEGIN
    logger.append_param(l_params, 'p_id_concepteur', p_id_concepteur);
    logger.append_param(l_params, 'p_debut', p_debut);
    logger.append_param(l_params, 'p_limite', p_limite);
    logger.log('>>> Début', l_scope, NULL, l_params);

    IF p_id_concepteur IS NOT NULL THEN
      valider_id(p_id_concepteur);

      -- Validation proactive (Leçon 7, diapo 17) : le concepteur demandé existe-t-il?
      SELECT COUNT(*)
        INTO l_nbre_rangees
        FROM concepteur
       WHERE id_concepteur = p_id_concepteur;

      IF l_nbre_rangees = 0 THEN
        RAISE_APPLICATION_ERROR(api_erreurs.c_introuvable,
          'Le concepteur ' || p_id_concepteur || ' est introuvable.');
      END IF;

      l_debut := 0;  -- un seul concepteur demandé : la pagination ne s'applique pas
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
        WITH concepteur_data AS (
          SELECT *
            FROM concepteur
           WHERE id_concepteur = COALESCE(p_id_concepteur, id_concepteur)
           ORDER BY id_concepteur
          OFFSET l_debut ROWS FETCH NEXT l_limite ROWS ONLY
        )
        SELECT l_limite "limite", l_debut "debut", COUNT(*) "taille",
               JSON_ARRAYAGG(JSON_OBJECT(*)) "resultats"
          FROM concepteur_data
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
  END concepteur_select;
END concepteur_api;
/
