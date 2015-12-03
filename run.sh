#!/bin/sh

if [ "$HOST_IP" == "" ]; then
    echo "Warning : The environment variable HOST_IP not set"
fi

/bin/registrator -ip ${HOST_IP} etcd-tmpl://etcd:4001/services