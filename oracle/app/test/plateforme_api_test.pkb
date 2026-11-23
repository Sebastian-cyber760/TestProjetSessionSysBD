---- TESTS UNITAIRES DE plateforme_api (utPLSQL) : CORPS ----
CREATE OR REPLACE PACKAGE BODY plateforme_api_test AS
  -- Valeur de p_test pour les appels de l'API : 'O' = mode test, ni COMMIT ni ROLLBACK.
  c_test CONSTANT VARCHAR2(1) := 'O';

  ---------------------------------------------------------------------------
  -- Outils de préparation (arrange) et de vérification, absents de la spécification
  ---------------------------------------------------------------------------

  /**
   * Crée une plateforme de test (identifiant assigné par la BD).
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_nom_plateforme: nom de la plateforme de test
   * @return id_plateforme: l'identifiant de la plateforme créée
   */
  FUNCTION creer_plateforme (
    p_nom_plateforme IN plateforme.nom_plateforme%TYPE DEFAULT 'Plateforme de test'
  ) RETURN plateforme.id_plateforme%TYPE IS
    l_id_plateforme plateforme.id_plateforme%TYPE;
  BEGIN
    INSERT INTO plateforme (nom_plateforme)
    VALUES (p_nom_plateforme)
    RETURNING id_plateforme INTO l_id_plateforme;
    RETURN l_id_plateforme;
  END creer_plateforme;

  /**
   * Retourne un identifiant de plateforme qui n'existe pas (le plus grand + 1).
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @return id_plateforme: un identifiant inutilisé
   */
  FUNCTION id_plateforme_inexistant RETURN plateforme.id_plateforme%TYPE IS
    l_id_plateforme plateforme.id_plateforme%TYPE;
  BEGIN
    SELECT COALESCE(MAX(id_plateforme), 0) + 1
      INTO l_id_plateforme
      FROM plateforme;
    RETURN l_id_plateforme;
  END id_plateforme_inexistant;

  /**
   * Indique si le JSON retourné par plateforme_select contient un morceau de texte,
   * par exemple '"taille":1,' (opérateur LIKE, Leçon 6).
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-08
   * @param p_json: JSON retourné par plateforme_select
   * @param p_morceau: texte cherché dans p_json
   * @return 1 si p_json contient p_morceau, sinon 0
   */
  FUNCTION contient (
    p_json    IN VARCHAR2,
    p_morceau IN VARCHAR2
  ) RETURN NUMBER IS
    l_resultat NUMBER := 0;
  BEGIN
    IF p_json LIKE '%' || p_morceau || '%' THEN
      l_resultat := 1;
    END IF;
    RETURN l_resultat;
  END contient;

  ---------------------------------------------------------------------------
  -- Tests
  ---------------------------------------------------------------------------

  PROCEDURE plateforme_insert_valide IS
    l_id_plateforme plateforme.id_plateforme%TYPE;
    l_compte        NUMBER;
    l_nom           plateforme.nom_plateforme%TYPE;
  BEGIN
    -- act : aucun identifiant fourni, la BD l'assigne
    l_id_plateforme := plateforme_api.plateforme_insert(
                         p_nom_plateforme => 'Steam Deck',
                         p_test           => c_test);

    -- assert : la plateforme existe, avec le nom reçu
    SELECT COUNT(*)
      INTO l_compte
      FROM plateforme
     WHERE id_plateforme = l_id_plateforme;
    ut.expect(l_compte).to_equal(1);
    SELECT nom_plateforme
      INTO l_nom
      FROM plateforme
     WHERE id_plateforme = l_id_plateforme;
    ut.expect(l_nom).to_equal('Steam Deck');
  END plateforme_insert_valide;

  PROCEDURE plateforme_insert_nom_absent IS
    l_id_plateforme plateforme.id_plateforme%TYPE;
    l_code          NUMBER;
  BEGIN
    -- act : sous-bloc (Leçon 7, diapo 32) qui attrape l'erreur attendue
    BEGIN
      l_id_plateforme := plateforme_api.plateforme_insert(
                           p_nom_plateforme => NULL,
                           p_test           => c_test);
    EXCEPTION
      WHEN api_erreurs.e_donnee_invalide THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20002
    ut.expect(l_code).to_equal(api_erreurs.c_donnee_invalide);
  END plateforme_insert_nom_absent;

  PROCEDURE plateforme_insert_id_existant IS
    l_id_existant   plateforme.id_plateforme%TYPE;
    l_id_plateforme plateforme.id_plateforme%TYPE;
    l_code          NUMBER;
  BEGIN
    -- arrange
    l_id_existant := creer_plateforme;

    -- act : même identifiant
    BEGIN
      l_id_plateforme := plateforme_api.plateforme_insert(
                           p_id_plateforme  => l_id_existant,
                           p_nom_plateforme => 'Doublon',
                           p_test           => c_test);
    EXCEPTION
      WHEN api_erreurs.e_conflit THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20003
    ut.expect(l_code).to_equal(api_erreurs.c_conflit);
  END plateforme_insert_id_existant;

  PROCEDURE plateforme_update_valide IS
    l_id_plateforme plateforme.id_plateforme%TYPE;
    l_nbre          NUMBER;
    l_nom           plateforme.nom_plateforme%TYPE;
  BEGIN
    -- arrange
    l_id_plateforme := creer_plateforme('Nom avant');

    -- act
    l_nbre := plateforme_api.plateforme_update(
                p_id_plateforme  => l_id_plateforme,
                p_nom_plateforme => 'Nom après',
                p_test           => c_test);

    -- assert
    ut.expect(l_nbre).to_equal(1);
    SELECT nom_plateforme
      INTO l_nom
      FROM plateforme
     WHERE id_plateforme = l_id_plateforme;
    ut.expect(l_nom).to_equal('Nom après');
  END plateforme_update_valide;

  PROCEDURE plateforme_update_introuvable IS
    l_nbre NUMBER;
    l_code NUMBER;
  BEGIN
    -- act
    BEGIN
      l_nbre := plateforme_api.plateforme_update(
                  p_id_plateforme  => id_plateforme_inexistant,
                  p_nom_plateforme => 'Fantôme',
                  p_test           => c_test);
    EXCEPTION
      WHEN api_erreurs.e_introuvable THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20001
    ut.expect(l_code).to_equal(api_erreurs.c_introuvable);
  END plateforme_update_introuvable;

  PROCEDURE plateforme_delete_valide IS
    l_id_plateforme plateforme.id_plateforme%TYPE;
    l_nbre          NUMBER;
    l_compte        NUMBER;
  BEGIN
    -- arrange
    l_id_plateforme := creer_plateforme;

    -- act
    l_nbre := plateforme_api.plateforme_delete(p_id_plateforme => l_id_plateforme, p_test => c_test);

    -- assert
    ut.expect(l_nbre).to_equal(1);
    SELECT COUNT(*)
      INTO l_compte
      FROM plateforme
     WHERE id_plateforme = l_id_plateforme;
    ut.expect(l_compte).to_equal(0);
  END plateforme_delete_valide;

  PROCEDURE plateforme_delete_associee IS
    l_id_plateforme plateforme.id_plateforme%TYPE;
    l_id_genre      genre.id_genre%TYPE;
    l_id_concepteur concepteur.id_concepteur%TYPE;
    l_id_jeu        jeu.id_jeu%TYPE;
    l_nbre          NUMBER;
    l_code          NUMBER;
  BEGIN
    -- arrange : un jeu est associé à la plateforme
    l_id_plateforme := creer_plateforme;
    INSERT INTO genre (nom_genre)
    VALUES ('Genre de test')
    RETURNING id_genre INTO l_id_genre;
    INSERT INTO concepteur (nom_concepteur)
    VALUES ('Concepteur de test')
    RETURNING id_concepteur INTO l_id_concepteur;
    INSERT INTO jeu (titre, prix, genre_id_genre, concepteur_id_concepteur)
    VALUES ('Jeu de test', 10, l_id_genre, l_id_concepteur)
    RETURNING id_jeu INTO l_id_jeu;
    INSERT INTO jeu_plateforme (jeu_id_jeu, plateforme_id_plateforme)
    VALUES (l_id_jeu, l_id_plateforme);

    -- act
    BEGIN
      l_nbre := plateforme_api.plateforme_delete(p_id_plateforme => l_id_plateforme, p_test => c_test);
    EXCEPTION
      WHEN api_erreurs.e_conflit THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20003
    ut.expect(l_code).to_equal(api_erreurs.c_conflit);
  END plateforme_delete_associee;

  PROCEDURE plateforme_select_par_id IS
    l_id_plateforme plateforme.id_plateforme%TYPE;
    l_json          VARCHAR2(4000);
  BEGIN
    -- arrange
    l_id_plateforme := creer_plateforme('Plateforme lue');

    -- act
    l_json := plateforme_api.plateforme_select(p_id_plateforme => l_id_plateforme);

    -- assert : une seule plateforme, celle qui a été créée
    ut.expect(contient(l_json, '"taille":1,')).to_equal(1);
    ut.expect(contient(l_json, 'Plateforme lue')).to_equal(1);
  END plateforme_select_par_id;

  PROCEDURE plateforme_select_introuvable IS
    l_json VARCHAR2(4000);
    l_code NUMBER;
  BEGIN
    -- act
    BEGIN
      l_json := plateforme_api.plateforme_select(p_id_plateforme => id_plateforme_inexistant);
    EXCEPTION
      WHEN api_erreurs.e_introuvable THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20001
    ut.expect(l_code).to_equal(api_erreurs.c_introuvable);
  END plateforme_select_introuvable;
END plateforme_api_test;
/
