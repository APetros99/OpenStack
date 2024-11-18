function plugin_install {
    echo "Installazione di Kubernetes"

    sudo curl -LO $KUBECTL_INSTALL_URL
    sudo chmod +x kubectl
    sudo mv kubectl /usr/local/bin/

    sudo apt-get update
    sudo apt-get install -y kubeadm kubelet kubernetes-cni
}

function plugin_configure {
    echo "Configurazione di Kubernetes con OpenStack"

    openstack network create kubernetes-network
    openstack subnet create --network kubernetes-network --subnet-range 192.168.1.0/24 kubernetes-subnet
}

function plugin_start {
    echo "Avvio del cluster Kubernetes"

    openstack server create --image <image-id> --flavor <flavor-id> \
	--network kubernetes-network --key-name <key-name> master-node
    for i in $(seq 1 $K8S_NODE_COUNT); do
	openstack server create --image<image-id> --flavor <flavor-id> \
	    --network kubernetes-network --key-name <key-name> worker-node-$i
    done

}