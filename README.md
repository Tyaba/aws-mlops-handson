# AWS MLOps Handson
This repository is designed to provide a comprehensive ML infrastructure for CTR (Click-Through Rate) prediction.
With a focus on AWS services, this repository offer practical learning experience for MLOps.

This repository is based on [nsakki55/aws-mlops-handson](https://github.com/nsakki55/aws-mlops-handson/tree/main)(2023). I have made some version upgrades and bug fixes and have published this repository with the consent of [nsakki55](https://github.com/nsakki55).

Slide[japanese]: https://speakerdeck.com/tyaba/mlops-handson

## Key Features
### Python Development Environment
We guide you through setting up a Python development environment that ensures code quality and maintainability.
This environment is carefully configured to enable efficient development practices and facilitate collaboration.

### Train Pipeline
This repository includes the implementation of a training pipeline.
This pipeline covers the stages, including data preprocessing, model training, and evaluation.

### Prediction Server
This repository provides an implementation of a prediction server that serves predictions based on your trained CTR prediction model.

### AWS Deployment
To showcase industry-standard practices, this repository guide you in deploying the training pipeline and inference server on AWS.


## AWS Infra Architecture
AWS Infra Architecture made by this repository.

### ML Pipeline
![ml_pipeline](https://github.com/Tyaba/aws-mlops-handson/assets/44280132/4548e4ce-b4cb-49ec-8b8f-a3e88eb2d30a)

### Predict Server
![predict_server](https://github.com/Tyaba/aws-mlops-handson/assets/44280132/2ff9e00b-220c-4b96-ab2b-c4dfb880c173)

## Requirements
| Software                   | Install (Mac)              |
|----------------------------|----------------------------|
| [pyenv](https://github.com/pyenv/pyenv#installation)             | `brew install pyenv`       |
| [Poetry](https://python-poetry.org/docs/#installation)           | curl -sSL https://install.python-poetry.org &#x7C; python3 - |
| [direnv](https://formulae.brew.sh/formula/direnv)           | `brew install direnv`      |
| [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform)    | `brew install terraform`   |
| [Docker](https://docs.docker.com/desktop/install/mac-install/) | install via dmg |
| [awscli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-installjkkkkj.html) | `curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"` |

## Setup
### Install Python Dependencies
Use `pyenv` to install Python 3.11.7 environment
```bash
$ pyenv install 3.11.7
$ pyenv local 3.11.7
```

Use `poetry` to install library dependencies
```bash
$ poetry install
```

### Configure environment variable
Use `direnv` to configure environment variable
```bash
$ cp .env.sample .env
$ direnv allow .
```

## Usage
Build ML Pipeline
```bash
$ make build-ml
```

Run ML Pipeline
```bash
$ make run-ml
```

Build Predict API
```bash
$ make build-predictor
```

Run Predict API locally
```bash
$ make up
```

Shutdown Predict API locally
```bash
$ make down
```

Run formatter
```bash
$ make format
```

Run linter
```bash
$ make lint
```

Run pytest
```bash
$ make test
```

Show options
```bash
$ make help
```
