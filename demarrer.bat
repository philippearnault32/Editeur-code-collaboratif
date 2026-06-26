@echo off
setlocal enabledelayedexpansion
title IDE Collaboratif Auto-Pilote

echo [1/3] Demarrage du serveur Node.js en arriere-plan...
start "Serveur Backend" /min node backend.js

echo [2/3] Generation du tunnel internet (localtunnel)...
echo Patientez pendant la creation du lien de partage...

:: Le "-y" force le fonctionnement automatique
start /min cmd /c "npx -y localtunnel --port 8080 > tunnel.txt 2>&1"

:: Attente de 6 secondes pour laisser localtunnel s'initialiser
timeout /t 6 /nobreak >nul

:: Extraction de l'URL du fichier tunnel.txt
set "URL="
if exist tunnel.txt (
    for /f "tokens=2 delims= " %%a in ('findstr /i "url" tunnel.txt') do (
        set "URL=%%a"
    )
)

echo ===================================================
:: Nettoyage et lancement si l'URL existe
if defined URL (
    set "CLEAN_URL=!URL:https://=!"
    set "CLEAN_URL=!CLEAN_URL:http://=!"
    
    echo [3/3] Lien partageable genere avec succes 
    echo.
    echo ENVOIE CE LIEN A TON POTE A DISTANCE :
    echo !URL!
    echo.
    echo ===================================================
    echo Ouverture automatique de ton IDE...
    
    :: CORRECTION ICI : On utilise explorer pour forcer Windows à ouvrir le fichier local correctement avec ses paramètres
    start explorer.exe "index.html?tunnel=!CLEAN_URL!"
) else (
    echo [ATTENTION] Le lien automatique n'a pas pu etre injecte.
    echo Verifie le fichier "tunnel.txt" qui vient d'etre cree.
    echo ===================================================
    echo Ouverture de l'IDE...
    start explorer.exe "index.html"
)

echo.
echo Laisse cette fenetre ouverte pendant votre session de code.
pause

if exist tunnel.txt del tunnel.txt
