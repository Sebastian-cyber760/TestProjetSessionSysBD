---- RACCOURCIS : COMMANDES À EXÉCUTER CONNECTÉ COMME SYS DANS FREEPDB1 ----
/*
 * Équivalent de raccourci_sys.sql dans l'exemple cours.zip (Leçon 9, diapo 65).
 * Ce n'est pas un script à lancer d'un bloc : sélectionnez une commande (ou un
 * groupe de commandes), puis exécutez-la avec le bouton execute script.
 * Remplacez les chemins par les vôtres.
 */

-- 1. Se placer dans la base enfichable (document « Configuration du débogueur »)
ALTER SESSION SET CONTAINER = FREEPDB1;

-- 2. Une seule fois par poste : installer utPLSQL comme SYS dans FREEPDB1
--    (document « Installation et utilisation de utPLSQ-framework », étape 3).
--    Exécutez les deux lignes ensemble.
-- À spécifier : le dossier source de utPLSQL décompressé (exemple du document : C:\Users\Downloads\utPLSQL\source)
cd "chemin"
@install_headless_with_trigger.sql

-- 3. Créer l'utilisateur GESTIONJEUX et ses droits (une seule fois par poste).
--    Exécutez les deux lignes ensemble.
-- À spécifier : le chemin du dossier oracle\init du projet (exemple : C:\Users\sebastian\cours3GB\Projet-session-Groupe-1\oracle\init)
cd "chemin"
@creer_gestionjeux.sql

-- 4. Vérifier la règle ACL du débogueur (document « Configuration du débogueur »).
--    Les droits de GESTIONJEUX se vérifient ensuite connecté comme GESTIONJEUX
--    (étape 2 de raccourci_gestionjeux.sql).
SELECT HOST,
       LOWER_PORT,
       UPPER_PORT
  FROM DBA_HOST_ACLS;
