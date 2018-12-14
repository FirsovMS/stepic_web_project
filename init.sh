#!/usr/bin/env bash

echo "Update & Upgrade"
sudo apt-get update && sudo apt-get upgrade

echo "Create symbolic link to a new nginx config"
sudo -s ln -sf /home/box/web/etc/nginx.conf  /etc/nginx/sites-enabled/django.conf
sudo -s rm /etc/nginx/sites-enabled/default

echo "Restart nginx"
sudo -s /etc/init.d/nginx restart

echo "Run MySQL & create DB"
sudo -s /etc/init.d/mysql start && \
    mysql -uroot -e "CREATE DATABASE django"

echo "Create environment for web app ad run"
cd /home/box/web && \
    virtualenv venv && \
    source venv/bin/activate && \
    echo "Update setup-tools" && \
    sudo pip install --upgrade pip setuptools && \
    sudo pip install -r etc/list.txt && \
    export PYTHONPATH=$(pwd):$PYTHONPATH && \
    cd /home/box/web/ && \
    python manage.py migrate && \
    python manage.py makemigrations && \
    exec gunicorn --bind=0.0.0.0:8000 --workers=4 ask.wsgi:application