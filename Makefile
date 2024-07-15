#!make

db-migrate:
	python manage.py migrate

db-drop:
	python manage.py reset_db

serve:
	python manage.py runserver

container:
	docker build -t ollamate .

test: container
	@echo
	@echo "> Running Python Tests (In Docker)..."
	IMAGE_TAG=ollamate docker compose --file=contrib/docker-compose-test.yml run --rm interfaces

ct:
	ct lint --charts chart
