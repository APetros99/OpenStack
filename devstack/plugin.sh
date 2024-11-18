function plugin_install {
    echo "Installazione di Kubernetes"

    # Installazione di kubectl
    sudo curl -LO $KUBECTL_INSTALL_URL
    sudo chmod +x kubectl
    sudo mv kubectl /usr/local/bin/

    # Installazione di kubeadm e kubelet
    sudo apt-get update
    sudo apt-get install -y kubeadm kubelet kubernetes-cni
}
