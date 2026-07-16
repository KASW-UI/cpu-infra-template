.PHONY: build pull run shell verify healthcheck snapshot mpi-test hpc-bench stop logs clean compose-up compose-down lock

include env/versions.env
export

REGISTRY   ?= ghcr.io/kasw-ui/cpu-infra-template
IMAGE_NAME ?= cpu-infra-template
IMAGE_TAG  ?= cpu-hpc-ubuntu$(UBUNTU_VERSION)

DOCKERFILE   := docker/Dockerfile
COMPOSE_FILE := deploy/docker/docker-compose.yml
CONTEXT      := .

build:
	@echo "==> Building $(IMAGE_NAME):$(IMAGE_TAG)"
	docker build \
		--build-arg UBUNTU_VERSION=$(UBUNTU_VERSION) \
		-t $(IMAGE_NAME):$(IMAGE_TAG) \
		-f $(DOCKERFILE) \
		$(CONTEXT)
	@echo "==> Generating manifest.json"
	@docker inspect $(IMAGE_NAME):$(IMAGE_TAG) --format '{{json .}}' | \
		jq '{ \
			project: "cpu-infra-template", \
			image: "$(IMAGE_NAME):$(IMAGE_TAG)", \
			digest: .RepoDigests[0], \
			base_image: "ubuntu:$(UBUNTU_VERSION)", \
			built_at: .Created, \
			os: .Os, \
			architecture: .Architecture, \
			docker_version: .DockerVersion, \
			size: .Size \
		}' > manifest.json
	@echo "==> Build complete"
	@cat manifest.json

pull:
	@echo "==> Pulling $(REGISTRY):latest"
	docker pull $(REGISTRY):latest
	@echo "==> Tagging as $(IMAGE_NAME):$(IMAGE_TAG)"
	docker tag $(REGISTRY):latest $(IMAGE_NAME):$(IMAGE_TAG)
	@echo "==> Pull complete"

run:
	@echo "==> Starting container with compose"
	docker compose -f $(COMPOSE_FILE) up -d

shell:
	docker compose -f $(COMPOSE_FILE) exec cpu-dev bash

verify:
	docker compose -f $(COMPOSE_FILE) exec cpu-dev bash /workspace/scripts/verify.sh

healthcheck:
	docker compose -f $(COMPOSE_FILE) exec cpu-dev bash /workspace/scripts/healthcheck.sh

snapshot:
	docker compose -f $(COMPOSE_FILE) exec cpu-dev bash /workspace/scripts/snapshot.sh

mpi-test:
	docker compose -f $(COMPOSE_FILE) exec cpu-dev bash /workspace/scripts/mpi-test.sh

hpc-bench:
	docker compose -f $(COMPOSE_FILE) exec cpu-dev bash /workspace/scripts/hpc-bench.sh

stop:
	docker compose -f $(COMPOSE_FILE) down

logs:
	docker compose -f $(COMPOSE_FILE) logs -f

clean:
	docker compose -f $(COMPOSE_FILE) down -v --rmi local 2>/dev/null || true
	rm -f manifest.json

lock:
	@echo "==> Generating requirements.lock"
	uv pip compile env/requirements.in \
		--python-version 3.10 \
		-o env/requirements.lock
	@echo "==> Generating requirements-hash.lock"
	uv pip compile env/requirements.in \
		--python-version 3.10 \
		--generate-hashes \
		-o env/requirements-hash.lock
	@echo "==> Lock files generated"
