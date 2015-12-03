#!/bin/sh

if [ "$HOST_IP" == "" ]; then
    echo "Warning : The environment variable HOST_IP not set"
fi

if [ "$ETCD_IP" == "" ]; then
    echo "Warning : The environment variable ETCD_IP not set"
fi

if [ "$ETCD_PORT" == "" ]; then
    echo "Warning : The environment variable ETCD_PORT not set"
fi

exec /bin/registrator -ip ${HOST_IP} etcd://${ETCD_IP}:${ETCD_PORT}/services
