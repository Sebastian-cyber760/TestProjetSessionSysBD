---- TESTS UNITAIRES DE jeu_api (utPLSQL) : SPÉCIFICATION ----
CREATE OR REPLACE PACKAGE jeu_api_test AS
  --%suite(jeu_api : tests unitaires de l'API de l'entité JEU)

  /**
   * Tests unitaires de jeu_api avec utPLSQL (Leçon 9, diapos 60 à 63).
   * Chaque test suit le squelette généré par utPLSQL : arrange, act, assert.
   *   arrange : le test crée lui-même ses données (genre, concepteur, jeu, plateforme);
   *   act     : il appelle une fonction de l'API avec p_test => 'O' (ni COMMIT ni ROLLBACK);
   *   assert  : il vérifie le résultat avec ut.expect. Pour une erreur attendue, un
   *             sous-bloc (Leçon 7, diapo 32) attrape l'exception nommée de api_erreurs,
   *             puis ut.expect vérifie son code.
   * utPLSQL annule tout après chaque test : les tests ne dépendent ni de leur ordre,
   * ni des autres tests, ni des données de 02_peuplement.sql, et ils laissent la
   * base inchangée (meilleures pratiques, Leçon 9, diapo 63).
   * Les tests couvrent le déroulement nominal et les déroulements alternatifs des
   * cas d'utilisation CU-03 à CU-08 de l'analyse préliminaire.
   *
   * @author Sebastian Sanchez Gonzalez
   * @created 2026-11-01
   */

  --%test(CU-06 : jeu_insert ajoute un jeu valide et retourne l'identifiant généré)
  PROCEDURE jeu_insert_valide;

  --%test(CU-06 Information invalide : un titre absent donne l'erreur -20002, statut 400)
  PROCEDURE jeu_insert_titre_absent;

  --%test(CU-06 Information invalide : un prix négatif donne l'erreur -20002, statut 400)
  PROCEDURE jeu_insert_prix_negatif;

  --%test(CU-06 Information invalide : un genre inexistant donne l'erreur -20002, statut 400)
  PROCEDURE jeu_insert_genre_inexistant;

  --%test(CU-06 : un identifiant déjà utilisé donne l'erreur -20003, statut 409)
  PROCEDURE jeu_insert_id_existant;

  --%test(CU-07 : jeu_update change seulement les valeurs reçues, les autres restent - COALESCE)
  PROCEDURE jeu_update_valide;

  --%test(CU-07 Jeu manquant : modifier un jeu inexistant donne l'erreur -20001, statut 404)
  PROCEDURE jeu_update_introuvable;

  --%test(CU-07 Information invalide : un prix négatif donne l'erreur -20002, statut 400)
  PROCEDURE jeu_update_prix_negatif;

  --%test(CU-08 : jeu_delete supprime le jeu et ses associations avec les plateformes)
  PROCEDURE jeu_delete_valide;

  --%test(CU-08 Jeu manquant : supprimer un jeu inexistant donne l'erreur -20001, statut 404)
  PROCEDURE jeu_delete_introuvable;

  --%test(CU-03 : jeu_select retourne la première page de la liste des jeux)
  PROCEDURE jeu_select_liste;

  --%test(CU-03 Aucun jeu enregistré : jeu_select retourne une page vide - taille 0)
  PROCEDURE jeu_select_liste_vide;

  --%test(CU-03 : debut et limite découpent la liste en pages)
  PROCEDURE jeu_select_pagination;

  --%test(CU-04 et CU-05 : un jeu lu par son identifiant, avec son genre, son concepteur et ses plateformes)
  PROCEDURE jeu_select_par_id;

  --%test(CU-04 Jeu introuvable : un jeu inexistant donne l'erreur -20001, statut 404)
  PROCEDURE jeu_select_introuvable;

  --%test(CU-04 Identifiant invalide : l'identifiant 0 donne l'erreur -20002, statut 400)
  PROCEDURE jeu_select_id_invalide;

  --%test(CU-03 : une limite plus grande que c_limite_max donne l'erreur -20002, statut 400)
  PROCEDURE jeu_select_limite_invalide;
END jeu_api_test;
/
