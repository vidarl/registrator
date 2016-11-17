NAME=vidarl_registrator
VERSION=$(shell cat VERSION)
DEV_RUN_OPTS ?= consul:

dev:
	docker build -f Dockerfile.dev -t $(NAME):dev .
	docker run --rm \
		-v /var/run/docker.sock:/tmp/docker.sock \
		$(NAME):dev /bin/registrator $(DEV_RUN_OPTS)

# When using the ezdev target, you likely wanna use the dev target first to make the image. Then use ezdev which will mount the registrator source on host inside the container using volume
# Once you have done code changes, you may restart the container using:
# $docker rm -vf registrator; make ezdev; docker logs --follow registrator
ezdev:
	docker run --name=registrator -d -v /var/run/docker.sock:/tmp/docker.sock \
		-h vl \
		-v `pwd`:/go/src/github.com/gliderlabs/registrator \
		--network cdm_default \
		-e ETCD_TMPL_HOSTNAMES="{{if and .Attrs.lbregister .Attrs.hostnames}}/sites/{{.ID}}/hostnames {{.Attrs.hostnames}}{{end}}" \
		-e ETCD_TMPL_IP="{{if .Attrs.lbregister}}/sites/{{.ID}}/ip {{.IP}}{{end}}" \
		-e ETCD_TMPL_PORT="{{if .Attrs.lbregister}}/sites/{{.ID}}/port {{.Port}}{{end}}" \
		-e ETCD_TMPL_ENVIRONMENT_NAME="{{if .Attrs.lbregister}}/sites/{{.ID}}/environmentname {{.Attrs.environmentname}}{{end}}"
		-e ETCD_TMPL_MODIFIED="/modified Modified by registrator"
		-e GOPATH="/go" \
		$(NAME):dev /bin/sh -c "cd /go/src/github.com/gliderlabs/registrator; go build -ldflags '-X main.Version=dev' -o /bin/registrator; exec /bin/registrator -ip 127.0.0.1 etcd://etcd:2379/sites"

build:
	mkdir -p build
	docker build -t $(NAME):$(VERSION) .
	docker save $(NAME):$(VERSION) | gzip -9 > build/$(NAME)_$(VERSION).tgz

ezrelease: build
	docker save $(NAME):$(VERSION) | gzip -9 > dist/$(NAME)_$(VERSION).tar.gz

release:
	rm -rf release && mkdir release
	go get github.com/progrium/gh-release/...
	cp build/* release
	gh-release create gliderlabs/$(NAME) $(VERSION) \
		$(shell git rev-parse --abbrev-ref HEAD) $(VERSION)
	glu hubtag gliderlabs/$(NAME) $(VERSION)

docs:
	boot2docker ssh "sync; sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'" || true
	docker run --rm -it -p 8000:8000 -v $(PWD):/work gliderlabs/pagebuilder mkdocs serve

circleci:
	rm -f ~/.gitconfig
	go get -u github.com/gliderlabs/glu
	glu circleci

.PHONY: build ezrelease release docs
