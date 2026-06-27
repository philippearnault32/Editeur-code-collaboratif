@echo off
title Script d'Automatisation de l'IDE Collaboratif
cls

echo ===================================================
echo    Lancement de l'IDE Collaboratif Synchrone
echo ===================================================
echo.

:: 1. Lancement du serveur backend Node.js dans une fenêtre séparée
echo [1/3] Lancement du serveur Backend Node.js...
start "Serveur Backend Node" cmd /k "node backend.js"

:: Attente de 3 secondes pour s'assurer que le serveur est bien initialisé
timeout /t 3 /nobreak >nul

echo.
echo [2/3] Initialisation du tunnel public (Localtunnel)...
echo       Recuperation automatique du lien en cours...

:: 2. Lancement de localtunnel en enregistrant sa sortie dans un fichier temporaire propre
:: On utilise un nom unique pour éviter les blocages de processus
set "temp_tunnel_file=%TEMP%\lt_current_url.txt"
if exist "%temp_tunnel_file%" del "%temp_tunnel_file%"

:: On lance localtunnel en tâche de fond et on redirige le flux vers notre fichier temporaire
start /b cmd /c "npx localtunnel --port 8080 > "%temp_tunnel_file%""

:: Attente que localtunnel génère l'URL (environ 4 secondes)
timeout /t 4 /nobreak >nul

:: Lecture du fichier temporaire pour extraire l'URL
set "raw_url="
for /f "tokens=2* delims= " %%A in ('findstr "url" "%temp_tunnel_file%"') do set "raw_url=%%B"

:: Si findstr n'a pas fonctionné selon le formatage, on prend la première ligne valide
if "%raw_url%"=="" (
    for /f "usebackq tokens=*" %%A in ("%temp_tunnel_file%") do (
        set "line=%%A"
        setlocal enabledelayedexpansion
        if not "!line:https://=!"=="!line!" set "raw_url=%%A"
        endlocal
    )
)

:: Nettoyage de l'URL pour ne garder que le sous-domaine (ex: twelve-walls-rhyme.loca.lt)
if not "%raw_url%"=="" (
    set "clean_url=%raw_url:https://=%"
    set "clean_url=%clean_url:http://=%"
    
    echo.
    echo [Succes] URL publique detectee : !raw_url!
    echo [3/3] Generation automatique du lien de redirection...
    
    :: 3. Ouverture automatique du navigateur par défaut avec l'URL formatée
    echo       Ouverture de l'adresse : http://localhost:8080/?tunnel=!clean_url!
    start http://localhost:8080/?tunnel=!clean_url!
) else (
    echo.
    echo [Alerte] Impossible de lire l'URL automatiquement.
    echo Vérifiez que localtunnel est installé et fonctionnel en tapant : npx localtunnel --port 8080
)

echo.
echo ===================================================
echo L'environnement est prêt. Laissez cette fenêtre ouverte.
echo ===================================================
echo.
pause
