---- TESTS UNITAIRES DE concepteur_api (utPLSQL) : CORPS ----
CREATE OR REPLACE PACKAGE BODY concepteur_api_test AS
  -- Valeur de p_test pour les appels de l'API : 'O' = mode test, ni COMMIT ni ROLLBACK.
  c_test CONSTANT VARCHAR2(1) := 'O';

  ---------------------------------------------------------------------------
  -- Outils de préparation (arrange) et de vérification, absents de la spécification
  ---------------------------------------------------------------------------

  /**
   * Crée un concepteur de test (identifiant assigné par la BD).
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_nom_concepteur: nom du concepteur de test
   * @return id_concepteur: l'identifiant du concepteur créé
   */
  FUNCTION creer_concepteur (
    p_nom_concepteur IN concepteur.nom_concepteur%TYPE DEFAULT 'Concepteur de test'
  ) RETURN concepteur.id_concepteur%TYPE IS
    l_id_concepteur concepteur.id_concepteur%TYPE;
  BEGIN
    INSERT INTO concepteur (nom_concepteur, pays)
    VALUES (p_nom_concepteur, 'Canada')
    RETURNING id_concepteur INTO l_id_concepteur;
    RETURN l_id_concepteur;
  END creer_concepteur;

  /**
   * Retourne un identifiant de concepteur qui n'existe pas (le plus grand + 1).
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @return id_concepteur: un identifiant inutilisé
   */
  FUNCTION id_concepteur_inexistant RETURN concepteur.id_concepteur%TYPE IS
    l_id_concepteur concepteur.id_concepteur%TYPE;
  BEGIN
    SELECT COALESCE(MAX(id_concepteur), 0) + 1
      INTO l_id_concepteur
      FROM concepteur;
    RETURN l_id_concepteur;
  END id_concepteur_inexistant;

  /**
   * Indique si le JSON retourné par concepteur_select contient un morceau de texte,
   * par exemple '"taille":1,' (opérateur LIKE, Leçon 6).
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-08
   * @param p_json: JSON retourné par concepteur_select
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

  PROCEDURE concepteur_insert_valide IS
    l_id_concepteur concepteur.id_concepteur%TYPE;
    l_compte        NUMBER;
    rec_concepteur  concepteur%ROWTYPE;
  BEGIN
    -- act : aucun identifiant fourni, la BD l'assigne
    l_id_concepteur := concepteur_api.concepteur_insert(
                         p_nom_concepteur => 'Capcom',
                         p_pays           => 'Japon',
                         p_test           => c_test);

    -- assert : le concepteur existe, avec les valeurs reçues
    SELECT COUNT(*)
      INTO l_compte
      FROM concepteur
     WHERE id_concepteur = l_id_concepteur;
    ut.expect(l_compte).to_equal(1);
    SELECT *
      INTO rec_concepteur
      FROM concepteur
     WHERE id_concepteur = l_id_concepteur;
    ut.expect(rec_concepteur.nom_concepteur).to_equal('Capcom');
    ut.expect(rec_concepteur.pays).to_equal('Japon');
  END concepteur_insert_valide;

  PROCEDURE concepteur_insert_nom_absent IS
    l_id_concepteur concepteur.id_concepteur%TYPE;
    l_code          NUMBER;
  BEGIN
    -- act : sous-bloc (Leçon 7, diapo 32) qui attrape l'erreur attendue
    BEGIN
      l_id_concepteur := concepteur_api.concepteur_insert(
                           p_nom_concepteur => NULL,
                           p_pays           => 'Canada',
                           p_test           => c_test);
    EXCEPTION
      WHEN api_erreurs.e_donnee_invalide THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20002
    ut.expect(l_code).to_equal(api_erreurs.c_donnee_invalide);
  END concepteur_insert_nom_absent;

  PROCEDURE concepteur_insert_id_existant IS
    l_id_existant   concepteur.id_concepteur%TYPE;
    l_id_concepteur concepteur.id_concepteur%TYPE;
    l_code          NUMBER;
  BEGIN
    -- arrange
    l_id_existant := creer_concepteur;

    -- act : même identifiant
    BEGIN
      l_id_concepteur := concepteur_api.concepteur_insert(
                           p_id_concepteur  => l_id_existant,
                           p_nom_concepteur => 'Doublon',
                           p_test           => c_test);
    EXCEPTION
      WHEN api_erreurs.e_conflit THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20003
    ut.expect(l_code).to_equal(api_erreurs.c_conflit);
  END concepteur_insert_id_existant;

  PROCEDURE concepteur_update_valide IS
    l_id_concepteur concepteur.id_concepteur%TYPE;
    l_nbre          NUMBER;
    rec_concepteur  concepteur%ROWTYPE;
  BEGIN
    -- arrange
    l_id_concepteur := creer_concepteur('Studio de test');

    -- act : seulement le pays
    l_nbre := concepteur_api.concepteur_update(
                p_id_concepteur => l_id_concepteur,
                p_pays          => 'France',
                p_test          => c_test);

    -- assert
    ut.expect(l_nbre).to_equal(1);
    SELECT *
      INTO rec_concepteur
      FROM concepteur
     WHERE id_concepteur = l_id_concepteur;
    ut.expect(rec_concepteur.pays).to_equal('France');
    ut.expect(rec_concepteur.nom_concepteur).to_equal('Studio de test');  -- inchangé (COALESCE)
  END concepteur_update_valide;

  PROCEDURE concepteur_update_introuvable IS
    l_nbre NUMBER;
    l_code NUMBER;
  BEGIN
    -- act
    BEGIN
      l_nbre := concepteur_api.concepteur_update(
                  p_id_concepteur => id_concepteur_inexistant,
                  p_pays          => 'Canada',
                  p_test          => c_test);
    EXCEPTION
      WHEN api_erreurs.e_introuvable THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20001
    ut.expect(l_code).to_equal(api_erreurs.c_introuvable);
  END concepteur_update_introuvable;

  PROCEDURE concepteur_delete_valide IS
    l_id_concepteur concepteur.id_concepteur%TYPE;
    l_nbre          NUMBER;
    l_compte        NUMBER;
  BEGIN
    -- arrange
    l_id_concepteur := creer_concepteur;

    -- act
    l_nbre := concepteur_api.concepteur_delete(p_id_concepteur => l_id_concepteur, p_test => c_test);

    -- assert
    ut.expect(l_nbre).to_equal(1);
    SELECT COUNT(*)
      INTO l_compte
      FROM concepteur
     WHERE id_concepteur = l_id_concepteur;
    ut.expect(l_compte).to_equal(0);
  END concepteur_delete_valide;

  PROCEDURE concepteur_delete_utilise IS
    l_id_concepteur concepteur.id_concepteur%TYPE;
    l_id_genre      genre.id_genre%TYPE;
    l_nbre          NUMBER;
    l_code          NUMBER;
  BEGIN
    -- arrange : un jeu est lié au concepteur
    l_id_concepteur := creer_concepteur;
    INSERT INTO genre (nom_genre)
    VALUES ('Genre de test')
    RETURNING id_genre INTO l_id_genre;
    INSERT INTO jeu (titre, prix, genre_id_genre, concepteur_id_concepteur)
    VALUES ('Jeu de test', 10, l_id_genre, l_id_concepteur);

    -- act
    BEGIN
      l_nbre := concepteur_api.concepteur_delete(p_id_concepteur => l_id_concepteur, p_test => c_test);
    EXCEPTION
      WHEN api_erreurs.e_conflit THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20003
    ut.expect(l_code).to_equal(api_erreurs.c_conflit);
  END concepteur_delete_utilise;

  PROCEDURE concepteur_select_par_id IS
    l_id_concepteur concepteur.id_concepteur%TYPE;
    l_json          VARCHAR2(4000);
  BEGIN
    -- arrange
    l_id_concepteur := creer_concepteur('Concepteur lu');

    -- act
    l_json := concepteur_api.concepteur_select(p_id_concepteur => l_id_concepteur);

    -- assert : un seul concepteur, celui qui a été créé
    ut.expect(contient(l_json, '"taille":1,')).to_equal(1);
    ut.expect(contient(l_json, 'Concepteur lu')).to_equal(1);
  END concepteur_select_par_id;

  PROCEDURE concepteur_select_introuvable IS
    l_json VARCHAR2(4000);
    l_code NUMBER;
  BEGIN
    -- act
    BEGIN
      l_json := concepteur_api.concepteur_select(p_id_concepteur => id_concepteur_inexistant);
    EXCEPTION
      WHEN api_erreurs.e_introuvable THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20001
    ut.expect(l_code).to_equal(api_erreurs.c_introuvable);
  END concepteur_select_introuvable;
END concepteur_api_test;
/
