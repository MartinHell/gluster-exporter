FROM alpine as git
WORKDIR /git/
RUN apk add --no-cache git
RUN git clone https://github.com/gluster/gluster-prometheus.git gluster-prometheus

FROM golang:1.10 as go
RUN mkdir -p $GOPATH/src/github.com/gluster
COPY --from=git /git/gluster-prometheus $GOPATH/src/github.com/gluster/gluster-prometheus
RUN cd $GOPATH/src/github.com/gluster/gluster-prometheus/scripts/ && ./install-reqs.sh
RUN cd $GOPATH/src/github.com/gluster/gluster-prometheus && PREFIX=/usr make
RUN cd $GOPATH/src/github.com/gluster/gluster-prometheus && PREFIX=/usr make install

FROM alpine
WORKDIR /gluster-exporter
COPY --from=go /usr/sbin/gluster-exporter .
ENTRYPOINT ["/gluster-exporter/gluster-exporter", "--config=/configs/gluster-exporter.toml"]

