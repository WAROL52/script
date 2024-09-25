#!/bin/bash

# Demander le nom d'utilisateur
printf "Entrez le nom d'utilisateur à vérifier pour les droits sudo :\n> "
read username

# Vérifier si l'utilisateur existe
if id "$username" &>/dev/null; then
    # Vérifier si l'utilisateur a les droits sudo
    if sudo -l -U "$username" &>/dev/null; then
        echo "L'utilisateur '$username' a les droits sudo."
    else
        echo "L'utilisateur '$username' n'a pas les droits sudo."
        echo "Voulez-vous lui accorder des droits sudo ? (o/n)"
        read -r answer
        if [[ "$answer" == "o" || "$answer" == "O" ]]; then
            # Ajouter l'utilisateur au groupe sudo
            echo "Ajout de '$username' au groupe sudo..."
            sudo usermod -aG sudo "$username"
            echo "L'utilisateur '$username' a maintenant des droits sudo."
        else
            echo "Aucune modification effectuée."
        fi
    fi
else
    echo "L'utilisateur '$username' n'existe pas."
fi


# Met à jour la liste des paquets
sudo apt update

# Vérifier et installer curl si nécessaire
if ! command -v curl &> /dev/null
then
    echo "curl n'est pas installé. Installation de curl..."
    sudo apt install -y curl
fi

# Liste des programmes à installer
programs=(
    git
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
