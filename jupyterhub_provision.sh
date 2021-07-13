#!/usr/bin/env bash

# print commands and their expanded arguments
set -x

cd /opt
apt-get update 
apt-get install -y python3-venv python3-pip nginx git

git clone https://github.com/HSPH-QBRC/jupyterhub-terraform.git

# Install jupyterhub and associated packages:
cd jupyterhub-terraform/
pip3 install -U pip
pip3 install --no-cache-dir -r ./requirements.txt

# The following allows dynamic 3-d plotting
curl -sL https://deb.nodesource.com/setup_16.x | /usr/bin/bash -
apt-get install -y nodejs
jupyter labextension install @jupyter-widgets/jupyterlab-manager jupyter-matplotlib

npm install -g configurable-http-proxy

cd /opt
mkdir -p /opt/jupyterhub/etc/jupyterhub
cd jupyterhub/etc/jupyterhub
/usr/local/bin/jupyterhub --generate-config

# Edit the jupyterhub config file:
sed -i "s?^# c.JupyterHub.bind_url = 'http://:8000'?c.JupyterHub.bind_url = 'http://:8000/jupyter'?g" /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py
sed -i "s?^# c.Spawner.default_url = ''?c.Spawner.default_url = '/lab'?g" /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py

# Removing the existing default conf and create an nginx conf file
rm /etc/nginx/sites-enabled/default
cat > /etc/nginx/sites-enabled/jupyter.conf <<"EOF"
server {

  listen 80;
  listen [::]:80;

  location /jupyter/ {    
    # NOTE important to also set base url of jupyterhub to /jupyter in its config
    proxy_pass http://127.0.0.1:8000;

    proxy_redirect   off;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_http_version 1.1;

    # websocket headers
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
  }
}
EOF

# Now restart nginx so the new conf loads:
service nginx restart

# Setup jupyterhub as a service
mkdir -p /opt/jupyterhub/etc/systemd
cat > /opt/jupyterhub/etc/systemd/jupyterhub.service<<"EOF"
[Unit]
Description=JupyterHub
After=syslog.target network.target

[Service]
User=root
Environment="PATH=/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"
ExecStart=/usr/local/bin/jupyterhub -f /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py

[Install]
WantedBy=multi-user.target
EOF

# Load and start the service
ln -s /opt/jupyterhub/etc/systemd/jupyterhub.service /etc/systemd/system/jupyterhub.service
systemctl daemon-reload
systemctl enable jupyterhub.service
systemctl start jupyterhub.service
