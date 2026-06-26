#!/bin/bash

echo "[1/3] Démarrage du serveur Node.js..."
node backend.js &
PID_NODE=$!

echo "[2/3] Génération du tunnel internet en arrière-plan..."
# On lance localtunnel et on écrit le résultat dans un fichier temporaire
npx lt --port 8080 > tunnel.txt &
PID_TUNNEL=$!

echo "Attente de la génération du lien..."
# Boucle pour attendre que le fichier contienne l'URL du tunnel
URL=""
while [ -z "$URL" ]; do
    sleep 1
    if [ -f tunnel.txt ]; then
        URL=$(grep "url:" tunnel.txt | awk '{print $2}')
    fi
done

# Nettoyage de l'URL pour enlever le https:// ou http://
CLEAN_URL=$(echo "$URL" | sed -e 's/https:\/\///' -e 's/http:\/\///')

echo "[3/3] Lien généré : $URL"
echo "Ouverture automatique de l'IDE..."

# Détection de l'OS pour ouvrir le navigateur correctement
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Pour macOS
    open "index.html?tunnel=$CLEAN_URL"
else
    # Pour Linux
    xdg-open "index.html?tunnel=$CLEAN_URL" 2>/dev/null || sensible-browser "index.html?tunnel=$CLEAN_URL"
fi

# Supprime le fichier temporaire
rm tunnel.txt

# Maintient le script parent éveillé pour pouvoir couper les processus enfants proprement avec Ctrl+C
trap "kill $PID_NODE $PID_TUNNEL; exit" INT TERM
wait
