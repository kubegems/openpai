#!/bin/bash
set -e
set -x

echo "pai" >cluster-id

# assume the workdir is pai
echo "Generating services configurations..."
python3 ./contrib/kubespray/script/openpai_generator.py -l ./contrib/kubespray/config/layout.yaml -c ./contrib/kubespray/config/config.yaml -o ./cluster-configuration

echo "Pushing cluster config to k8s..."
cp ./contrib/kubespray/config/*.yaml ./cluster-configuration/
./paictl.py config push --cluster-conf-path ./cluster-configuration -m service <cluster-id

echo "Starting OpenPAI service..."
./paictl.py service start <cluster-id

rm cluster-id
