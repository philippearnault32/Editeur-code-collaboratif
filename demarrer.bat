@echo off
set PORT=8080
title IDE Collaboratif - Demarrage

echo === Lancement du serveur Backend ===
start /b node backend.js

echo Attente de l'initialisation du serveur (2s)...
timeout /t 2 /nobreak > nul

echo === Creation du tunnel public (Localtunnel) ===
echo Generation de l'URL en cours...

:: Lancement de localtunnel en tâche de fond en redirigeant la sortie vers un fichier temporaire
start /b "" npx lt --port %PORT% > tunnel.txt 2>&1@echo off
title Lanceur IDE Collaboratif
cls

echo ===================================================
echo    Lancement de l'IDE Collaboratif Synchrone
echo ===================================================
echo.

:: 1. Lancement du serveur backend Node dans une nouvelle fenêtre séparée
echo [1/2] Lancement du serveur Backend Node.js...
start "Serveur Backend Node" cmd /k "node backend.js"

:: Attente de 2 secondes pour s'assurer que le serveur est bien démarré
timeout /t 3 /nobreak >nul

echo.
echo [2/2] Creation du tunnel public (Localtunnel)...
echo       L'URL va s'afficher ci-dessous d'ici quelques instants.
echo       Copiez l'URL affichee (ex: https://xxxxx.loca.lt) et ajoutez-la
echo       au lien de votre navigateur sous la forme :
echo       http://localhost:8080/?tunnel=xxxxx.loca.lt
echo.
echo ===================================================
echo.

:: 2. Lancement en direct de localtunnel sans redirection vers un fichier texte
npx localtunnel --port 8080

pause

:: Attente de la génération du lien
timeout /t 3 /nobreak > nul

:: Extraction et nettoyage de l'URL
set "TUNNEL_URL="
for /f "tokens=*" %%i in (tunnel.txt) do (
    echo %%i | findstr "https://" >nul
    if not errorlevel 1 (
        set "TUNNEL_URL=%%i"
    )
)

if "%TUNNEL_URL%"=="" (
    echo [Alerte] Impossible de recuperer automatiquement l'URL du tunnel. Checkez le fichier tunnel.txt.
    goto :end
)

:: Nettoyage de la phrase "your url is: "
set "TUNNEL_URL=%TUNNEL_URL:your url is =%"
set "TUNNEL_URL=%TUNNEL_URL: =%"
set "TUNNEL_URL=%TUNNEL_URL::=%"

:: Copie magique dans le presse-papiers Windows
echo | set /p="%TUNNEL_URL%" | clip

echo =======================================================
echo  🔗 URL : %TUNNEL_URL%
echo  📋 Le lien a ete COPIE automatiquement ! (Ctrl+V)
echo =======================================================

:end
:: Supprime le fichier temporaire
if exist tunnel.txt del tunnel.txt
:: Garde la fenêtre ouverte pour lire l'URL
cmd /k
