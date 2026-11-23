#!/bin/zsh
# Génère la documentation markdown de l'API (plsql-md-doc), puis le site web (MkDocs),
# à partir des commentaires Javadoc des packages du répertoire source.
# Adapté de l'exemple du document « Génération de sites de documentation à partir de
# la JavaDoc » (page 6); fichier build-doc.sh et répertoire md de l'exemple cours.zip
# (Leçon 9, diapos 64 et 65).
# Prérequis, une fois par poste (même document) :
#   - plsql-md-doc installé (node), avec une entrée « gestionjeux » dans son fichier
#     config.json : source = dossier oracle/app/source du projet,
#     output = dossier oracle/app/md du projet;
#   - MkDocs installé (pip install mkdocs) et un site créé avec : mkdocs new gestionjeux
# À spécifier : remplacez chaque « chemin » par le dossier de votre poste.
cd "chemin/plsql-md-doc"
node app gestionjeux
cp "chemin/Projet-session-Groupe-1/oracle/app/md/"* "chemin/mkdocs/gestionjeux/docs/"
cd "chemin/mkdocs/gestionjeux/"
mkdocs build
