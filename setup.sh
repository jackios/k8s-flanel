!/bin/bash
# by jackios
# desc  create  acluster
# 1. pre  noCNI env


curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.18.0/kind-linux-amd64 && chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind
cat <<EOF | kind create cluster  --image=kindest/node:v1.23.4 --config=-
kind: Cluster
name: flanel-flannel
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  disableDefaultCNI: true
  podSubnet: "10.244.0.0/16"
nodes:
- role: control-plane
#- role: control-plane
#- role: control-plane
- role: worker
- role: worker
- role: worker
EOF

cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.huaweicloud.com/kubernetes/apt/ kubernetes-xenial main
EOF
curl -s https://mirrors.huaweicloud.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -
apt install -y kubeadm=1.23.5-00  kubelet=1.23.5-00  kubectl=1.23.5-00
# 2. remove taints
con_no=`kubectl  get  no|awk 'NR>1{print $1}'|grep  control-plane`
kubectl  taint  no $con_no  node-role.kubernetes.io/master-
kubectl  get  no  -o wide

# 3. install  CNI
kubectl  apply  -f ./flannel.yaml
kubectl  apply  -f https://docs.projectcalico.org/manifests/calico.yaml


