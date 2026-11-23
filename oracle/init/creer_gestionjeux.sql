---- CRÉATION DE L'UTILISATEUR GESTIONJEUX (À EXÉCUTER CONNECTÉ COMME SYS) ----
/*
 * Équivalent de creer_cours.sql dans l'exemple cours.zip (Leçon 9, diapo 65).
 * À exécuter une seule fois par poste, connecté comme SYS (rôle SYSDBA), dans la
 * base enfichable FREEPDB1 (voir raccourci_sys.sql).
 * Ne jamais créer les tables, l'API, Logger ou les tests dans SYS : tout va dans
 * GESTIONJEUX.
 * Remplacez le mot de passe par celui de l'équipe. Le vrai mot de passe va dans
 * le fichier .env du serveur Node.js, jamais dans GitHub.
 * Prérequis pour la suite (une fois par poste) : utPLSQL installé comme SYS dans
 * FREEPDB1 (document « Installation et utilisation de utPLSQ-framework »,
 * étape 3; voir l'étape 2 de raccourci_sys.sql). Ce script ne l'installe pas.
 */
ALTER SESSION SET CONTAINER = FREEPDB1;

-- Espace de stockage des tables de GESTIONJEUX : tablespace USERS
CREATE USER gestionjeux IDENTIFIED BY "MotDePasseAChanger1"
  DEFAULT TABLESPACE users
  QUOTA UNLIMITED ON users;

-- Droits demandés par Logger (document « Installation et utilisation de Logger »,
-- étape 3). CREATE TABLE et CREATE PROCEDURE servent aussi au projet : tables,
-- packages d'API et packages de tests.
GRANT CONNECT, CREATE VIEW, CREATE JOB, CREATE TABLE, CREATE SEQUENCE,
      CREATE TRIGGER, CREATE PROCEDURE, CREATE ANY CONTEXT
   TO gestionjeux;

-- Droits du débogueur PL/SQL (document « Configuration du débogueur », section 4)
GRANT DEBUG CONNECT SESSION TO gestionjeux;
GRANT DEBUG ANY PROCEDURE TO gestionjeux;

-- Autorise le débogueur de VS Code (protocole JDWP, ports 4000 à 4999), selon la
-- section 5 du document « Configuration du débogueur ». host : adresse du
-- document; remplacez-la au besoin par l'adresse de votre poste.
BEGIN
  DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
    host       => '10.0.0.229',
    lower_port => 4000,
    upper_port => 4999,
    ace        => xs$ace_type(privilege_list => xs$name_list('jdwp'),
                              principal_name => 'GESTIONJEUX',
                              principal_type => xs_acl.ptype_db));
END;
/

-- Vérifier que l'autorisation a été créée (document « Configuration du débogueur »).
-- Les droits de GESTIONJEUX se vérifient connecté comme GESTIONJEUX, avec
-- USER_SYS_PRIVS (étape 2 de raccourci_gestionjeux.sql).
SELECT HOST,
       LOWER_PORT,
       UPPER_PORT
  FROM DBA_HOST_ACLS;
