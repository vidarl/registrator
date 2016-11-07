FROM gliderlabs/alpine:3.3
ENTRYPOINT ["/bin/registrator"]

COPY . /go/src/github.com/gliderlabs/registrator
RUN apk-install -t build-deps build-base go git mercurial \
	&& cd /go/src/github.com/gliderlabs/registrator \
	&& export GOPATH=/go \
	&& go get -v \
	; mv /go/src/github.com/go-check /go/src/github.com/go-check.org \
	&& mkdir /go/src/github.com/go-check \
	&& git clone https://github.com/go-check/check.git /go/src/github.com/go-check/check \
	&& go build -ldflags "-X main.Version $(cat VERSION)" -o /bin/registrator \
	&& rm -rf /go \
	&& apk del --purge build-deps
