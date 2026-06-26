@echo off
:: FORCE Windows à activer les variables dynamiques avec !
setlocal enabledelayedexpansion
title IDE Collaboratif Auto-Pilote

echo [1/3] Demarrage du serveur Node.js en arriere-plan...
start "Serveur Backend" /min node backend.js

echo [2/3] Generation du tunnel internet (localtunnel)...
echo Patientez pendant la creation du lien de partage...

:: Le "-y" force npx à installer localtunnel sans bloquer en arriere-plan
start /min cmd /c "npx -y localtunnel --port 8080 > tunnel.txt 2>&1"

:: Attente de 6 secondes pour laisser le temps au tunnel de se créer
timeout /t 6 /nobreak >nul

:: Extraction de l'URL du fichier tunnel.txt
set "URL="
if exist tunnel.txt (
    for /f "tokens=2 delims= " %%a in ('findstr /i "url" tunnel.txt') do (
        set "URL=%%a"
    )
)

:: Nettoyage et lancement si l'URL existe
if defined URL (
    set "CLEAN_URL=!URL:https://=!"
    set "CLEAN_URL=!CLEAN_URL:http://=!"
    
    echo ===================================================
    echo [3/3] Lien partageable genere avec succes : !URL!
    echo Ouverture automatique de l'IDE...
    echo ===================================================
    
    :: Lance l'index.html avec le paramètre tunnel
    start index.html?tunnel=!CLEAN_URL!
) else (
    echo ===================================================
    echo [ATTENTION] Impossible de generer le tunnel automatique.
    echo Pas de panique ! Vous pouvez lancer la session manuellement.
    echo.
    echo 1. Copiez ce lien et ouvrez-le dans votre navigateur :
    echo    http://localhost:8080
    echo.
    echo 2. Partagez ce lien a votre pote si vous etes sur le meme Wi-Fi.
    echo ===================================================
    echo.
    echo Ouverture de l'IDE en mode local simple...
    start index.html
    
    :: Empêche le terminal de se fermer pour vous laisser copier le lien
    pause
)

:: Suppression du fichier temporaire après lecture
if exist tunnel.txt del tunnel.txt
