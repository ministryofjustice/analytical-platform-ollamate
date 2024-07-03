#!/usr/bin/env bash

# Upgrade NPM
npm install --global npm@latest

# Start Postgres
docker compose --file contrib/docker-compose-postgres.yml up --detach

# Start Ollama Container
docker compose --file contrib/docker-compose-ollama.yml up --detach

# Start Ollama Model
docker exec -it contrib-ollama-1 ollama run orca-mini

# Upgrade Pip
pip install --break-system-package --upgrade pip

# Install dependencies
pip install --break-system-package --requirement requirements.dev.txt

# install npm dependencies and static assets
# npm install
# make build-static

# Run migrations
python manage.py migrate
