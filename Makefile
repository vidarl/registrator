NAME=vidarl_registrator
VERSION=$(shell cat VERSION)

dev:
	docker build -f Dockerfile.dev -t $(NAME):dev .
	docker run --name=registrator -d -v /var/run/docker.sock:/var/run/docker.sock -h vl \
	-e ETCD_TMPL_HOSTNAMES="{{if and .Attrs.lbregister .Attrs.hostnames}}/sites/{{.ID}}/hostnames {{.Attrs.hostnames}}{{end}}" \
	-e ETCD_TMPL_IP="{{if .Attrs.lbregister}}/sites/{{.ID}}/ip {{.Published.HostIP}}{{end}}" \
	-e ETCD_TMPL_PORT="{{if .Attrs.lbregister}}/sites/{{.ID}}/port {{.Published.HostPort}}{{end}}" \
	$(NAME):dev /bin/registrator -ip 127.0.0.1 etcd-tmpl://127.0.0.1:4001/services

build:
	docker build -f Dockerfile.dev -t $(NAME):$(VERSION) .
	docker save $(NAME):$(VERSION) | gzip -9 > dist/$(NAME)_$(VERSION).tar.gz

release:
	rm -rf release && mkdir release
	go get github.com/progrium/gh-release/...
	cp build/* release
	gh-release create gliderlabs/$(NAME) $(VERSION) \
		$(shell git rev-parse --abbrev-ref HEAD) $(VERSION)

circleci:
	rm ~/.gitconfig
ifneq ($(CIRCLE_BRANCH), release)
	echo build-$$CIRCLE_BUILD_NUM > VERSION
endif

.PHONY: build release
