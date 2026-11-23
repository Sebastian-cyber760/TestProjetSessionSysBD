---- SUPPRIME LES PACKAGES ET LES TABLES DU PROJET (LOGGER EST CONSERVÉ) ----
/*
 * Appelé au début de creer_env.sql pour que l'installation complète puisse être
 * refaite autant de fois que nécessaire. À exécuter connecté comme GESTIONJEUX.
 * Chaque boucle FOR (Leçon 6) lit seulement les objets qui existent, puis les
 * supprime avec du SQL dynamique, EXECUTE IMMEDIATE (Leçon 9, diapo 22) : aucune
 * erreur au premier lancement, quand rien n'existe encore.
 * Les anciens noms de la version précédente (packages *_API_TESTS) sont aussi
 * supprimés s'ils existent encore.
 */
BEGIN
  -- 1. Packages de tests et packages de l'API
  FOR rec_objet IN (
    SELECT object_name
      FROM user_objects
     WHERE object_type = 'PACKAGE'
       AND object_name IN ('GENRE_API_TEST', 'CONCEPTEUR_API_TEST', 'PLATEFORME_API_TEST',
                           'JEU_API_TEST', 'GENRE_API_TESTS', 'CONCEPTEUR_API_TESTS',
                           'PLATEFORME_API_TESTS', 'JEU_API_TESTS', 'GENRE_API',
                           'CONCEPTEUR_API', 'PLATEFORME_API', 'JEU_API', 'API_ERREURS')
  ) LOOP
    EXECUTE IMMEDIATE 'DROP PACKAGE ' || rec_objet.object_name;
  END LOOP;

  -- 2. Tables, dans le même ordre que 05_RESET_MANUEL.sql de l'équipe : d'abord
  --    les tables dont les clés étrangères visent les autres, puis JEU, puis les
  --    tables parents. Les guillemets gardent le nom exact (table "SESSION").
  FOR rec_table IN (
    SELECT table_name
      FROM user_tables
     WHERE table_name IN ('JEU_PLATEFORME', 'UTILISATEUR_DROIT', 'DEMANDE_VENDEUR', 'SESSION')
  ) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE "' || rec_table.table_name || '"';
  END LOOP;

  FOR rec_table IN (
    SELECT table_name
      FROM user_tables
     WHERE table_name = 'JEU'
  ) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE "' || rec_table.table_name || '"';
  END LOOP;

  FOR rec_table IN (
    SELECT table_name
      FROM user_tables
     WHERE table_name IN ('PLATEFORME', 'GENRE', 'CONCEPTEUR', 'DROIT', 'UTILISATEUR')
  ) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE "' || rec_table.table_name || '"';
  END LOOP;
END;
/
