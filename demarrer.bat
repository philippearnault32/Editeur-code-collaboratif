@echo off
:: FORCE Windows à activer les variables dynamiques avec ! (très important)
setlocal enabledelayedexpansion
title IDE Collaboratif Auto-Pilote

echo [1/3] Demarrage du serveur Node.js...
start "Serveur Backend" /min node backend.js

echo [2/3] Generation du tunnel internet...
:: On écrit dans tunnel.txt au lieu de log pour éviter les conflits
start /min cmd /c "npx lt --port 8080 > tunnel.txt"

echo Connexion aux serveurs distants...
timeout /t 5 /nobreak >nul

:: Extraction de l'URL
set "URL="
for /f "tokens=2 delims= " %%a in ('findstr "url:" tunnel.txt') do (
    set "URL=%%a"
)

:: Nettoyage et lancement si l'URL existe
if defined URL (
    set "CLEAN_URL=!URL:https://=!"
    set "CLEAN_URL=!CLEAN_URL:http://=!"
    
    echo [3/3] Lien genere avec succes : !URL!
    echo Ouverture automatique de l'IDE...
    
    :: On lance avec l'URL injectée
    start index.html?tunnel=!CLEAN_URL!
) else (
    echo [ERREUR] Impossible de recuperer l'adresse du tunnel.
    echo Ouverture en local simple...
    start index.html
)

:: Suppression du fichier temporaire après lecture
timeout /t 1 /nobreak >nul
if exist tunnel.txt del tunnel.txt
