@echo off
setlocal enabledelayedexpansion
title IDE Collaboratif Auto-Pilote

echo [1/3] Demarrage du serveur Node.js...
start /b node backend.js

echo [2/3] Generation du tunnel internet en arriere-plan...
:: On lance localtunnel et on redirige sa sortie vers un fichier texte temporaire
start /b npx lt --port 8080 > tunnel.txt

echo Attente de la generation du lien...
:wait
timeout /t 1 /nobreak >nul
if not exist tunnel.txt goto wait

:: On cherche la ligne contenant "url:" dans le fichier texte
for /f "tokens=2 delims= " %%a in ('findstr "url:" tunnel.txt') do (
    set "URL=%%a"
)

:: Si l'URL n'est pas encore ecrite, on patiente encore
if "!URL!"=="" goto wait

:: Nettoyage de l'URL pour ne garder que le nom de domaine
set "CLEAN_URL=!URL:https://=!"
set "CLEAN_URL=!CLEAN_URL:http://=!"

echo [3/3] Lien genere : !URL!
echo Ouverture automatique de l'IDE...

:: On ouvre le index.html en lui injectant directement l'URL du tunnel !
start index.html?tunnel=!CLEAN_URL!

:: Nettoyage du fichier temporaire
del tunnel.txt
