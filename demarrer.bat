@echo off
title IDE Collaboratif Auto-Pilote

echo [1/3] Demarrage du serveur Node.js...
start "Serveur Backend" /min node backend.js

echo [2/3] Generation du tunnel internet...
:: On lance localtunnel en arriere-plan et on envoie son flux dans un fichier log
start "Tunnel Réseau" /min cmd /c "npx lt --port 8080 > tunnel.log"

echo Connexion aux serveurs distants...
:: On laisse 4 secondes à localtunnel pour obtenir son URL tranquillement
timeout /t 4 /nobreak >nul

:: On extrait la ligne de l'url du fichier log
for /f "tokens=2 delims= " %%a in ('findstr "url:" tunnel.log') do (
    set "URL=%%a"
)

:: Si l'URL a bien été trouvée
if defined URL (
    set "CLEAN_URL=!URL:https://=!"
    set "CLEAN_URL=!CLEAN_URL:http://=!"
    
    echo [3/3] Lien genere avec succes : !URL!
    echo Ouverture automatique de l'IDE...
    start index.html?tunnel=!CLEAN_URL!
) else (
    echo [ERREUR] Le tunnel a mis trop de temps a repondre.
    echo Tentative d'ouverture de secours en local...
    start index.html
)

:: Petit nettoyage du fichier log
if exist tunnel.log del tunnel.log
