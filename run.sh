#!/bin/sh

if [ "$HOST_IP" == "" ]; then
    echo "Warning : The environment variable HOST_IP not set"
fi

if [ "$ETCD_IP" == "" ]; then
    echo "Warning : The environment variable ETCD_IP not set"
fi


/bin/registrator -ip ${HOST_IP} etcd-tmpl://${ETCD_IP}:4001/services
