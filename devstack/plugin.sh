#!/bin/bash

# Flask dependencies function
function install_flask_dependencies {
    echo "Installing Flask and dependencies..."

    # Ensure Python3 is available
    if ! command -v python3 &> /dev/null; then
        echo "Python3 not found! Please install Python3."
        exit 1
    fi

    # Create venv if not exists
    if [[ ! -d "$APP_DIR/venv" ]]; then
        python3 -m venv "$APP_DIR/venv" || { echo "Failed to create venv"; exit 1; }
    fi

    # Activate venv
    source "$APP_DIR/venv/bin/activate" || { echo "Failed to activate venv"; exit 1; }

    # Install requirements
    if [[ -f "$APP_DIR/requirements.txt" ]]; then
        pip install -r "$APP_DIR/requirements.txt" || { echo "Failed to install dependencies"; deactivate; exit 1; }
    else
        echo "requirements.txt not found!"
        deactivate
        exit 1
    fi

    deactivate
}

# Move service file function
function copy_service_file {
    echo "Moving service file to systemd directory..."
    sudo cp "$SERVICE_DIR/openstack-plugin-flask.service" "$SYSTEMD_DIR" || { echo "Failed to copy service file"; exit 1; }
    sudo systemctl enable openstack-plugin-flask.service || { echo "Failed to enable systemd plugin service"; exit 1; }
    sudo systemctl daemon-reload || { echo "Failed to reload systemd daemon"; exit 1; }
}

# Start flask plugin
function start_flask_plugin {
    echo "Starting Flask service..."
    sudo systemctl start openstack-plugin-flask.service || { echo "Failed to start service"; exit 1; }
}

# Configure flask plugin
function configure_flask_plugin {
    echo "Configuring Flask service..."
    # Add configuration here
}

if is_service_enabled openstack-plugin-flask; then

    if [[ "$1" == "stack" && "$2" == "pre-install" ]]; then
        echo_summary "No additional packages to install for Flask Plugin."

    elif [[ "$1" == "stack" && "$2" == "install" ]]; then
        echo_summary "Installing Flask Plugin"
        install_flask_dependencies
        copy_service_file

    elif [[ "$1" == "stack" && "$2" == "post-config" ]]; then
        echo_summary "Configuring Flask Plugin"
        configure_flask_plugin

    elif [[ "$1" == "stack" && "$2" == "extra" ]]; then
        echo_summary "Initializing Flask Plugin"
        start_flask_plugin
    fi

    if [[ "$1" == "unstack" ]]; then
        echo_summary "Stopping Flask service..."
        sudo systemctl stop openstack-plugin-flask.service || { echo "Failed to stop service"; exit 1; }
    fi

    if [[ "$1" == "clean" ]]; then
        echo_summary "Cleaning up Flask service..."
        sudo rm "$SYSTEMD_DIR/openstack-plugin-flask.service"
    fi
fi
