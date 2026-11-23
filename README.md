# TestProjetSessionSysBD (Groupe 1 – Projet de session SysBD)

**Système de gestion de jeux vidéo du Groupe 1** : serveur API REST (Node.js et Express) qui appelle une API PL/SQL dans une base de données Oracle, avec une interface web.

| | |
|---|---|
| Cours | Système de base de données (420-3GB-BB), automne 2026 |
| Établissement | Collège de Bois-de-Boulogne |
| Équipe | Groupe 1 |
| Tableau de projet | https://github.com/orgs/420-3GB-BB/projects/5 |

---

## 1. Équipe et rôles

| Membre | Utilisateur GitHub |
|---|---|
| Hady Kaba | @HadyKaba-bdeb |
| Maxime Maindron | @Maxbdeb |
| Sami Hassan Naib | @Sami-SNH |
| Sebastian Sanchez Gonzalez | @Sebastian-cyber760 |

Chaque rôle a une seule personne responsable. **Les rôles tournent à chaque sprint** (2 semaines) : personne ne devient la seule personne à comprendre une partie du projet.

| Rôle | Responsabilité principale | Sprint 1 | Sprint 2 | Sprint 3 | Sprint 4 |
|---|---|---|---|---|---|
| Données | Schéma Oracle, tables, procédures PL/SQL, jeux de test | Maxime Maindron | [Membre B] | [Membre C] | [Membre D] |
| API | Routes Node.js, validation, codes HTTP | Sebastian Sanchez Gonzalez | [Membre C] | [Membre D] | [Membre A] |
| Infrastructure | Docker/Podman, Nginx, variables d'environnement | Hady Kaba | [Membre D] | [Membre A] | [Membre B] |
| Intégration et qualité | Révision des Pull Requests, tests, documentation | Sami Hassan Naib | [Membre A] | [Membre B] | [Membre C] |

Après le sprint 4, la rotation recommence.

## 2. Rituels de l'équipe

| Rituel | Quand | Durée | Contenu |
|---|---|---|---|
| Mêlée hebdomadaire | **[Jour] à [heure]**, [lieu : en classe, Discord, Teams…] | 15 min | Chaque membre répond : Qu'est-ce que j'ai fait? Qu'est-ce que je fais? Qu'est-ce qui me bloque? |
| Planification de sprint | Début de chaque sprint | [durée] | Choisir et assigner les tâches des 2 prochaines semaines |
| Révision de fin de sprint | Fin de chaque sprint | [durée] | Démontrer ce qui fonctionne |
| Rétrospective | Fin de chaque sprint | 10 min | Qu'est-ce qu'on garde? Qu'est-ce qu'on change? |

**Communication** : les décisions, les questions et les blocages liés à une tâche sont écrits en commentaire dans l'Issue concernée. On évite de discuter uniquement en messages privés, car les décisions y disparaissent.

## 3. Tableau de projet (GitHub Projects)

| Colonne | Signification |
|---|---|
| Backlog | La tâche n'a pas encore commencé. |
| Ready | La tâche est clairement définie et prête à être réalisée. |
| In progress | Un membre de l'équipe travaille actuellement sur la tâche. |
| In review | Le travail est terminé et doit être révisé par un autre membre (Pull Request ouverte). |
| Done | La tâche respecte la definition of done (section 5). |

Chaque membre déplace ses propres cartes. Le tableau est vérifié à chaque mêlée.

## 4. Flux Git

| Branche | Rôle |
|---|---|
| `main` | Version stable et livrable. **Protégée** : aucun push direct. |
| `develop` | Branche d'intégration où le travail de tous se rejoint. C'est la branche par défaut du dépôt. |
| `label/numéro-description` | Une branche par Issue, créée à partir de `develop` et supprimée après la fusion. |

### Règles de l'équipe

1. On crée toujours sa branche à partir de `develop`, jamais de `main`.
2. Toute fusion passe par une Pull Request révisée et approuvée par un coéquipier.
3. `main` est protégée : révision obligatoire, historique linéaire, aucun force push.
4. Une fois la Pull Request fusionnée, on supprime la branche et l'Issue est fermée.
5. On pousse son travail souvent (au moins tous les 3 jours) avec des commits atomiques : un commit = une modification précise.

### Nommer une branche

Format : `label/numéro-issue-description-courte`. Le numéro de l'Issue relie le code à la tâche : on retrouve toujours pourquoi une ligne a été écrite.

| Label | Quand l'utiliser | Exemple de branche |
|---|---|---|
| `feature` | Nouvelle fonctionnalité | `feature/15-api-ajout-jeu` |
| `bugfix` | Correction d'une anomalie | `bugfix/23-erreur-500-liste` |
| `bd` | Schéma Oracle, tables, PL/SQL | `bd/7-table-jeu` |
| `api` | Routes Node.js, validation, codes HTTP | `api/18-get-jeu-par-id` |
| `infra` | Docker/Podman, Nginx, configuration | `infra/8-nginx-reverse-proxy` |
| `doc` | Documentation, README, documents d'analyse | `doc/31-readme-installation` |

### Cycle de vie d'une tâche

```bash
git checkout develop
git pull                                   # partir de la dernière version de develop
git branch bd/7-table-jeu                  # créer la branche de l'Issue #7
git checkout bd/7-table-jeu                # basculer sur cette branche
# ... travailler, puis :
git add <fichiers>
git commit -m "Créer la table JEU et ses contraintes"
git push -u origin bd/7-table-jeu
```

Ensuite, sur GitHub :

1. Ouvrir une Pull Request **vers `develop`** avec `Closes #7` dans la description, puis déplacer la carte dans **In review**.
2. Un coéquipier révise le travail, le commente et l'approuve.
3. Résoudre les conversations, fusionner, puis supprimer la branche. L'Issue se ferme et la carte passe dans **Done**.

Les messages de commit sont à l'infinitif et précis, par exemple : « Ajouter la validation des données ».

## 5. Definition of done (DoD)

Une tâche passe dans **Done** seulement quand tous les critères qui la concernent sont respectés. **Une tâche à 90 % n'est pas terminée.**

### Pour toutes les tâches

- [ ] Tous les critères d'acceptation de l'Issue sont respectés.
- [ ] Le travail fonctionne et a été testé (« ça compile » ne suffit pas).
- [ ] Une Pull Request vers `develop`, contenant `Closes #N`, a été révisée et approuvée par un coéquipier.
- [ ] Toutes les conversations de la Pull Request sont résolues.
- [ ] La branche est fusionnée dans `develop`, puis supprimée.
- [ ] L'Issue est fermée et la carte est dans la colonne **Done**.

### Critères supplémentaires selon le label

**`bd` – base de données et PL/SQL**

- [ ] Les scripts s'exécutent sur une base vide et peuvent être rejoués (suppression puis recréation) : `creer_env.sql` va jusqu'au bout sans erreur.
- [ ] Les clés primaires, les clés étrangères et les contraintes (CHECK, NOT NULL) sont définies et nommées.
- [ ] Les packages compilent sans erreur et chaque fonction ou procédure est documentée avec le gabarit Javadoc (champ `@author` rempli).
- [ ] Le code est instrumenté avec logger.
- [ ] Les tests unitaires utPLSQL du package `<entite>_api_test` passent (`exec_tests.sql`).

**`api` – routes Node.js**

- [ ] La route est testée dans Postman (cas nominal et cas d'erreur) et la collection Postman du dépôt est à jour.
- [ ] Les codes HTTP sont ceux de la Leçon 10 (200, 201, 204, 400, 404, 409, 500) et les réponses sont en JSON.
- [ ] Les valeurs sont passées à Oracle par des variables de liaison (paramètres nommés), jamais par concaténation.
- [ ] Les requêtes et les erreurs sont journalisées (Winston) et une erreur ne fait pas planter le serveur.

**`feature` – fonctionnalité visible**

- [ ] La fonctionnalité marche dans le navigateur et les messages d'erreur sont affichés à l'utilisateur.
- [ ] Les données sont réellement lues ou modifiées dans la base.

**`infra` – infrastructure**

- [ ] `docker compose up -d` (ou l'équivalent Podman) démarre le service sans erreur sur le poste d'un autre membre.
- [ ] Aucun secret n'est dans le dépôt : `.env` est ignoré par Git et `.env.example` est à jour.
- [ ] Le README est mis à jour si la procédure d'installation change.

**`doc` – documentation**

- [ ] Le contenu respecte le gabarit et la grille d'évaluation du livrable.
- [ ] Un coéquipier a relu le contenu et la qualité de la langue.
- [ ] Les sources sont citées, y compris les liens de partage des conversations avec un outil d'IA.

**`bugfix` – correction**

- [ ] Le bogue a été reproduit, puis corrigé.
- [ ] Un test couvre maintenant ce cas.

## 6. Milestones (livrables)

| Milestone | Contenu principal | Échéance |
|---|---|---|
| Analyse préliminaire (livrable #2) | `docs/Equipe01_analysep_l2.docx` : analyse révisée, scripts SQL, besoins de transfert, méthodologie | Semaine 6 |
| Prototype API PL/SQL (livrable #3) | 16 méthodes pour 4 entités, 4 packages de tests, Javadoc, logger, scripts d'installation comme l'exemple `cours.zip` | Semaine 10 (autoévaluation en semaine 9) |
| Serveur API REST (livrable #4) | Serveur Node.js, page web CRUD, tests Postman, documentation finale | Semaine 14 |

## 7. Structure du dépôt

Le dépôt suit le document « Structure du projet » du cours. Le livrable 3 (base de données et API PL/SQL) se trouve dans `oracle/`, organisé comme l'exemple `cours.zip`. Les éléments marqués « livrable 4 » seront ajoutés plus tard.

```text
backend/                     API Node.js + Express (src/routes/, src/db.js, src/server.js, Dockerfile, package.json) – livrable 4
docs/                        Documentation du projet
  Equipe01_analysep_l2.docx  Analyse préliminaire
  annexe-docker-run.md       Prévu dans la structure du cours – livrable 4
frontend/                    Interface web (index.html, app.js, style.css) – livrable 4
nginx/                       Proxy inverse (default.conf) – livrable 4
oracle/
  init/
    creer_gestionjeux.sql    Création de l'utilisateur GESTIONJEUX (une seule fois, comme SYS)
  app/
    raccourci_sys.sql          Commandes à exécuter comme SYS
    raccourci_gestionjeux.sql  Commandes à exécuter comme GESTIONJEUX
    creer_env.sql              Installe tout (tables, données, API, tests) et exécute les tests
    supprimer_objets.sql       Supprime les packages et les tables du projet (logger est gardé)
    01_creation.sql            Tables et contraintes
    02_peuplement.sql          Données initiales
    exec_tests.sql             Exécute les 4 suites de tests
    exemples_appels_api.sql    Démonstration des appels de l'API
    build-doc.sh               Génère la documentation de l'API (Javadoc, markdown, site web)
    05_RESET_MANUEL.sql, 06_verification.sql, 08_audit_final.sql
                               Outils de vérification de l'équipe
    source/                    Packages de l'API (.pks et .pkb)
    test/                      Packages de tests (<entite>_api_test)
    md/                        Documentation markdown produite par build-doc.sh (à ajouter)
    resultat.log               Résultat de creer_env.sql (à ajouter après l'exécution)
.env                         Variables d'environnement réelles (jamais versionné)
.env.example                 Modèle des variables d'environnement – livrable 4
.gitignore                   Fichiers ignorés par Git (.env)
docker-compose.yml           Démarrage de tous les services – livrable 4
README.md                    Ce document
```

## 8. Installation et déploiement

Cette procédure permet à une autre personne (un membre de l'équipe ou le professeur) d'installer le projet à partir de GitHub et d'exécuter ses tests. La section 8.3 couvre la base de données et l'API PL/SQL (livrable 3). La section 8.4 couvre le serveur Node.js, l'interface web et les conteneurs : elle sera complétée au livrable 4.

### 8.1 Prérequis (une seule fois par poste)

| Outil | Utilité |
|---|---|
| Git | Récupérer le dépôt |
| Docker Desktop ou Podman, avec le conteneur Oracle Database Free | Base de données : hôte `localhost`, port `1521`, service `FREEPDB1` |
| VS Code et l'extension Oracle SQL Developer | Exécuter les scripts SQL avec le bouton **execute script** |
| logger 3.1.1 | Journalisation du code PL/SQL (installé dans GESTIONJEUX à la section 8.3) |
| utPLSQL | Tests unitaires PL/SQL (installé comme SYS dans FREEPDB1 à la section 8.3) |
| node, plsql-md-doc et MkDocs (Python 3) | Générer la documentation de l'API à partir de la Javadoc (`build-doc.sh`) |
| Node.js | Serveur API REST (livrable 4) |

### 8.2 Récupérer le projet

```bash
git clone <URL du dépôt>      # bouton « Code » de la page GitHub du dépôt
cd <dossier du dépôt>
git checkout main             # version stable et livrable (develop = intégration en cours)
```

### 8.3 Base de données et API PL/SQL (livrable 3)

Toutes les commandes de cette section se trouvent aussi dans `oracle/app/raccourci_sys.sql` et `oracle/app/raccourci_gestionjeux.sql`. Dans VS Code, sélectionner les lignes, puis les exécuter ensemble avec le bouton **execute script** (document « Installation et utilisation de Logger »). Remplacer les chemins par ceux de votre poste.

1. **Installer utPLSQL** (une seule fois par poste), selon le document « Installation et utilisation de utPLSQ-framework ». Connecté comme **SYS** (rôle SYSDBA) :

   ```sql
   ALTER SESSION SET CONTAINER = FREEPDB1;
   cd "C:\chemin\vers\utPLSQL\source"
   @install_headless_with_trigger.sql
   ```

2. **Créer l'utilisateur GESTIONJEUX** (une seule fois). Dans `oracle/init/creer_gestionjeux.sql`, remplacer le mot de passe d'exemple par celui de l'équipe, sans jamais pousser le vrai mot de passe, et, au besoin, l'adresse `host` de la règle du débogueur (document « Configuration du débogueur »). Toujours connecté comme **SYS** :

   ```sql
   cd "C:\chemin\vers\le\depot\oracle\init"
   @creer_gestionjeux.sql
   ```

   Créer ensuite une connexion VS Code pour **GESTIONJEUX** (mêmes hôte, port et service). Toutes les étapes suivantes se font avec cette connexion, jamais avec SYS.

3. **Installer logger 3.1.1 dans GESTIONJEUX** (une seule fois), selon le document « Installation et utilisation de Logger » :

   ```sql
   cd "C:\chemin\vers\logger_3.1.1"
   @logger_install.sql
   ```

4. **Vérifier utPLSQL et les droits du débogueur** :

   ```sql
   select substr(ut.version(),1,60) as ut_version from dual;
   SELECT * FROM USER_SYS_PRIVS WHERE PRIVILEGE LIKE 'DEBUG%';
   ```

5. **Créer l'environnement et exécuter les tests** :

   ```sql
   cd "C:\chemin\vers\le\depot\oracle\app"
   @@creer_env.sql
   ```

   Le script vérifie que logger et utPLSQL sont présents, supprime les objets du projet (logger est gardé), crée les tables, insère les données initiales, compile `api_erreurs`, les 4 packages d'API et les 4 packages de tests, puis exécute les tests. Tout ce qu'il affiche est aussi écrit dans `oracle/app/resultat.log`. Il peut être relancé autant de fois que nécessaire.

6. **Vérifier `resultat.log`** :

   - au début, les deux rangées de `LOGGER` (statut `VALID`) et la version de utPLSQL (`UT_VERSION`);
   - le statut `VALID` pour `LOGGER`, `API_ERREURS`, les 4 packages d'API et les 4 packages de tests;
   - aucune rangée dans la liste des erreurs de compilation (`user_errors`);
   - à la fin du rapport de utPLSQL : `44 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)`.

Commandes utiles ensuite (connecté comme GESTIONJEUX, dans le dossier `oracle/app/`) :

| Commande | Utilité |
|---|---|
| `@@exec_tests.sql` | Réexécuter seulement les tests unitaires |
| `@@exemples_appels_api.sql` | Démontrer les appels de l'API et ses erreurs (les changements sont annulés à la fin) |
| `SELECT id, logger_level, scope, text FROM logger_logs ORDER BY id DESC;` | Lire les traces de logger, les plus récentes en premier |

**Documentation de l'API (Javadoc)** : `oracle/app/build-doc.sh` génère les fichiers markdown du répertoire `oracle/app/md/` avec plsql-md-doc, puis le site web avec MkDocs, selon le document « Génération de sites de documentation à partir de la JavaDoc ». Avant la première utilisation : installer plsql-md-doc et MkDocs, créer l'entrée `gestionjeux` dans le fichier `config.json` de plsql-md-doc (source : `oracle/app/source`; sortie : `oracle/app/md`), puis remplacer les chemins du script.

### 8.4 Serveur API REST, interface web et conteneurs (livrable 4)

> **À compléter au livrable 4** par l'équipe : commandes exactes, ports, nom de la collection Postman et adresse de l'interface web.

Selon l'analyse préliminaire, chaque service (Oracle, API Node.js et proxy inverse Nginx) s'exécute dans son propre conteneur Podman, et l'ensemble démarre avec une seule commande. Étapes prévues :

1. Copier `.env.example` vers `.env`, puis remplir les valeurs : identifiants et chaîne de connexion de la base de données, port de l'API. Le fichier `.env` n'est jamais versionné.
2. Démarrer les services :

   ```bash
   podman compose up -d
   ```

   Au démarrage, l'API tente de se reconnecter à Oracle pendant 30 secondes, le temps que la base soit prête.
3. Ouvrir l'interface web dans le navigateur, par Nginx : adresse et port à préciser.
4. Importer la collection Postman du dépôt, puis exécuter ses tests (cas nominaux et cas d'erreur).

### 8.5 Problèmes fréquents

| Message ou symptôme | Solution |
|---|---|
| Aucune rangée `LOGGER` au début de `resultat.log` | logger n'est pas installé dans GESTIONJEUX : refaire l'étape 3 de la section 8.3, connecté comme GESTIONJEUX. |
| Une erreur à la requête `ut_version` au début de `resultat.log` | utPLSQL n'est pas installé : refaire l'étape 1 de la section 8.3, connecté comme SYS. |
| `resultat.log` n'est pas créé, ou un script appelé avec `@@` est introuvable | La commande `cd` ne vise pas le dossier `oracle/app/` du dépôt. |
| Une seule instruction s'exécute | Sélectionner les lignes, puis les exécuter ensemble avec le bouton **execute script**, comme indiqué au début de la section 8.3. |
