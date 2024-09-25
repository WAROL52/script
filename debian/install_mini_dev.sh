#!/bin/bash

# Met à jour la liste des paquets
sudo apt update

# Liste des programmes à installer
programs=(
    git
    curl
    wget
    vim
    htop
    build-essential
    python3
    nodejs
    npm
    openssh-server  # Si non déjà installé
    cockpit         # Cockpit pour l'administration via l'interface web
    fish            # Fish shell
)

# Boucle pour installer chaque programme
for program in "${programs[@]}"; do
    echo "Installation de $program..."
    sudo apt install -y $program
done

# Installation de VSCode Server via le script officiel
echo "Installation de VSCode Server..."
curl -fsSL https://code-server.dev/install.sh | sh

# Créer le service systemd pour VSCode Server
echo "Création du service systemd pour VSCode Server..."

sudo bash -c 'cat > /etc/systemd/system/code-server.service <<EOF
[Unit]
Description=VSCode Server
After=network.target

[Service]
Type=simple
User='"$USER"'
ExecStart=/usr/bin/code-server --bind-addr 0.0.0.0:8080
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF'

# Recharger systemd pour prendre en compte le nouveau service
sudo systemctl daemon-reload

# Activer le service pour qu'il démarre automatiquement au démarrage
sudo systemctl enable code-server

# Démarrer le service maintenant
sudo systemctl start code-server

# Installation et configuration de Cockpit
echo "Installation et configuration de Cockpit..."
sudo systemctl enable --now cockpit.socket

# Vérifie que Cockpit est en cours d'exécution
sudo systemctl status cockpit

echo "Cockpit est installé et accessible à l'adresse http://<adresse_ip_de_ta_vm>:9090"

# Changer le shell par défaut pour Fish
echo "Configuration de Fish comme shell par défaut..."
chsh -s /usr/bin/fish $USER

echo "Fish est maintenant le shell par défaut pour l'utilisateur $USER"

echo "Tous les programmes ont été installés avec succès !"
