@echo off
setlocal enabledelayedexpansion
title IDE Collaboratif Auto-Pilote

echo [1/2] Demarrage du serveur Node.js...
:: On lance le backend dans une fenetre separee qui se fermera a la fin
start "Serveur Backend" /min node backend.js

echo [2/2] Generation du tunnel internet...
echo --------------------------------------------------
echo Connexion aux serveurs Localtunnel en cours...
echo Une fenetre de navigateur va s'ouvrir automatiquement.
echo --------------------------------------------------

:: On lance localtunnel et on recupere directement sa sortie sans passer par un fichier texte
for /f "tokens=2 delims= " %%a in ('npx lt --port 8080') do (
    set "URL=%%a"
    goto launch
)

:launch
:: Nettoyage de l'URL pour le parametre
set "CLEAN_URL=!URL:https://=!"
set "CLEAN_URL=!CLEAN_URL:http://=!"

echo Lien genere : !URL!
echo Ouverture de l'IDE...

:: Ouverture automatique du navigateur
start index.html?tunnel=!CLEAN_URL!
