-include env_make

PHP_VER ?= 7.2
TAG ?= $(PHP_VER)

REPO = wodby/wordpress-php
NAME = wordpress-php-$(TAG)
FROM_TAG = $(PHP_VER)

ifneq ($(PHP_DEBUG),)
    override TAG := $(TAG)-debug
    FROM_TAG := $(FROM_TAG)-debug
    NAME := $(NAME)-debug
endif

ifneq ($(FROM_STABILITY_TAG),)
    FROM_TAG := $(FROM_TAG)-$(FROM_STABILITY_TAG)
endif

ifneq ($(STABILITY_TAG),)
ifneq ($(TAG),latest)
    override TAG := $(TAG)-$(STABILITY_TAG)
endif
endif

.PHONY: build test push shell run start stop logs clean release

default: build

build:
	docker build -t $(REPO):$(TAG) --build-arg FROM_TAG=$(FROM_TAG) ./

test:
	cd ./test/4 && IMAGE=$(REPO):$(TAG) ./run.sh

push:
	docker push $(REPO):$(TAG)

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) /bin/bash

run:
	docker run --rm --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) $(CMD)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	-docker rm -f $(NAME)

release: build push
