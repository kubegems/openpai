#!/bin/bash
set -e

while getopts "l:c:" opt; do
  case $opt in
    l)
      LAYOUT=$OPTARG
      ;;
    c)
      CLUSTER_CONFIG=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
  esac
done

mkdir -p ./pai-deploy/cluster-cfg

LOCAL_PAI_PATH=$(realpath $PWD/../..)
echo "Local pai folder path: $LOCAL_PAI_PATH"

echo "Generating kubespray configuration"
python3 ${LOCAL_PAI_PATH}/contrib/kubespray/script/k8s_generator.py -l ${LAYOUT} -c ${CLUSTER_CONFIG} -o ./pai-deploy/cluster-cfg

mkdir -p ./pai-deploy/kubespray/inventory/pai/
cp ./pai-deploy/cluster-cfg/openpai.yml ./pai-deploy/kubespray/inventory/pai/
cp ./pai-deploy/cluster-cfg/hosts.yml ./pai-deploy/kubespray/inventory/pai/
