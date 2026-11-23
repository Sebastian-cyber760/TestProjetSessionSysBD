---- API PL/SQL DE L'ENTITÉ JEU : SPÉCIFICATION ----
CREATE OR REPLACE PACKAGE jeu_api AS
  /**
   * API PL/SQL de l'entité JEU, l'entité centrale de l'analyse préliminaire.
   * Architecture SmartDB (Leçon 9) : le serveur Node.js n'écrit aucune requête
   * SQL; il appelle seulement les quatre fonctions de ce package.
   *
   *   Fonction   | Appel REST (livrable 4)      | Cas d'utilisation de l'analyse
   *   jeu_insert | POST   /jeux                 | CU-06 Ajouter un jeu
   *   jeu_update | PUT    /jeux/{id}            | CU-07 Modifier un jeu
   *   jeu_delete | DELETE /jeux/{id}            | CU-08 Supprimer un jeu
   *   jeu_select | GET    /jeux                 | CU-03 Afficher la liste des jeux (debut, limite)
   *              | GET    /jeux/{id}            | CU-04 Rechercher un jeu par son ID
   *              |                              | CU-05 Consulter les détails d'un jeu
   *
   * Transactions (Leçon 9, diapos 33 à 39) : quand p_test vaut 'N', la valeur par
   * défaut, une fonction d'écriture confirme son travail (COMMIT) ou, en cas
   * d'erreur, l'annule (ROLLBACK). Les tests unitaires passent 'O' : la fonction ne
   * fait ni COMMIT ni ROLLBACK, et utPLSQL annule tout après chaque test. Une erreur
   * est journalisée avec Logger, puis relancée avec un code du package api_erreurs
   * (-20001 = 404, -20002 = 400, -20003 = 409).
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   */

  -- Nombre maximal de jeux par page dans jeu_select : le JSON retourné doit
  -- tenir dans le VARCHAR2(4000) du squelette de la Leçon 9 (diapo 31).
  c_limite_max CONSTANT PLS_INTEGER := 10;

  /**
   * Ajoute un jeu au catalogue (CU-06) et retourne son identifiant.
   * Si p_id_jeu est NULL, la BD assigne l'identifiant (colonne identité) et la
   * clause RETURNING le récupère sans SELECT supplémentaire.
   *
   * @example l_id_jeu := jeu_api.jeu_insert(p_titre => 'Zelda', p_prix => 89.99,
   *                        p_genre_id_genre => 2, p_concepteur_id_concepteur => 3);
   *
   * @issue Les plateformes du jeu (table jeu_plateforme) ne sont pas gérées par l'API.
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_id_jeu: identifiant voulu (facultatif, NULL = assigné par la BD)
   * @param p_titre: titre du jeu (obligatoire, 100 caractères au maximum)
   * @param p_description: description du jeu (facultative, 500 caractères au maximum)
   * @param p_date_sortie: date de sortie du jeu (facultative)
   * @param p_prix: prix du jeu (obligatoire, positif ou nul)
   * @param p_genre_id_genre: identifiant du genre (obligatoire, doit exister)
   * @param p_concepteur_id_concepteur: identifiant du concepteur (obligatoire, doit exister)
   * @param p_test: paramètre pour ne pas sauvegarder les tests, si 'N' alors commit
   * @return id_jeu: la clé primaire du jeu créé
   * @throws -20002 (400) donnée absente ou invalide, genre ou concepteur inexistant, texte trop long
   * @throws -20003 (409) l'identifiant p_id_jeu est déjà utilisé
   */
  FUNCTION jeu_insert (
    p_id_jeu                   IN jeu.id_jeu%TYPE                   DEFAULT NULL,
    p_titre                    IN jeu.titre%TYPE                    DEFAULT NULL,
    p_description              IN jeu.description%TYPE              DEFAULT NULL,
    p_date_sortie              IN jeu.date_sortie%TYPE              DEFAULT NULL,
    p_prix                     IN jeu.prix%TYPE                     DEFAULT NULL,
    p_genre_id_genre           IN jeu.genre_id_genre%TYPE           DEFAULT NULL,
    p_concepteur_id_concepteur IN jeu.concepteur_id_concepteur%TYPE DEFAULT NULL,
    p_test                     IN VARCHAR2                          DEFAULT 'N'
  ) RETURN NUMBER;

  /**
   * Modifie un jeu existant (CU-07). Un paramètre NULL garde la valeur actuelle
   * de la colonne (COALESCE) : on peut donc changer seulement le prix, par exemple.
   *
   * @example l_nbre := jeu_api.jeu_update(p_id_jeu => 1, p_prix => 29.99);
   *
   * @issue Avec COALESCE, on ne peut pas remettre la description ou la date de sortie à NULL.
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_id_jeu: identifiant du jeu à modifier (obligatoire)
   * @param p_titre: nouveau titre (NULL = inchangé)
   * @param p_description: nouvelle description (NULL = inchangée)
   * @param p_date_sortie: nouvelle date de sortie (NULL = inchangée)
   * @param p_prix: nouveau prix (NULL = inchangé, positif ou nul)
   * @param p_genre_id_genre: nouveau genre (NULL = inchangé, doit exister)
   * @param p_concepteur_id_concepteur: nouveau concepteur (NULL = inchangé, doit exister)
   * @param p_test: paramètre pour ne pas sauvegarder les tests, si 'N' alors commit
   * @return nbre_rangees: le nombre de rangées modifiées (1)
   * @throws -20001 (404) le jeu n'existe pas
   * @throws -20002 (400) identifiant invalide, prix négatif, genre ou concepteur inexistant,
   *         ou texte trop long
   */
  FUNCTION jeu_update (
    p_id_jeu                   IN jeu.id_jeu%TYPE                   DEFAULT NULL,
    p_titre                    IN jeu.titre%TYPE                    DEFAULT NULL,
    p_description              IN jeu.description%TYPE              DEFAULT NULL,
    p_date_sortie              IN jeu.date_sortie%TYPE              DEFAULT NULL,
    p_prix                     IN jeu.prix%TYPE                     DEFAULT NULL,
    p_genre_id_genre           IN jeu.genre_id_genre%TYPE           DEFAULT NULL,
    p_concepteur_id_concepteur IN jeu.concepteur_id_concepteur%TYPE DEFAULT NULL,
    p_test                     IN VARCHAR2                          DEFAULT 'N'
  ) RETURN NUMBER;

  /**
   * Supprime un jeu et ses associations avec les plateformes (CU-08).
   *
   * @example l_nbre := jeu_api.jeu_delete(p_id_jeu => 4);
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_id_jeu: identifiant du jeu à supprimer (obligatoire)
   * @param p_test: paramètre pour ne pas sauvegarder les tests, si 'N' alors commit
   * @return nbre_rangees: le nombre de jeux supprimés (1)
   * @throws -20001 (404) le jeu n'existe pas
   * @throws -20002 (400) identifiant absent ou invalide
   * @throws -20003 (409) d'autres données (ajoutées plus tard au modèle) utilisent encore le jeu
   */
  FUNCTION jeu_delete (
    p_id_jeu IN jeu.id_jeu%TYPE DEFAULT NULL,
    p_test   IN VARCHAR2        DEFAULT 'N'
  ) RETURN NUMBER;

  /**
   * Retourne un objet JSON avec une page de jeux (CU-03) ou un seul jeu (CU-04).
   * Chaque jeu contient aussi le nom de son genre, le nom de son concepteur et
   * ses plateformes dans un tableau JSON (fiche détaillée du CU-05). Les jeux sont
   * triés par identifiant (squelette de la Leçon 9, diapos 31 et 32).
   * Format : {"limite":5,"debut":0,"taille":2,"resultats":[{"ID_JEU":1,"TITRE":"GTA V",...,
   *          "PLATEFORMES":["PlayStation 5","Xbox Series X","PC"]},...]}
   *   limite    : nombre maximal de jeux demandé
   *   debut     : position de départ (0 = premier jeu)
   *   taille    : nombre de jeux retournés dans cette page
   *   resultats : tableau des jeux (null si la page est vide : CU-03 « Aucun jeu enregistré »)
   *
   * @example SELECT jeu_api.jeu_select(p_id_jeu => 1) FROM dual;
   *
   * @issue Le JSON retourné doit tenir dans 4000 octets (VARCHAR2(4000) du squelette de
   *        la Leçon 9, diapo 31) : une page de jeux aux longues descriptions peut
   *        dépasser cette taille.
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   * @param p_id_jeu: identifiant du jeu (NULL = tous les jeux, page par page)
   * @param p_debut: position de départ de la page (0 par défaut, ignorée si p_id_jeu est fourni)
   * @param p_limite: nombre maximal de jeux dans la page (5 par défaut, de 1 à c_limite_max)
   * @return json: l'objet JSON décrit ci-dessus
   * @throws -20001 (404) aucun jeu ne porte l'identifiant p_id_jeu
   * @throws -20002 (400) identifiant, début ou limite invalide
   */
  FUNCTION jeu_select (
    p_id_jeu IN jeu.id_jeu%TYPE DEFAULT NULL,
    p_debut  IN PLS_INTEGER     DEFAULT 0,
    p_limite IN PLS_INTEGER     DEFAULT 5
  ) RETURN VARCHAR2;
END jeu_api;
/
