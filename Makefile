#!make

IMAGE_NAME=ghcr.io/ministryofjustice/analytical-platform-ollamate:local

phony: test

build-static:
	make build-css
	make build-js

build-css:
	mkdir -p static/assets/fonts
	mkdir -p static/assets/images
	cp -R node_modules/govuk-frontend/dist/govuk/assets/fonts/. static/assets/fonts
	cp -R node_modules/govuk-frontend/dist/govuk/assets/images/. static/assets/images
	npm run css

build-js:
	mkdir -p static/assets/js
	cp node_modules/govuk-frontend/dist/govuk/all.bundle.js static/assets/js/govuk.js
	cp node_modules/govuk-frontend/dist/govuk/all.bundle.js.map static/assets/js/govuk.js.map

db-migrate:
	python manage.py migrate

db-drop:
	python manage.py reset_db

serve:
	python manage.py runserver

build-container:
	@ARCH=`uname -m`; \
	case $$ARCH in \
	aarch64 | arm64) \
		echo "Building on $$ARCH architecture"; \
		docker build --platform linux/amd64 --file container/Dockerfile --tag $(IMAGE_NAME) . ;; \
	*) \
		echo "Building on $$ARCH architecture"; \
		docker build --file container/Dockerfile --tag $(IMAGE_NAME) . ;; \
	esac

cst: build-container
	container-structure-test test --platform linux/amd64 --config container/test/container-structure-test.yml --image $(IMAGE_NAME)

test: build-container
	@echo
	@echo "> Running Python Tests (In Docker)..."
	export IMAGE_TAG=$(IMAGE_NAME); env | grep IMAGE; docker compose --file=contrib/docker-compose-test.yml run --rm interfaces

ct:
	ct lint --charts chart


super-linter:
	docker run -e RUN_LOCAL=true \
	-e DEFAULT_BRANCH=main \
	-e VALIDATE_ALL_CODEBASE=false \
	-e LINTER_RULES_PATH=/ \
	-e PYTHON_BLACK_CONFIG_FILE=pyproject.toml \
	-e PYTHON_FLAKE8_CONFIG_FILE=.flake8 \
	-e PYTHON_ISORT_CONFIG_FILE=pyproject.toml \
	-e PYTHON_MYPY_CONFIG_FILE=mypy.ini \
	-e VALIDATE_KUBERNETES_KUBECONFORM=false \
	-v $(shell pwd):/tmp/lint github/super-linter
