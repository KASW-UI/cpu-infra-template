.PHONY: build pull run shell verify healthcheck snapshot nccl-test stop logs clean compose-up compose-down

include env/versions.env
export

REGISTRY   ?= ghcr.io/KASW-UI/gpu-infra-template
IMAGE_NAME ?= gpu-infra-template
IMAGE_TAG  ?= cuda$(CUDA_VERSION)-torch$(TORCH_VERSION)

DOCKERFILE   := docker/Dockerfile
COMPOSE_FILE := deploy/docker/docker-compose.yml
CONTEXT      := .

build:
	@echo "==> Building $(IMAGE_NAME):$(IMAGE_TAG)"
	docker build \
		--build-arg CUDA_VERSION=$(CUDA_VERSION) \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg TORCH_VERSION=$(TORCH_VERSION) \
		--build-arg TRITON_VERSION=$(TRITON_VERSION) \
		--build-arg UBUNTU_VERSION=$(UBUNTU_VERSION) \
		-t $(IMAGE_NAME):$(IMAGE_TAG) \
		-f $(DOCKERFILE) \
		$(CONTEXT)
	@echo "==> Generating manifest.json"
	@docker inspect $(IMAGE_NAME):$(IMAGE_TAG) --format '{{json .}}' | \
		jq '{ \
			project: "gpu-infra-template", \
			image: "$(IMAGE_NAME):$(IMAGE_TAG)", \
			digest: .RepoDigests[0], \
			base_image: "nvidia/cuda:$(CUDA_VERSION)-devel-ubuntu$(UBUNTU_VERSION)", \
			built_at: .Created, \
			cuda: "$(CUDA_VERSION)", \
			python: "$(PYTHON_VERSION)", \
			torch: "$(TORCH_VERSION)+cu124", \
			triton: "$(TRITON_VERSION)", \
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
	docker compose -f $(COMPOSE_FILE) exec gpu-dev bash

verify:
	docker compose -f $(COMPOSE_FILE) exec gpu-dev bash /workspace/scripts/verify.sh

healthcheck:
	docker compose -f $(COMPOSE_FILE) exec gpu-dev bash /workspace/scripts/healthcheck.sh

snapshot:
	docker compose -f $(COMPOSE_FILE) exec gpu-dev bash /workspace/scripts/snapshot.sh

nccl-test:
	docker compose -f $(COMPOSE_FILE) exec gpu-dev bash /workspace/scripts/nccl-test.sh

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
		--index-url https://download.pytorch.org/whl/cu124 \
		--extra-index-url https://pypi.org/simple \
		--python-version $(PYTHON_VERSION) \
		-o env/requirements.lock
	@echo "==> Generating requirements-hash.lock"
	uv pip compile env/requirements.in \
		--index-url https://download.pytorch.org/whl/cu124 \
		--extra-index-url https://pypi.org/simple \
		--python-version $(PYTHON_VERSION) \
		--generate-hashes \
		-o env/requirements-hash.lock
	@echo "==> Lock files generated"
