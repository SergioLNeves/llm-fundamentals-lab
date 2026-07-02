VENV    := .venv
PYTHON  := $(VENV)/bin/python
PIP     := $(VENV)/bin/pip
UVICORN := $(VENV)/bin/uvicorn

TAILWIND  := bin/tailwindcss
CSS_IN    := app/frontend/static/styles.css
CSS_OUT   := app/frontend/static/output.css
TEMPLATES := app/frontend/templates

.PHONY: venv install css css-watch run kill

venv:
	python3 -m venv $(VENV)

install: venv
	$(PIP) install -r requirements.txt

$(TAILWIND):
	mkdir -p bin
	curl -sLo $(TAILWIND) https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-linux-x64
	chmod +x $(TAILWIND)

run: $(TAILWIND)
	$(TAILWIND) -i $(CSS_IN) -o $(CSS_OUT) --content "$(TEMPLATES)/**/*.html" --watch & \
	$(UVICORN) app.api.main:app --reload --reload-dir app; \
	kill %1

kill:
	-pkill -f "tailwindcss"
	-pkill -f "uvicorn app.api.main"
