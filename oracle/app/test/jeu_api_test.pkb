---- TESTS UNITAIRES DE jeu_api (utPLSQL) : CORPS ----
CREATE OR REPLACE PACKAGE BODY jeu_api_test AS
  -- Valeur de p_test pour les appels de l'API : 'O' = mode test, ni COMMIT ni ROLLBACK.
  -- utPLSQL peut alors tout annuler après chaque test.
  c_test CONSTANT VARCHAR2(1) := 'O';

  ---------------------------------------------------------------------------
  -- Outils de préparation (arrange) et de vérification. Ils ne sont pas dans la
  -- spécification : utPLSQL ne les exécute donc pas comme des tests.
  ---------------------------------------------------------------------------

  /**
   * Crée un genre de test (identifiant assigné par la BD).
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-08
   * @return id_genre: l'identifiant du genre créé
   */
  FUNCTION creer_genre RETURN genre.id_genre%TYPE IS
    l_id_genre genre.id_genre%TYPE;
  BEGIN
    INSERT INTO genre (nom_genre, description)
    VALUES ('Genre de test', 'Créé par jeu_api_test')
    RETURNING id_genre INTO l_id_genre;
    RETURN l_id_genre;
  END creer_genre;

  /**
   * Crée un concepteur de test (identifiant assigné par la BD).
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-08
   * @return id_concepteur: l'identifiant du concepteur créé
   */
  FUNCTION creer_concepteur RETURN concepteur.id_concepteur%TYPE IS
    l_id_concepteur concepteur.id_concepteur%TYPE;
  BEGIN
    INSERT INTO concepteur (nom_concepteur, pays)
    VALUES ('Concepteur de test', 'Canada')
    RETURNING id_concepteur INTO l_id_concepteur;
    RETURN l_id_concepteur;
  END creer_concepteur;

  /**
   * Crée un jeu de test complet, avec son propre genre et son propre concepteur.
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_titre: titre du jeu de test
   * @return id_jeu: l'identifiant du jeu créé
   */
  FUNCTION creer_jeu (
    p_titre IN jeu.titre%TYPE DEFAULT 'Jeu de test'
  ) RETURN jeu.id_jeu%TYPE IS
    l_id_genre      genre.id_genre%TYPE;
    l_id_concepteur concepteur.id_concepteur%TYPE;
    l_id_jeu        jeu.id_jeu%TYPE;
  BEGIN
    l_id_genre      := creer_genre;
    l_id_concepteur := creer_concepteur;

    INSERT INTO jeu (titre, description, date_sortie, prix,
                     genre_id_genre, concepteur_id_concepteur)
    VALUES (p_titre, 'Description de test', DATE '2025-01-15', 49.99,
            l_id_genre, l_id_concepteur)
    RETURNING id_jeu INTO l_id_jeu;

    RETURN l_id_jeu;
  END creer_jeu;

  /**
   * Crée une plateforme de test et l'associe au jeu.
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_id_jeu: identifiant du jeu
   * @param p_nom_plateforme: nom de la plateforme à créer
   */
  PROCEDURE associer_plateforme (
    p_id_jeu         IN jeu.id_jeu%TYPE,
    p_nom_plateforme IN plateforme.nom_plateforme%TYPE
  ) IS
    l_id_plateforme plateforme.id_plateforme%TYPE;
  BEGIN
    INSERT INTO plateforme (nom_plateforme)
    VALUES (p_nom_plateforme)
    RETURNING id_plateforme INTO l_id_plateforme;

    INSERT INTO jeu_plateforme (jeu_id_jeu, plateforme_id_plateforme)
    VALUES (p_id_jeu, l_id_plateforme);
  END associer_plateforme;

  /**
   * Retourne un identifiant de jeu qui n'existe pas (le plus grand + 1).
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @return id_jeu: un identifiant inutilisé
   */
  FUNCTION id_jeu_inexistant RETURN jeu.id_jeu%TYPE IS
    l_id_jeu jeu.id_jeu%TYPE;
  BEGIN
    SELECT COALESCE(MAX(id_jeu), 0) + 1
      INTO l_id_jeu
      FROM jeu;
    RETURN l_id_jeu;
  END id_jeu_inexistant;

  /**
   * Indique si le JSON retourné par jeu_select contient un morceau de texte,
   * par exemple '"taille":1,' (opérateur LIKE, Leçon 6).
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-08
   * @param p_json: JSON retourné par jeu_select
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
  -- jeu_insert (CU-06)
  ---------------------------------------------------------------------------

  PROCEDURE jeu_insert_valide IS
    l_id_genre      genre.id_genre%TYPE;
    l_id_concepteur concepteur.id_concepteur%TYPE;
    l_id_jeu        jeu.id_jeu%TYPE;
    l_compte        NUMBER;
    rec_jeu         jeu%ROWTYPE;
  BEGIN
    -- arrange
    l_id_genre      := creer_genre;
    l_id_concepteur := creer_concepteur;

    -- act : aucun identifiant fourni, la BD l'assigne
    l_id_jeu := jeu_api.jeu_insert(
                  p_titre                    => 'Jeu ajouté par le test',
                  p_description              => 'Description du jeu ajouté',
                  p_date_sortie              => DATE '2026-11-01',
                  p_prix                     => 59.99,
                  p_genre_id_genre           => l_id_genre,
                  p_concepteur_id_concepteur => l_id_concepteur,
                  p_test                     => c_test);

    -- assert : le jeu existe, avec les valeurs reçues
    SELECT COUNT(*)
      INTO l_compte
      FROM jeu
     WHERE id_jeu = l_id_jeu;
    ut.expect(l_compte).to_equal(1);
    SELECT *
      INTO rec_jeu
      FROM jeu
     WHERE id_jeu = l_id_jeu;
    ut.expect(rec_jeu.titre).to_equal('Jeu ajouté par le test');
    ut.expect(rec_jeu.prix).to_equal(59.99);
    ut.expect(rec_jeu.genre_id_genre).to_equal(l_id_genre);
    ut.expect(rec_jeu.concepteur_id_concepteur).to_equal(l_id_concepteur);
  END jeu_insert_valide;

  PROCEDURE jeu_insert_titre_absent IS
    l_id_genre      genre.id_genre%TYPE;
    l_id_concepteur concepteur.id_concepteur%TYPE;
    l_id_jeu        jeu.id_jeu%TYPE;
    l_code          NUMBER;
  BEGIN
    -- arrange
    l_id_genre      := creer_genre;
    l_id_concepteur := creer_concepteur;

    -- act : aucun titre; un sous-bloc (Leçon 7, diapo 32) attrape l'erreur attendue
    BEGIN
      l_id_jeu := jeu_api.jeu_insert(
                    p_titre                    => NULL,
                    p_prix                     => 10,
                    p_genre_id_genre           => l_id_genre,
                    p_concepteur_id_concepteur => l_id_concepteur,
                    p_test                     => c_test);
    EXCEPTION
      WHEN api_erreurs.e_donnee_invalide THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20002
    ut.expect(l_code).to_equal(api_erreurs.c_donnee_invalide);
  END jeu_insert_titre_absent;

  PROCEDURE jeu_insert_prix_negatif IS
    l_id_genre      genre.id_genre%TYPE;
    l_id_concepteur concepteur.id_concepteur%TYPE;
    l_id_jeu        jeu.id_jeu%TYPE;
    l_code          NUMBER;
  BEGIN
    -- arrange
    l_id_genre      := creer_genre;
    l_id_concepteur := creer_concepteur;

    -- act
    BEGIN
      l_id_jeu := jeu_api.jeu_insert(
                    p_titre                    => 'Jeu au prix négatif',
                    p_prix                     => -1,
                    p_genre_id_genre           => l_id_genre,
                    p_concepteur_id_concepteur => l_id_concepteur,
                    p_test                     => c_test);
    EXCEPTION
      WHEN api_erreurs.e_donnee_invalide THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20002
    ut.expect(l_code).to_equal(api_erreurs.c_donnee_invalide);
  END jeu_insert_prix_negatif;

  PROCEDURE jeu_insert_genre_inexistant IS
    l_id_concepteur concepteur.id_concepteur%TYPE;
    l_id_genre_faux genre.id_genre%TYPE;
    l_id_jeu        jeu.id_jeu%TYPE;
    l_code          NUMBER;
  BEGIN
    -- arrange : un concepteur valide et un identifiant de genre inutilisé
    l_id_concepteur := creer_concepteur;
    SELECT COALESCE(MAX(id_genre), 0) + 1
      INTO l_id_genre_faux
      FROM genre;

    -- act : la clé étrangère refuse le genre
    BEGIN
      l_id_jeu := jeu_api.jeu_insert(
                    p_titre                    => 'Jeu sans genre',
                    p_prix                     => 10,
                    p_genre_id_genre           => l_id_genre_faux,
                    p_concepteur_id_concepteur => l_id_concepteur,
                    p_test                     => c_test);
    EXCEPTION
      WHEN api_erreurs.e_donnee_invalide THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20002
    ut.expect(l_code).to_equal(api_erreurs.c_donnee_invalide);
  END jeu_insert_genre_inexistant;

  PROCEDURE jeu_insert_id_existant IS
    l_id_genre      genre.id_genre%TYPE;
    l_id_concepteur concepteur.id_concepteur%TYPE;
    l_id_existant   jeu.id_jeu%TYPE;
    l_id_jeu        jeu.id_jeu%TYPE;
    l_code          NUMBER;
  BEGIN
    -- arrange : un jeu existe déjà
    l_id_existant   := creer_jeu;
    l_id_genre      := creer_genre;
    l_id_concepteur := creer_concepteur;

    -- act : même identifiant
    BEGIN
      l_id_jeu := jeu_api.jeu_insert(
                    p_id_jeu                   => l_id_existant,
                    p_titre                    => 'Doublon',
                    p_prix                     => 10,
                    p_genre_id_genre           => l_id_genre,
                    p_concepteur_id_concepteur => l_id_concepteur,
                    p_test                     => c_test);
    EXCEPTION
      WHEN api_erreurs.e_conflit THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20003
    ut.expect(l_code).to_equal(api_erreurs.c_conflit);
  END jeu_insert_id_existant;

  ---------------------------------------------------------------------------
  -- jeu_update (CU-07)
  ---------------------------------------------------------------------------

  PROCEDURE jeu_update_valide IS
    l_id_jeu jeu.id_jeu%TYPE;
    l_nbre   NUMBER;
    rec_jeu  jeu%ROWTYPE;
  BEGIN
    -- arrange
    l_id_jeu := creer_jeu('Titre avant');

    -- act : seulement le titre et le prix; les autres paramètres restent NULL
    l_nbre := jeu_api.jeu_update(
                p_id_jeu => l_id_jeu,
                p_titre  => 'Titre après',
                p_prix   => 19.99,
                p_test   => c_test);

    -- assert
    ut.expect(l_nbre).to_equal(1);
    SELECT *
      INTO rec_jeu
      FROM jeu
     WHERE id_jeu = l_id_jeu;
    ut.expect(rec_jeu.titre).to_equal('Titre après');
    ut.expect(rec_jeu.prix).to_equal(19.99);
    ut.expect(rec_jeu.description).to_equal('Description de test');  -- inchangée (COALESCE)
    ut.expect(rec_jeu.date_sortie).to_equal(DATE '2025-01-15');       -- inchangée (COALESCE)
  END jeu_update_valide;

  PROCEDURE jeu_update_introuvable IS
    l_nbre NUMBER;
    l_code NUMBER;
  BEGIN
    -- act
    BEGIN
      l_nbre := jeu_api.jeu_update(
                  p_id_jeu => id_jeu_inexistant,
                  p_prix   => 10,
                  p_test   => c_test);
    EXCEPTION
      WHEN api_erreurs.e_introuvable THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20001
    ut.expect(l_code).to_equal(api_erreurs.c_introuvable);
  END jeu_update_introuvable;

  PROCEDURE jeu_update_prix_negatif IS
    l_id_jeu jeu.id_jeu%TYPE;
    l_nbre   NUMBER;
    l_code   NUMBER;
  BEGIN
    -- arrange
    l_id_jeu := creer_jeu;

    -- act
    BEGIN
      l_nbre := jeu_api.jeu_update(
                  p_id_jeu => l_id_jeu,
                  p_prix   => -5,
                  p_test   => c_test);
    EXCEPTION
      WHEN api_erreurs.e_donnee_invalide THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20002
    ut.expect(l_code).to_equal(api_erreurs.c_donnee_invalide);
  END jeu_update_prix_negatif;

  ---------------------------------------------------------------------------
  -- jeu_delete (CU-08)
  ---------------------------------------------------------------------------

  PROCEDURE jeu_delete_valide IS
    l_id_jeu jeu.id_jeu%TYPE;
    l_nbre   NUMBER;
    l_compte NUMBER;
  BEGIN
    -- arrange : un jeu associé à une plateforme
    l_id_jeu := creer_jeu;
    associer_plateforme(l_id_jeu, 'Plateforme de test');

    -- act
    l_nbre := jeu_api.jeu_delete(p_id_jeu => l_id_jeu, p_test => c_test);

    -- assert : le jeu et son association n'existent plus
    ut.expect(l_nbre).to_equal(1);
    SELECT COUNT(*)
      INTO l_compte
      FROM jeu
     WHERE id_jeu = l_id_jeu;
    ut.expect(l_compte).to_equal(0);
    SELECT COUNT(*)
      INTO l_compte
      FROM jeu_plateforme
     WHERE jeu_id_jeu = l_id_jeu;
    ut.expect(l_compte).to_equal(0);
  END jeu_delete_valide;

  PROCEDURE jeu_delete_introuvable IS
    l_nbre NUMBER;
    l_code NUMBER;
  BEGIN
    -- act
    BEGIN
      l_nbre := jeu_api.jeu_delete(p_id_jeu => id_jeu_inexistant, p_test => c_test);
    EXCEPTION
      WHEN api_erreurs.e_introuvable THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20001
    ut.expect(l_code).to_equal(api_erreurs.c_introuvable);
  END jeu_delete_introuvable;

  ---------------------------------------------------------------------------
  -- jeu_select (CU-03, CU-04 et CU-05)
  ---------------------------------------------------------------------------

  PROCEDURE jeu_select_liste IS
    l_id_jeu  jeu.id_jeu%TYPE;
    l_total   NUMBER;
    l_attendu NUMBER;
    l_json    VARCHAR2(4000);
  BEGIN
    -- arrange : au moins un jeu existe
    l_id_jeu := creer_jeu;
    SELECT COUNT(*)
      INTO l_total
      FROM jeu;

    -- act
    l_json := jeu_api.jeu_select(p_debut => 0, p_limite => jeu_api.c_limite_max);

    -- assert : taille = le plus petit nombre entre l_total et c_limite_max
    IF l_total < jeu_api.c_limite_max THEN
      l_attendu := l_total;
    ELSE
      l_attendu := jeu_api.c_limite_max;
    END IF;
    ut.expect(contient(l_json, '"limite":' || jeu_api.c_limite_max || ',')).to_equal(1);
    ut.expect(contient(l_json, '"debut":0,')).to_equal(1);
    ut.expect(contient(l_json, '"taille":' || l_attendu || ',')).to_equal(1);
  END jeu_select_liste;

  PROCEDURE jeu_select_liste_vide IS
    l_json VARCHAR2(4000);
  BEGIN
    -- arrange : aucun jeu (utPLSQL annule ces suppressions après le test)
    DELETE FROM jeu_plateforme;
    DELETE FROM jeu;

    -- act
    l_json := jeu_api.jeu_select(p_debut => 0);

    -- assert : page vide (squelette de la Leçon 9 : "resultats" est null)
    ut.expect(contient(l_json, '"taille":0,')).to_equal(1);
    ut.expect(contient(l_json, '"resultats":null')).to_equal(1);
  END jeu_select_liste_vide;

  PROCEDURE jeu_select_pagination IS
    l_id_jeu jeu.id_jeu%TYPE;
    l_total  NUMBER;
    l_json   VARCHAR2(4000);
  BEGIN
    -- arrange : au moins 3 jeux; créés en dernier, Jeu B et Jeu C reçoivent les
    -- plus grands identifiants (colonne identité)
    l_id_jeu := creer_jeu('Jeu A');
    l_id_jeu := creer_jeu('Jeu B');
    l_id_jeu := creer_jeu('Jeu C');
    SELECT COUNT(*)
      INTO l_total
      FROM jeu;

    -- act : la dernière page de 2 jeux (les jeux sont triés par identifiant)
    l_json := jeu_api.jeu_select(p_debut => l_total - 2, p_limite => 2);

    -- assert : Jeu B et Jeu C, mais pas Jeu A
    ut.expect(contient(l_json, '"debut":' || (l_total - 2) || ',')).to_equal(1);
    ut.expect(contient(l_json, '"taille":2,')).to_equal(1);
    ut.expect(contient(l_json, 'Jeu B')).to_equal(1);
    ut.expect(contient(l_json, 'Jeu C')).to_equal(1);
    ut.expect(contient(l_json, 'Jeu A')).to_equal(0);
  END jeu_select_pagination;

  PROCEDURE jeu_select_par_id IS
    l_id_jeu jeu.id_jeu%TYPE;
    l_json   VARCHAR2(4000);
  BEGIN
    -- arrange : un jeu associé à une plateforme
    l_id_jeu := creer_jeu('Jeu lu');
    associer_plateforme(l_id_jeu, 'Plateforme de test');

    -- act
    l_json := jeu_api.jeu_select(p_id_jeu => l_id_jeu);

    -- assert : la fiche détaillée du CU-05 (un seul jeu, avec son genre, son
    -- concepteur et sa plateforme)
    ut.expect(contient(l_json, '"taille":1,')).to_equal(1);
    ut.expect(contient(l_json, 'Jeu lu')).to_equal(1);
    ut.expect(contient(l_json, 'Genre de test')).to_equal(1);
    ut.expect(contient(l_json, 'Concepteur de test')).to_equal(1);
    ut.expect(contient(l_json, 'Plateforme de test')).to_equal(1);
  END jeu_select_par_id;

  PROCEDURE jeu_select_introuvable IS
    l_json VARCHAR2(4000);
    l_code NUMBER;
  BEGIN
    -- act
    BEGIN
      l_json := jeu_api.jeu_select(p_id_jeu => id_jeu_inexistant);
    EXCEPTION
      WHEN api_erreurs.e_introuvable THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20001
    ut.expect(l_code).to_equal(api_erreurs.c_introuvable);
  END jeu_select_introuvable;

  PROCEDURE jeu_select_id_invalide IS
    l_json VARCHAR2(4000);
    l_code NUMBER;
  BEGIN
    -- act
    BEGIN
      l_json := jeu_api.jeu_select(p_id_jeu => 0);
    EXCEPTION
      WHEN api_erreurs.e_donnee_invalide THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20002
    ut.expect(l_code).to_equal(api_erreurs.c_donnee_invalide);
  END jeu_select_id_invalide;

  PROCEDURE jeu_select_limite_invalide IS
    l_json VARCHAR2(4000);
    l_code NUMBER;
  BEGIN
    -- act
    BEGIN
      l_json := jeu_api.jeu_select(p_limite => jeu_api.c_limite_max + 1);
    EXCEPTION
      WHEN api_erreurs.e_donnee_invalide THEN
        l_code := SQLCODE;
    END;

    -- assert : erreur -20002
    ut.expect(l_code).to_equal(api_erreurs.c_donnee_invalide);
  END jeu_select_limite_invalide;
END jeu_api_test;
/
