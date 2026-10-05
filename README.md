# Groupe 01 – Projet de session SysBD

**Système de gestion du Groupe 01** : serveur API REST (Node.js et Express) qui appelle une API PL/SQL dans une base de données Oracle, avec une interface web.

| | |
|---|---|
| Cours | 420-3GB-BB – Système de base de données, automne 2026 |
| Établissement | Collège de Bois-de-Boulogne |
| Personnes enseignantes | Rim Mseddi et Jean-François Brodeur |
| Équipe | Groupe 1 – [nom ou numéro de l'équipe] |
| Tableau de projet | [lien vers le GitHub Project] |

---

## 1. Équipe et rôles

| Membre | Utilisateur GitHub |
|---|---|
| Hady Kaba | [@utilisateur] |
| Maxime Maindron | [@utilisateur] |
| Sami Hassan Naib | [@utilisateur] |
| Sebastian Sanchez Gonzalez | [@utilisateur] |

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
| `feature` | Nouvelle fonctionnalité | `feature/15-api-ajout-etudiant` |
| `bugfix` | Correction d'une anomalie | `bugfix/23-erreur-500-liste` |
| `bd` | Schéma Oracle, tables, PL/SQL | `bd/7-table-etudiant` |
| `api` | Routes Node.js, validation, codes HTTP | `api/18-get-etudiant-par-id` |
| `infra` | Docker/Podman, Nginx, configuration | `infra/8-nginx-reverse-proxy` |
| `doc` | Documentation, README, documents d'analyse | `doc/31-readme-installation` |

### Cycle de vie d'une tâche

```bash
git switch develop
git pull                                   # partir de la dernière version de develop
git switch -c bd/7-table-etudiant          # créer la branche de l'Issue #7
# ... travailler, puis :
git add <fichiers>
git commit -m "Créer la table ETUDIANT et ses contraintes"
git push -u origin bd/7-table-etudiant
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

- [ ] Les scripts s'exécutent sur une base vide et peuvent être rejoués (suppression puis recréation).
- [ ] Les clés primaires, les clés étrangères et les contraintes (CHECK, NOT NULL) sont définies et nommées.
- [ ] Les packages compilent sans erreur et chaque fonction ou procédure est documentée avec le gabarit Javadoc (champ `@author` rempli).
- [ ] Le code est instrumenté avec logger.
- [ ] Les tests unitaires du package `<entite>_API_tests` passent.

**`api` – routes Node.js**

- [ ] La route est testée dans Postman (cas nominal et cas d'erreur) et la collection Postman du dépôt est à jour.
- [ ] Les codes HTTP sont appropriés (200, 201, 404, 409, 500) et les réponses sont en JSON.
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
| Analyse préliminaire (livrable #2) | `Equipe01_analyseP_l2.docx` : analyse révisée, scripts SQL, besoins de transfert, méthodologie | Semaine 6 |
| Prototype API PL/SQL (livrable #3) | 16 méthodes pour 4 entités, 4 packages de tests, logger, scripts d'installation | Semaine 10 (autoévaluation en semaine 9) |
| Serveur API REST (livrable #4) | Serveur Node.js, page web CRUD, tests Postman, documentation finale | Semaine 14 |

## 7. Structure du dépôt (prévue)

```text
backend/             API Node.js + Express (src/routes, db.js, server.js, Dockerfile, package.json)
frontend/            Interface web (index.html, app.js, style.css)
nginx/               Proxy inverse (default.conf)
oracle/              Scripts SQL et PL/SQL (init/, app/)
docs/                Documents d'analyse et livrables Word
.env.example         Modèle des variables d'environnement (sans mot de passe réel)
docker-compose.yml   Démarrage de tous les services
```

## 8. Installation et déploiement

À compléter au fil du projet. Le livrable final exige une procédure détaillée qui permet à une autre personne d'installer l'application à partir de GitHub et d'exécuter ses tests.
