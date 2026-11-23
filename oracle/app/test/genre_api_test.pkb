---- TESTS UNITAIRES DE genre_api (utPLSQL) : CORPS ----
CREATE OR REPLACE PACKAGE BODY genre_api_test AS
  -- Valeur de p_test pour les appels de l'API : 'O' = mode test, ni COMMIT ni ROLLBACK.
  c_test CONSTANT VARCHAR2(1) := 'O';

  ---------------------------------------------------------------------------
  -- Outils de préparation (arrange) et de vérification, absents de la spécification
  ---------------------------------------------------------------------------

  /**
   * Crée un genre de test (identifiant assigné par la BD).
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_nom_genre: nom du genre de test
   * @return id_genre: l'identifiant du genre créé
   */
  FUNCTION creer_genre (
    p_nom_genre IN genre.nom_genre%TYPE DEFAULT 'Genre de test'
  ) RETURN genre.id_genre%TYPE IS
    l_id_genre genre.id_genre%TYPE;
  BEGIN
    INSERT INTO genre (nom_genre, description)
    VALUES (p_nom_genre, 'Description de test')
    RETURNING id_genre INTO l_id_genre;
    RETURN l_id_genre;
  END creer_genre;

  /**
   * Retourne un identifiant de genre qui n'existe pas (le plus grand + 1).
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @return id_genre: un identifiant inutilisé
   */
  FUNCTION id_genre_inexistant RETURN genre.id_genre%TYPE IS
    l_id_genre genre.id_genre%TYPE;
  BEGIN
    SELECT COALESCE(MAX(id_genre), 0) + 1
      INTO l_id_genre
      FROM genre;
    RETURN l_id_genre;
  END id_genre_inexistant;

  /**
   * Indique si le JSON retourné par genre_select contient un morceau de texte,
   * par exemple '"taille":1,' (opérateur LIKE, Leçon 6).
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-08
   * @param p_json: JSON retourné par genre_select
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

  PROCEDURE genre_insert_valide IS
    l_id_genre genre.id_genre%TYPE;
    l_compte   NUMBER;
    rec_genre  genre%ROWTYPE;
  BEGIN
    -- act : aucun identifiant fourni, la BD l'assigne
    l_id_genre := genre_api.genre_insert(
                    p_nom_genre   => 'Course',
                    p_description => 'Jeux de course',
                    p_test        => c_test);

    -- assert : le genre existe, avec les valeurs reçues
    SELECT COUNT(*)
      INTO l_compte
      FROM genre
     WHERE id_genre = l_id_genre;
    ut.expect(l_compte).to_equal(1);
    SELECT *
      INTO rec_genre
      FROM genre
     WHERE id_genre = l_id_genre;
    ut.expect(rec_genre.nom_genre).to_equal('Course');
    ut.expect(rec_genre.description).to_equal('Jeux de course');
  END genre_insert_valide;

  PROCEDURE genre_insert_nom_absent IS
    l_id_genre genre.id_genre%TYPE;
    l_code     NUMBER;
  BEGIN
    -- act : sous-bloc (Leçon 7, diapo 32) qui attrape l'erreur attendue
    BEGIN
      l_id_genre := genre_api.genre_insert(
                      p_nom_genre   => NULL,
                      p_description => 'Genre sans nom',
                      p_test        => c_test);
    EXCEPTION
      WHEN api_erreurs.e_donnee_invalide THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20002
    ut.expect(l_code).to_equal(api_erreurs.c_donnee_invalide);
  END genre_insert_nom_absent;

  PROCEDURE genre_insert_id_existant IS
    l_id_existant genre.id_genre%TYPE;
    l_id_genre    genre.id_genre%TYPE;
    l_code        NUMBER;
  BEGIN
    -- arrange
    l_id_existant := creer_genre;

    -- act : même identifiant
    BEGIN
      l_id_genre := genre_api.genre_insert(
                      p_id_genre  => l_id_existant,
                      p_nom_genre => 'Doublon',
                      p_test      => c_test);
    EXCEPTION
      WHEN api_erreurs.e_conflit THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20003
    ut.expect(l_code).to_equal(api_erreurs.c_conflit);
  END genre_insert_id_existant;

  PROCEDURE genre_update_valide IS
    l_id_genre genre.id_genre%TYPE;
    l_nbre     NUMBER;
    rec_genre  genre%ROWTYPE;
  BEGIN
    -- arrange
    l_id_genre := creer_genre('Nom avant');

    -- act : seulement le nom
    l_nbre := genre_api.genre_update(
                p_id_genre  => l_id_genre,
                p_nom_genre => 'Nom après',
                p_test      => c_test);

    -- assert
    ut.expect(l_nbre).to_equal(1);
    SELECT *
      INTO rec_genre
      FROM genre
     WHERE id_genre = l_id_genre;
    ut.expect(rec_genre.nom_genre).to_equal('Nom après');
    ut.expect(rec_genre.description).to_equal('Description de test');  -- inchangée (COALESCE)
  END genre_update_valide;

  PROCEDURE genre_update_introuvable IS
    l_nbre NUMBER;
    l_code NUMBER;
  BEGIN
    -- act
    BEGIN
      l_nbre := genre_api.genre_update(
                  p_id_genre  => id_genre_inexistant,
                  p_nom_genre => 'Fantôme',
                  p_test      => c_test);
    EXCEPTION
      WHEN api_erreurs.e_introuvable THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20001
    ut.expect(l_code).to_equal(api_erreurs.c_introuvable);
  END genre_update_introuvable;

  PROCEDURE genre_delete_valide IS
    l_id_genre genre.id_genre%TYPE;
    l_nbre     NUMBER;
    l_compte   NUMBER;
  BEGIN
    -- arrange
    l_id_genre := creer_genre;

    -- act
    l_nbre := genre_api.genre_delete(p_id_genre => l_id_genre, p_test => c_test);

    -- assert
    ut.expect(l_nbre).to_equal(1);
    SELECT COUNT(*)
      INTO l_compte
      FROM genre
     WHERE id_genre = l_id_genre;
    ut.expect(l_compte).to_equal(0);
  END genre_delete_valide;

  PROCEDURE genre_delete_utilise IS
    l_id_genre      genre.id_genre%TYPE;
    l_id_concepteur concepteur.id_concepteur%TYPE;
    l_nbre          NUMBER;
    l_code          NUMBER;
  BEGIN
    -- arrange : un jeu utilise le genre
    l_id_genre := creer_genre;
    INSERT INTO concepteur (nom_concepteur)
    VALUES ('Concepteur de test')
    RETURNING id_concepteur INTO l_id_concepteur;
    INSERT INTO jeu (titre, prix, genre_id_genre, concepteur_id_concepteur)
    VALUES ('Jeu de test', 10, l_id_genre, l_id_concepteur);

    -- act
    BEGIN
      l_nbre := genre_api.genre_delete(p_id_genre => l_id_genre, p_test => c_test);
    EXCEPTION
      WHEN api_erreurs.e_conflit THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20003
    ut.expect(l_code).to_equal(api_erreurs.c_conflit);
  END genre_delete_utilise;

  PROCEDURE genre_select_par_id IS
    l_id_genre genre.id_genre%TYPE;
    l_json     VARCHAR2(4000);
  BEGIN
    -- arrange
    l_id_genre := creer_genre('Genre lu');

    -- act
    l_json := genre_api.genre_select(p_id_genre => l_id_genre);

    -- assert : un seul genre, celui qui a été créé
    ut.expect(contient(l_json, '"taille":1,')).to_equal(1);
    ut.expect(contient(l_json, 'Genre lu')).to_equal(1);
  END genre_select_par_id;

  PROCEDURE genre_select_introuvable IS
    l_json VARCHAR2(4000);
    l_code NUMBER;
  BEGIN
    -- act
    BEGIN
      l_json := genre_api.genre_select(p_id_genre => id_genre_inexistant);
    EXCEPTION
      WHEN api_erreurs.e_introuvable THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20001
    ut.expect(l_code).to_equal(api_erreurs.c_introuvable);
  END genre_select_introuvable;
END genre_api_test;
/
