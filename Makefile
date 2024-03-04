#################################################################################
#
# Makefile to build the project
#
#################################################################################

PROJECT_NAME = totesys-de 
REGION = eu-west-2
PYTHON_INTERPRETER = python3.12
WD=$(shell pwd)
PYTHONPATH=${WD}
SHELL := /bin/bash
PROFILE = default
PIP:=pip
ROOT_DIR := $(shell pwd)
ACTIVATE_ENV := source venv/bin/activate

## Create python interpreter environment.
create-environment:
	@echo ">>> About to create environment: $(PROJECT_NAME)..."
	@echo ">>> check python3 version"
	( \
		$(PYTHON_INTERPRETER) --version; \
	)
	@echo ">>> Setting up VirtualEnv."
	( \
		export PYTHONPATH=$(ROOT_DIR);\
	    $(PIP) install -q virtualenv virtualenvwrapper; \
	    virtualenv venv --python=$(PYTHON_INTERPRETER); \
		${ACTIVATE_ENV}; \
	)

# Execute python related functionalities from within the project's environment
define execute_in_env
	$(ACTIVATE_ENV) && $1
endef

## Build the environment requirements
requirements: create-environment
	$(call execute_in_env, $(PIP) install -r ./requirements.txt)

################################################################################################################

# ## Run the flake8 code check
# run-flake:
# 	$(call execute_in_env, flake8  ./src/*/*.py ./test/*/test_*.py ./src/*.py ./test/test_*.py)

# run-autopep:
# 	$(call execute_in_env, autopep8  ./src/*/*.py ./test/*/test_*.py ./src/*.py ./test/test_*.py)


# # Set Up
# ## Install bandit
# bandit:
# 	$(call execute_in_env, $(PIP) install bandit)

# # ## Install safety
# safety:
# 	$(call execute_in_env, $(PIP) install safety)

# # ## Install flake8
# flake:
# 	$(call execute_in_env, $(PIP) install flake8)

# # ## Install coverage
# # coverage:
# # 	$(call execute_in_env, $(PIP) install coverage)

# # ## Set up dev requirements (bandit, safety, flake8)
# dev-setup: bandit safety flake coverage

# # # Build / Run

# # ## Run the security test (bandit + safety)
# security-test:
# 	$(call execute_in_env, safety check -r ./requirements.txt)
# 	$(call execute_in_env, bandit -lll */*.py *c/*/*.py)



# ## Run the all unit tests
# unit-test:
# 	$(call execute_in_env, PYTHONPATH=${PYTHONPATH} pytest -v)

# # ## Run a single test
# # test:
# # 	$(call execute_in_env, PYTHONPATH=${PYTHONPATH} pytest --testdox -vvrP ${test_run} )

# ## Run the coverage check
# check-coverage:
# 	$(call execute_in_env, PYTHONPATH=${PYTHONPATH} coverage run --omit 'venv/*' -m pytest && coverage report -m)

# # ## Run all checks
# # run-checks: security-test run-flake 

