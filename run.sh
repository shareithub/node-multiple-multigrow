#!/bin/bash

# Menampilkan header
echo "=============================================="
echo "         M  U  L  T  I  G  R  O  W           "
echo "           T  E  S  T  N  E  T              "
echo "        =============================       "
echo "           By Share It Hub                  "
echo "=============================================="
echo "  Welcome to the MultiGrow Testnet Installer  "
echo "  Let's get started with the setup process!  "
echo "=============================================="
echo ""
echo "=============================================="
echo "     To check the status of your node, you    "
echo "       can use the following commands:        "
echo "=============================================="
echo ""
echo "1. Check if the node process is running:"
echo "   ps aux | grep multiple-node"
echo ""
echo "2. Alternatively, use pgrep to find the PID:"
echo "   pgrep -af multiple-node"
echo ""
echo "3. If you are using systemd (as a service), you can run:"
echo "   systemctl status multiple-node.service"
echo ""
echo "4. To see the logs of the node, check the output.log file:"
echo "   tail -f output.log"
echo ""
echo "=============================================="
echo "  If you need further assistance, feel free to ask! "
echo "=============================================="
echo ""

# Fungsi untuk menghentikan node dan menghapus file lama
clean_up() {
    echo "Stopping node..."
    pkill -f multiple-node  # Menghentikan semua proses yang menggunakan multiple-node
    sleep 2

    echo "Removing downloaded files and old installation..."
    rm -rf multipleforlinux.tar multipleforlinux  # Menghapus file tar dan folder hasil ekstraksi
    sleep 2

    echo "Node stopped and old files removed."
}

# Fungsi untuk memulai ulang node
restart_node() {
    echo "Starting system update..."
    sudo apt update && sudo apt upgrade -y

    echo "Checking system architecture..."
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        CLIENT_URL="https://cdn.app.multiple.cc/client/linux/x64/multipleforlinux.tar"
    elif [[ "$ARCH" == "aarch64" ]]; then
        CLIENT_URL="https://cdn.app.multiple.cc/client/linux/arm64/multipleforlinux.tar"
    else
        echo "Unsupported system architecture: $ARCH"
        exit 1
    fi

    echo "Downloading the client from $CLIENT_URL..."
    wget $CLIENT_URL -O multipleforlinux.tar

    echo "Extracting files..."
    tar -xvf multipleforlinux.tar

    cd multipleforlinux

    echo "Granting permissions..."
    chmod +x ./multiple-cli
    chmod +x ./multiple-node

    echo "Adding directory to system PATH..."
    echo "PATH=\$PATH:$(pwd)" >> ~/.bash_profile
    source ~/.bash_profile

    echo "Setting permissions..."
    chmod -R 777 $(pwd)

    echo "Launching multiple-node..."
    nohup ./multiple-node > output.log 2>&1 &

    echo "Please enter your Account ID and PIN to bind your account:"
    read -p "Account ID: " IDENTIFIER
    read -p "Set your PIN: " PIN

    echo "Binding account with ID: $IDENTIFIER and PIN: $PIN..."
    multiple-cli bind --bandwidth-download 200 --identifier $IDENTIFIER --pin $PIN --storage 200 --bandwidth-upload 200

    echo "Installation completed successfully!"
    echo "Channel Telegram: https://t.me/SHAREITHUB_COM"
}

# Menanyakan apakah pengguna ingin menghentikan node lama dan memulai dari awal
echo "Do you want to stop the existing node and restart the installation from scratch? (yes/no)"
read RESPONSE
if [[ "$RESPONSE" == "yes" ]]; then
    clean_up  # Menghentikan node dan menghapus file lama
    restart_node  # Memulai ulang node dari awal
else
    echo "Skipping cleanup and restart."
    exit 0
fi
