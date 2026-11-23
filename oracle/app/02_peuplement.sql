---- PEUPLEMENT DES TABLES ----
-- GENRE, CONCEPTEUR, PLATEFORME et JEU : identifiants assignés par la BD (colonnes
-- identité, voir 01_creation.sql). Dans des tables neuves (creer_env.sql), les
-- rangées reçoivent 1, 2, 3 et 4 dans l'ordre des INSERT : les clés étrangères de
-- JEU et de JEU_PLATEFORME ci-dessous utilisent ces numéros.

---- GENRE ----
INSERT INTO genre (nom_genre, description) VALUES ('Action', 'Jeux d action');
INSERT INTO genre (nom_genre, description) VALUES ('Aventure', 'Jeux d aventure');
INSERT INTO genre (nom_genre, description) VALUES ('Sport', 'Jeux de sport');
INSERT INTO genre (nom_genre, description) VALUES ('RPG', 'Jeux de role');

---- CONCEPTEUR ----
INSERT INTO concepteur (nom_concepteur, pays) VALUES ('Rockstar Games', 'Etats-Unis');
INSERT INTO concepteur (nom_concepteur, pays) VALUES ('Ubisoft', 'France');
INSERT INTO concepteur (nom_concepteur, pays) VALUES ('Nintendo', 'Japon');
INSERT INTO concepteur (nom_concepteur, pays) VALUES ('Electronic Arts', 'Etats-Unis');

---- PLATEFORME ----
INSERT INTO plateforme (nom_plateforme) VALUES ('PlayStation 5');
INSERT INTO plateforme (nom_plateforme) VALUES ('Xbox Series X');
INSERT INTO plateforme (nom_plateforme) VALUES ('Nintendo Switch');
INSERT INTO plateforme (nom_plateforme) VALUES ('PC');

---- JEU ----
INSERT INTO jeu (titre, description, date_sortie, prix, genre_id_genre, concepteur_id_concepteur) VALUES ('GTA V', 'Jeu d action en monde ouvert', DATE '2013-09-17', 39.99, 1, 1);
INSERT INTO jeu (titre, description, date_sortie, prix, genre_id_genre, concepteur_id_concepteur) VALUES ('Assassins Creed Valhalla', 'Jeu d aventure', DATE '2020-11-10', 59.99, 2, 2);
INSERT INTO jeu (titre, description, date_sortie, prix, genre_id_genre, concepteur_id_concepteur) VALUES ('Mario Odyssey', 'Jeu de plateforme et aventure', DATE '2017-10-27', 79.99, 2, 3);
INSERT INTO jeu (titre, description, date_sortie, prix, genre_id_genre, concepteur_id_concepteur) VALUES ('EA Sports FC 25', 'Jeu de football', DATE '2024-09-27', 69.99, 3, 4);

---- JEU_PLATEFORME ----
INSERT INTO jeu_plateforme (jeu_id_jeu, plateforme_id_plateforme) VALUES (1, 1);
INSERT INTO jeu_plateforme (jeu_id_jeu, plateforme_id_plateforme) VALUES (1, 2);
INSERT INTO jeu_plateforme (jeu_id_jeu, plateforme_id_plateforme) VALUES (1, 4);
INSERT INTO jeu_plateforme (jeu_id_jeu, plateforme_id_plateforme) VALUES (2, 1);
INSERT INTO jeu_plateforme (jeu_id_jeu, plateforme_id_plateforme) VALUES (2, 2);
INSERT INTO jeu_plateforme (jeu_id_jeu, plateforme_id_plateforme) VALUES (3, 3);
INSERT INTO jeu_plateforme (jeu_id_jeu, plateforme_id_plateforme) VALUES (4, 1);
INSERT INTO jeu_plateforme (jeu_id_jeu, plateforme_id_plateforme) VALUES (4, 2);
INSERT INTO jeu_plateforme (jeu_id_jeu, plateforme_id_plateforme) VALUES (4, 4);

---- UTILISATEUR ----
INSERT INTO utilisateur (id_utilisateur, nom, prenom, courriel, mot_de_passe, date_creation) VALUES (1, 'Tremblay', 'Alexandre', 'alexandre@test.com', 'TEST_NON_SECURISÉ_1', DATE '2026-10-01');
INSERT INTO utilisateur (id_utilisateur, nom, prenom, courriel, mot_de_passe, date_creation) VALUES (2, 'Gagnon', 'Sophie', 'sophie@test.com', 'TEST_NON_SECURISÉ_2', DATE '2026-10-02');
INSERT INTO utilisateur (id_utilisateur, nom, prenom, courriel, mot_de_passe, date_creation) VALUES (3, 'Bouchard', 'Marc', 'marc@test.com', 'TEST_NON_SECURISÉ_3', DATE '2026-10-03');
INSERT INTO utilisateur (id_utilisateur, nom, prenom, courriel, mot_de_passe, date_creation) VALUES (4, 'Roy', 'Emma', 'emma@test.com', 'TEST_NON_SECURISÉ_4', DATE '2026-10-04');

---- DROIT ----
INSERT INTO droit (id_droit, nom_droit, description) VALUES (1, 'CLIENT', 'Utilisateur qui consulte les jeux');
INSERT INTO droit (id_droit, nom_droit, description) VALUES (2, 'VENDEUR', 'Utilisateur autorise a vendre des jeux');
INSERT INTO droit (id_droit, nom_droit, description) VALUES (3, 'ADMIN', 'Administrateur du systeme');

---- UTILISATEUR_DROIT ----
INSERT INTO utilisateur_droit (utilisateur_id_utilisateur, droit_id_droit) VALUES (1, 1);
INSERT INTO utilisateur_droit (utilisateur_id_utilisateur, droit_id_droit) VALUES (2, 1);
INSERT INTO utilisateur_droit (utilisateur_id_utilisateur, droit_id_droit) VALUES (2, 2);
INSERT INTO utilisateur_droit (utilisateur_id_utilisateur, droit_id_droit) VALUES (3, 3);
INSERT INTO utilisateur_droit (utilisateur_id_utilisateur, droit_id_droit) VALUES (4, 1);

---- SESSION ----
INSERT INTO "SESSION" (id_session, date_debut, date_fin, utilisateur_id_utilisateur) VALUES (1, TIMESTAMP '2026-10-10 09:00:00', TIMESTAMP '2026-10-10 10:00:00', 1);
INSERT INTO "SESSION" (id_session, date_debut, date_fin, utilisateur_id_utilisateur) VALUES (2, TIMESTAMP '2026-10-11 14:00:00', TIMESTAMP '2026-10-11 15:00:00', 2);
INSERT INTO "SESSION" (id_session, date_debut, date_fin, utilisateur_id_utilisateur) VALUES (3, TIMESTAMP '2026-10-12 08:30:00', NULL, 3);
INSERT INTO "SESSION" (id_session, date_debut, date_fin, utilisateur_id_utilisateur) VALUES (4, TIMESTAMP '2026-10-13 16:00:00', NULL, 4);

---- DEMANDE_VENDEUR ----
INSERT INTO demande_vendeur (id_demande, date_demande, statut, utilisateur_id_utilisateur) VALUES (1, DATE '2026-10-10', 'EN_ATTENTE', 1);
INSERT INTO demande_vendeur (id_demande, date_demande, statut, utilisateur_id_utilisateur) VALUES (2, DATE '2026-10-11', 'ACCEPTEE', 2);
INSERT INTO demande_vendeur (id_demande, date_demande, statut, utilisateur_id_utilisateur) VALUES (3, DATE '2026-10-12', 'REFUSEE', 4);

COMMIT;
