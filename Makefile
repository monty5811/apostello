dev:
	@venv/bin/python manage.py runserver 0.0.0.0:4000

shell_plus:
	@venv/bin/python manage.py shell_plus

watchjs:
	@cd assets && yarn watchjs

watchcss:
	@cd assets && yarn watchcss

build_assets:
	@cd assets && yarn build

test:
	@venv/bin/tox

setup_env:
	@rm -rf venv && \
	python -m venv venv && \
	venv/bin/pip install -r requirements/test.txt && \
	cd assets && \
	rm -rf node_modules elm-stuff tests-elm/elm-stuff && \
	yarn

heroku_create_build:
	@heroku builds:create # requires https://github.com/heroku/heroku-builds

format:
	black -l 120 --py36 apostello/ api/ elvanto/ site_config/ graphs/ onebody/ tests/ docs/ settings/
