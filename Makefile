setup:
	python3 -m venv ~/.udacity-devops

install:
	pip install --upgrade pip &&\
		pip install -r requirements.txt

test:
	pytest --disable-warnings test_prediction.py


lint:
	#uncomment to explore linting Dockerfiles
	pylint --disable=R,C,W1203,W0702 app.py

all: install lint test
