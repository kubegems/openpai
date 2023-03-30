# open pai 部署

官方的部署文档 <https://openpai.readthedocs.io/en/latest/manual/cluster-admin/installation-guide.html>

官方的部署文档中，包含两部分：

- 一部分是部署 k8s 集群，使用 kuberay 完成
- 另一部分是部署 pai ，这部分使用 paictl.py 为核心完成。

## 准备

准备安装代码：

官方代码已经没有继续维护其出现了一些问题，所以这里使用的是 fork 的代码。

```sh
# git clone https://github.com/microsoft/pai.git
git clone https://github.com/kubegems/openpai.git
cd pai
cd contrib/kubespray/config
```

这里主要有两个配置文件 `contrib/kubespray/config/config.yaml` 和 `contrib/kubespray/config/layout.yaml`。

`config.yaml` 是总体配置文件，包含了 pai 的配置，以及 kubespray 的配置。
如果被安装机器启用了免密登录，那么可以不用配置 `config.yaml` 中的 `user` 和 `password`。

如果要启用 marketplace ，那么需要将 `enable_marketplace` 设置为 `true`。

其他配置可以不用修改。

```yaml
# config.yaml
user: root
password: ""
docker_image_tag: v1.8.0

# Optional

#######################################################################
#                    OpenPAI Customized Settings                      #
#######################################################################
# enable_hived_scheduler: true
# enable_docker_cache: false
# docker_cache_storage_backend: "azure" # or "filesystem"
# docker_cache_azure_account_name: ""
# docker_cache_azure_account_key: ""
# docker_cache_azure_container_name: "dockerregistry"
# docker_cache_fs_mount_path: "/var/lib/registry"
# docker_cache_remote_url: "https://registry-1.docker.io"
# docker_cache_htpasswd: ""
enable_marketplace: "true"
#############################################
# Ansible-playbooks' inventory hosts' vars. #
#############################################
# ssh_key_file_path: /path/to/you/key/file

#####################################
# OpenPAI's service image registry. #
#####################################
# docker_registry_domain: docker.io
# docker_registry_namespace: openpai
# docker_registry_username: exampleuser
# docker_registry_password: examplepasswd

################################################################
# OpenPAI's daemon qos config.                                 #
# By default, the QoS class for PAI daemon is BestEffort.      #
# If you want to promote QoS class to Burstable or Guaranteed, #
# you should set the value to true.                            #
################################################################
# qos-switch: "false"

###########################################################################################
#                         Pre-check setting                                               #
###########################################################################################
# docker_check: true
# resource_check: true

########################################################################################
# Advanced docker configuration. If you are not familiar with them, don't change them. #
########################################################################################
# docker_data_root: /mnt/docker
# docker_config_file_path: /etc/docker/daemon.json
# docker_iptables_enabled: false

## An obvious use case is allowing insecure-registry access to self hosted registries.
## Can be ipaddress and domain_name.
## example define 172.19.16.11 or mirror.registry.io
# openpai_docker_insecure_registries:
#   - mirror.registry.io
#   - 172.19.16.11

## Add other registry,example China registry mirror.
# openpai_docker_registry_mirrors:
#   - https://registry.docker-cn.com
#   - https://mirror.aliyuncs.com

#######################################################################
#                       kubespray setting                             #
#######################################################################

# If you couldn't access to gcr.io or docker.io, please configure it.
# gcr_image_repo: "gcr.io"
# kube_image_repo: "gcr.io/google-containers"
# quay_image_repo: "quay.io"
# docker_image_repo: "docker.io"
# etcd_image_repo: "quay.io/coreos/etcd"
# pod_infra_image_repo: "gcr.io/google_containers/pause-{{ image_arch }}"
# kubeadm_download_url: "https://storage.googleapis.com/kubernetes-release/release/{{ kubeadm_version }}/bin/linux/{{ image_arch }}/kubeadm"
# hyperkube_download_url: "https://storage.googleapis.com/kubernetes-release/release/{{ kube_version }}/bin/linux/{{ image_arch }}/hyperkube"

# openpai_kube_network_plugin: calico

# openpai_kubespray_extra_var:
#   key: value
#   key: value

#######################################################################
#                     host daemon port setting                        #
#######################################################################
# host_daemon_port_start: 40000
# host_daemon_port_end: 65535
```

`layout.yaml` 是机器配置文件，包含了机器的配置，以及机器的分配。

machine-sku 是机器的配置，可以定义多个类型，每个类型的机器配置都是一样的。
这个和后续的调度有关系。

例如实际有两种 gpu 类型的机器，那么可以定义两个类型，然后在 `machine-list` 中分别指定。
一定要和实际的机器配置一致。

```yaml
# layout.yaml

# GPU cluster example
# This is a cluster with one master node and two worker nodes

machine-sku:
  master-machine: # define a machine sku
    # the resource requirements for all the machines of this sku
    # We use the same memory format as Kubernetes, e.g. Gi, Mi
    # Reference: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#meaning-of-memory
    mem: 60Gi
    cpu:
      # the number of CPU vcores
      vcore: 24
  gpu-machine:
    computing-device:
      # For `type`, please follow the same format specified in the device plugin.
      # For example, `nvidia.com/gpu` is for NVIDIA GPU, `amd.com/gpu` is for AMD GPU,
      # and `enflame.com/dtu` is for Enflame DTU.
      # Reference: https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/device-plugins/
      type: nvidia.com/gpu
      model: K80
      count: 4
    mem: 220Gi
    cpu:
      vcore: 24

machine-list:
  - hostname: pai-master # name of the machine, **do not** use upper case alphabet letters for hostname
    hostip: 10.0.0.1
    machine-type: master-machine # only one master-machine supported
    pai-master: "true"
  - hostname: pai-worker1
    hostip: 10.0.0.2
    machine-type: gpu-machine
    pai-worker: "true"
  - hostname: pai-worker2
    hostip: 10.0.0.3
    machine-type: gpu-machine
    pai-worker: "true"
```

## 部署 K8S

在官方文档中的这部分是这样的：

```sh
/bin/bash quick-start-kubespray.sh
```

由于年久失修，使用 kuberay 安装 k8s 这部分已经无法正常启动，先跳过这一部分。

所以需要先拥有一个预先搭建完成的 k8s 集群，并且安装好 gpu-container-toolkit。

## 部署 PAI

官方文档中的这部分是这样的：

```sh
/bin/bash quick-start-service.sh
```

分析这个脚本，可以看到它做了以下几件事：

- 复制配置文件到 ${HOME}/pai-deploy/cluster-config 目录下
- 运行： `script/service-boot.sh`
  - 启动一个容器，并挂载
  - 执行 `./contrib/kubespray/script/start-service-in-dev-box.sh`

start-service-in-dev-box.sh:

- script/openpai_generator.py 生成配置文件
- paictl.py config push 将配置文件推送到 k8s 集群，`kubectl get cm pai-configuration` 可以看到
- paictl.py service start 启动服务，如果只想启动部分服务，可以使用 `paictl.py service start -n <service-name>`

关于 paictl.py 的使用，可以参考 [paictl.py](./#paictl.py)。

有了上面的分析，我们就可以自己手动执行这些步骤了。简单来说，有了 `config.yaml` 和 `layout.yaml` 之后，
直接在本地执行下面命令就可以了。

```sh
bash ./contrib/kubespray/script/start-service-in-dev-box.sh
```

注意： 由于这些脚本里面直接调用了 kubectl 命令，你需要把当前的 kubectl context 切换成需要安装的 k8s 集群。

> 同样由于年久失修，安装 pai 这部分在过程中也会遇到不少问题，所以我们进行了一些修改，使得可以正常安装。

## paictl.py

paictl.py 是一个用于管理 pai 集群的工具，它的功能包括：

- 配置管理
- 服务管理
- 集群管理

`paictl.py service start` 工作流程

- 会首先从 k8s 集群中获取配置文件，然后和本地 src/<service>/config 目录下的配置文件进行合并，也有代码执行。
- 然后解析 src/<service>/deploy/service.yaml 文件，根据里面的配置：
  - 根据配置文件对 src/<service>/deploy/下的模板文件进行渲染
  - 执行对应的脚本
