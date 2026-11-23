---- API PL/SQL DE L'ENTITÉ JEU : CORPS ----
CREATE OR REPLACE PACKAGE BODY jeu_api AS
  -- Préfixe de la portée Logger : « jeu_api. » (gabarit Logger du cours)
  gc_scope_prefix CONSTANT VARCHAR2(31) := LOWER($$plsql_unit) || '.';
  -- Valeur de p_test qui confirme la transaction (gabarit Javadoc : « si 'N' alors commit »)
  c_confirmer CONSTANT VARCHAR2(1) := 'N';

  /**
   * Vérifie l'identifiant d'un jeu : entier obligatoire, plus grand que 0.
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_id_jeu: identifiant à vérifier
   * @throws -20002 (400) identifiant absent, non entier ou plus petit que 1
   */
  PROCEDURE valider_id (
    p_id_jeu IN jeu.id_jeu%TYPE
  ) AS
  BEGIN
    -- MOD (Leçon 6) : le reste de la division par 1 est 0 pour un entier.
    IF p_id_jeu IS NULL OR p_id_jeu <= 0 OR MOD(p_id_jeu, 1) <> 0 THEN
      RAISE_APPLICATION_ERROR(api_erreurs.c_donnee_invalide,
        'L''identifiant du jeu est obligatoire et doit être un entier plus grand que 0.');
    END IF;
  END valider_id;

  /**
   * Valide les données d'un nouveau jeu (validation proactive, sans lire la BD).
   * L'existence du genre et du concepteur est vérifiée de façon réactive par les
   * clés étrangères, au moment de l'INSERT.
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_titre: titre du jeu
   * @param p_prix: prix du jeu
   * @param p_genre_id_genre: identifiant du genre
   * @param p_concepteur_id_concepteur: identifiant du concepteur
   * @throws -20002 (400) titre, prix, genre ou concepteur absent, ou prix négatif
   */
  PROCEDURE valider_insert (
    p_titre                    IN jeu.titre%TYPE,
    p_prix                     IN jeu.prix%TYPE,
    p_genre_id_genre           IN jeu.genre_id_genre%TYPE,
    p_concepteur_id_concepteur IN jeu.concepteur_id_concepteur%TYPE
  ) AS
  BEGIN
    IF p_titre IS NULL THEN
      RAISE_APPLICATION_ERROR(api_erreurs.c_donnee_invalide,
        'Le titre du jeu est obligatoire.');
    END IF;

    IF p_prix IS NULL OR p_prix < 0 THEN
      RAISE_APPLICATION_ERROR(api_erreurs.c_donnee_invalide,
        'Le prix du jeu est obligatoire et doit être positif ou nul.');
    END IF;

    IF p_genre_id_genre IS NULL OR p_concepteur_id_concepteur IS NULL THEN
      RAISE_APPLICATION_ERROR(api_erreurs.c_donnee_invalide,
        'Le genre et le concepteur du jeu sont obligatoires.');
    END IF;
  END valider_insert;

  /**
   * Valide le nouveau prix d'un jeu (validation proactive). Un prix NULL veut
   * dire « garder la valeur actuelle » : ce n'est donc pas une erreur.
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_prix: nouveau prix (NULL = inchangé)
   * @throws -20002 (400) prix négatif
   */
  PROCEDURE valider_update (
    p_prix IN jeu.prix%TYPE
  ) AS
  BEGIN
    -- Si p_prix est NULL, la condition est inconnue (NULL) : aucune erreur.
    IF p_prix < 0 THEN
      RAISE_APPLICATION_ERROR(api_erreurs.c_donnee_invalide,
        'Le prix du jeu doit être positif ou nul.');
    END IF;
  END valider_update;

  FUNCTION jeu_insert (
    p_id_jeu                   IN jeu.id_jeu%TYPE                   DEFAULT NULL,
    p_titre                    IN jeu.titre%TYPE                    DEFAULT NULL,
    p_description              IN jeu.description%TYPE              DEFAULT NULL,
    p_date_sortie              IN jeu.date_sortie%TYPE              DEFAULT NULL,
    p_prix                     IN jeu.prix%TYPE                     DEFAULT NULL,
    p_genre_id_genre           IN jeu.genre_id_genre%TYPE           DEFAULT NULL,
    p_concepteur_id_concepteur IN jeu.concepteur_id_concepteur%TYPE DEFAULT NULL,
    p_test                     IN VARCHAR2                          DEFAULT 'N'
  ) RETURN NUMBER AS
    l_scope  logger_logs.scope%TYPE := gc_scope_prefix || 'jeu_insert';
    l_params logger.tab_param;
    l_id_jeu jeu.id_jeu%TYPE;
  BEGIN
    logger.append_param(l_params, 'p_id_jeu', p_id_jeu);
    logger.append_param(l_params, 'p_titre', p_titre);
    logger.append_param(l_params, 'p_description', p_description);
    logger.append_param(l_params, 'p_date_sortie', p_date_sortie);
    logger.append_param(l_params, 'p_prix', p_prix);
    logger.append_param(l_params, 'p_genre_id_genre', p_genre_id_genre);
    logger.append_param(l_params, 'p_concepteur_id_concepteur', p_concepteur_id_concepteur);
    logger.append_param(l_params, 'p_test', p_test);
    logger.log('>>> Début', l_scope, NULL, l_params);

    -- Validation proactive (sans lire la BD)
    IF p_id_jeu IS NOT NULL THEN
      valider_id(p_id_jeu);
    END IF;
    valider_insert(p_titre, p_prix, p_genre_id_genre, p_concepteur_id_concepteur);

    -- Validation réactive : la clé primaire refuse un identifiant déjà utilisé et
    -- les clés étrangères refusent un genre ou un concepteur inexistant.
    -- RETURNING récupère l'identifiant sans SELECT supplémentaire (Leçon 9);
    -- si p_id_jeu est NULL, la BD l'assigne (colonne identité).
    INSERT INTO jeu (id_jeu, titre, description, date_sortie, prix,
                     genre_id_genre, concepteur_id_concepteur)
    VALUES (p_id_jeu, p_titre, p_description, p_date_sortie, p_prix,
            p_genre_id_genre, p_concepteur_id_concepteur)
    RETURNING id_jeu INTO l_id_jeu;

    logger.log_information('<<< Fin : jeu ' || l_id_jeu || ' ajouté.', l_scope);

    -- SmartDB : l'API confirme elle-même la transaction, sauf en mode test.
    IF p_test = c_confirmer THEN
      COMMIT;
    END IF;

    RETURN l_id_jeu;
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
        'L''identifiant de jeu ' || COALESCE(TO_CHAR(p_id_jeu), 'généré par la BD')
        || ' est déjà utilisé.');
    WHEN api_erreurs.e_parent_introuvable THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_warning(SQLERRM, l_scope, NULL, l_params);
      RAISE_APPLICATION_ERROR(api_erreurs.c_donnee_invalide,
        'Le genre ' || p_genre_id_genre || ' ou le concepteur '
        || p_concepteur_id_concepteur || ' n''existe pas.');
    WHEN api_erreurs.e_valeur_null_non_permise THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_warning(SQLERRM, l_scope, NULL, l_params);
      RAISE_APPLICATION_ERROR(api_erreurs.c_donnee_invalide,
        'Une valeur obligatoire du jeu est absente (par exemple l''identifiant, '
        || 'si la table JEU n''a pas de colonne identité).');
    WHEN api_erreurs.e_valeur_trop_grande THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_warning(SQLERRM, l_scope, NULL, l_params);
      RAISE_APPLICATION_ERROR(api_erreurs.c_donnee_invalide,
        'Le titre ou la description du jeu dépasse la longueur permise.');
    WHEN OTHERS THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_error('Erreur imprévue', l_scope, NULL, l_params);
      RAISE;
  END jeu_insert;

  FUNCTION jeu_update (
    p_id_jeu                   IN jeu.id_jeu%TYPE                   DEFAULT NULL,
    p_titre                    IN jeu.titre%TYPE                    DEFAULT NULL,
    p_description              IN jeu.description%TYPE              DEFAULT NULL,
    p_date_sortie              IN jeu.date_sortie%TYPE              DEFAULT NULL,
    p_prix                     IN jeu.prix%TYPE                     DEFAULT NULL,
    p_genre_id_genre           IN jeu.genre_id_genre%TYPE           DEFAULT NULL,
    p_concepteur_id_concepteur IN jeu.concepteur_id_concepteur%TYPE DEFAULT NULL,
    p_test                     IN VARCHAR2                          DEFAULT 'N'
  ) RETURN NUMBER AS
    l_scope        logger_logs.scope%TYPE := gc_scope_prefix || 'jeu_update';
    l_params       logger.tab_param;
    rec_jeu        jeu%ROWTYPE;
    l_nbre_rangees NUMBER;
  BEGIN
    logger.append_param(l_params, 'p_id_jeu', p_id_jeu);
    logger.append_param(l_params, 'p_titre', p_titre);
    logger.append_param(l_params, 'p_description', p_description);
    logger.append_param(l_params, 'p_date_sortie', p_date_sortie);
    logger.append_param(l_params, 'p_prix', p_prix);
    logger.append_param(l_params, 'p_genre_id_genre', p_genre_id_genre);
    logger.append_param(l_params, 'p_concepteur_id_concepteur', p_concepteur_id_concepteur);
    logger.append_param(l_params, 'p_test', p_test);
    logger.log('>>> Début', l_scope, NULL, l_params);

    valider_id(p_id_jeu);
    valider_update(p_prix);

    -- Lecture des valeurs actuelles, puis une seule mise à jour (Leçon 9, diapo 24).
    -- CU-07 « Jeu manquant » : aucune rangée lue = 404 (sous-bloc, Leçon 7, diapo 32).
    BEGIN
      SELECT *
        INTO rec_jeu
        FROM jeu
       WHERE id_jeu = p_id_jeu;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(api_erreurs.c_introuvable,
          'Le jeu ' || p_id_jeu || ' est introuvable.');
    END;

    -- COALESCE garde la valeur actuelle quand un paramètre est NULL.
    -- Validation réactive : les clés étrangères refusent un genre ou un concepteur inexistant.
    UPDATE jeu
       SET titre                    = COALESCE(p_titre, rec_jeu.titre),
           description              = COALESCE(p_description, rec_jeu.description),
           date_sortie              = COALESCE(p_date_sortie, rec_jeu.date_sortie),
           prix                     = COALESCE(p_prix, rec_jeu.prix),
           genre_id_genre           = COALESCE(p_genre_id_genre, rec_jeu.genre_id_genre),
           concepteur_id_concepteur = COALESCE(p_concepteur_id_concepteur,
                                               rec_jeu.concepteur_id_concepteur)
     WHERE id_jeu = p_id_jeu;

    -- SQL%ROWCOUNT : nombre de rangées touchées par la dernière instruction SQL.
    l_nbre_rangees := SQL%ROWCOUNT;

    logger.log_information('<<< Fin : jeu ' || p_id_jeu || ' modifié.', l_scope);

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
    WHEN api_erreurs.e_parent_introuvable THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_warning(SQLERRM, l_scope, NULL, l_params);
      RAISE_APPLICATION_ERROR(api_erreurs.c_donnee_invalide,
        'Le genre ' || COALESCE(TO_CHAR(p_genre_id_genre), '(inchangé)') || ' ou le concepteur '
        || COALESCE(TO_CHAR(p_concepteur_id_concepteur), '(inchangé)') || ' n''existe pas.');
    WHEN api_erreurs.e_valeur_trop_grande THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_warning(SQLERRM, l_scope, NULL, l_params);
      RAISE_APPLICATION_ERROR(api_erreurs.c_donnee_invalide,
        'Le titre ou la description du jeu dépasse la longueur permise.');
    WHEN OTHERS THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_error('Erreur imprévue', l_scope, NULL, l_params);
      RAISE;
  END jeu_update;

  FUNCTION jeu_delete (
    p_id_jeu IN jeu.id_jeu%TYPE DEFAULT NULL,
    p_test   IN VARCHAR2        DEFAULT 'N'
  ) RETURN NUMBER AS
    l_scope        logger_logs.scope%TYPE := gc_scope_prefix || 'jeu_delete';
    l_params       logger.tab_param;
    l_titre        jeu.titre%TYPE;
    l_nbre_rangees NUMBER;
  BEGIN
    logger.append_param(l_params, 'p_id_jeu', p_id_jeu);
    logger.append_param(l_params, 'p_test', p_test);
    logger.log('>>> Début', l_scope, NULL, l_params);

    valider_id(p_id_jeu);

    -- Les associations avec les plateformes disparaissent d'abord (clé étrangère
    -- jeu_plateforme_jeu_fk). Si la suite échoue, le ROLLBACK (p_test = 'N')
    -- annule aussi cette première suppression.
    DELETE FROM jeu_plateforme
     WHERE jeu_id_jeu = p_id_jeu;

    -- RETURNING récupère le titre du jeu supprimé pour le journal.
    DELETE FROM jeu
     WHERE id_jeu = p_id_jeu
    RETURNING titre INTO l_titre;

    l_nbre_rangees := SQL%ROWCOUNT;

    -- CU-08 « Jeu manquant » : aucune rangée supprimée = 404.
    IF l_nbre_rangees = 0 THEN
      RAISE_APPLICATION_ERROR(api_erreurs.c_introuvable,
        'Le jeu ' || p_id_jeu || ' est introuvable.');
    END IF;

    logger.log_information('<<< Fin : jeu ' || p_id_jeu || ' (' || l_titre || ') supprimé.', l_scope);

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
      -- Aucune autre table ne référence JEU aujourd'hui (sauf jeu_plateforme, vidée
      -- plus haut). Si le modèle en ajoute une, la suppression sera refusée (409).
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_warning(SQLERRM, l_scope, NULL, l_params);
      RAISE_APPLICATION_ERROR(api_erreurs.c_conflit,
        'Le jeu ' || p_id_jeu || ' est encore utilisé par d''autres données.');
    WHEN OTHERS THEN
      IF p_test = c_confirmer THEN
        ROLLBACK;
      END IF;
      logger.log_error('Erreur imprévue', l_scope, NULL, l_params);
      RAISE;
  END jeu_delete;

  FUNCTION jeu_select (
    p_id_jeu IN jeu.id_jeu%TYPE DEFAULT NULL,
    p_debut  IN PLS_INTEGER     DEFAULT 0,
    p_limite IN PLS_INTEGER     DEFAULT 5
  ) RETURN VARCHAR2 AS
    l_scope        logger_logs.scope%TYPE := gc_scope_prefix || 'jeu_select';
    l_params       logger.tab_param;
    -- NULL reçu de Node.js (paramètre absent de l'URL) = valeur par défaut
    l_debut        PLS_INTEGER := COALESCE(p_debut, 0);
    l_limite       PLS_INTEGER := COALESCE(p_limite, 5);
    l_nbre_rangees NUMBER;
    l_json         VARCHAR2(4000);
  BEGIN
    logger.append_param(l_params, 'p_id_jeu', p_id_jeu);
    logger.append_param(l_params, 'p_debut', p_debut);
    logger.append_param(l_params, 'p_limite', p_limite);
    logger.log('>>> Début', l_scope, NULL, l_params);

    -- Validation proactive des paramètres
    IF p_id_jeu IS NOT NULL THEN
      valider_id(p_id_jeu);  -- CU-04 « Identifiant invalide » : 400

      -- CU-04 et CU-05 « Jeu introuvable » : 404 (validation proactive, Leçon 7, diapo 17)
      SELECT COUNT(*)
        INTO l_nbre_rangees
        FROM jeu
       WHERE id_jeu = p_id_jeu;

      IF l_nbre_rangees = 0 THEN
        RAISE_APPLICATION_ERROR(api_erreurs.c_introuvable,
          'Le jeu ' || p_id_jeu || ' est introuvable.');
      END IF;

      l_debut := 0;  -- un seul jeu demandé : la pagination ne s'applique pas
    END IF;

    IF l_debut < 0 THEN
      RAISE_APPLICATION_ERROR(api_erreurs.c_donnee_invalide,
        'La position de départ (debut) doit être positive ou nulle.');
    END IF;

    IF l_limite < 1 OR l_limite > c_limite_max THEN
      RAISE_APPLICATION_ERROR(api_erreurs.c_donnee_invalide,
        'La limite doit être un nombre de 1 à ' || c_limite_max || '.');
    END IF;

    -- Squelette du cours (Leçon 9, diapos 31 et 32) : le WITH lit la page de jeux
    -- demandée, puis JSON_OBJECT(*) transforme chaque rangée en objet JSON.
    -- Fiche du CU-05 dans la même requête : jointures avec GENRE et CONCEPTEUR, et
    -- LEFT JOIN avec les plateformes regroupées par jeu (GROUP BY, Leçon 2) dans un
    -- tableau JSON (JSON_ARRAYAGG). Une page vide donne "taille":0 et "resultats":null.
    SELECT JSON_OBJECT(*)
      INTO l_json
      FROM (
        WITH jeu_data AS (
          SELECT j.id_jeu, j.titre, j.description, j.date_sortie, j.prix,
                 g.id_genre, g.nom_genre, c.id_concepteur, c.nom_concepteur,
                 JSON_ARRAYAGG(p.nom_plateforme) AS plateformes
            FROM jeu j
           INNER JOIN genre g      ON g.id_genre = j.genre_id_genre
           INNER JOIN concepteur c ON c.id_concepteur = j.concepteur_id_concepteur
            LEFT JOIN jeu_plateforme jp ON jp.jeu_id_jeu = j.id_jeu
            LEFT JOIN plateforme p      ON p.id_plateforme = jp.plateforme_id_plateforme
           WHERE j.id_jeu = COALESCE(p_id_jeu, j.id_jeu)
           GROUP BY j.id_jeu, j.titre, j.description, j.date_sortie, j.prix,
                    g.id_genre, g.nom_genre, c.id_concepteur, c.nom_concepteur
           ORDER BY j.id_jeu
          OFFSET l_debut ROWS FETCH NEXT l_limite ROWS ONLY
        )
        SELECT l_limite "limite", l_debut "debut", COUNT(*) "taille",
               JSON_ARRAYAGG(JSON_OBJECT(*)) "resultats"
          FROM jeu_data
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
  END jeu_select;
END jeu_api;
/
