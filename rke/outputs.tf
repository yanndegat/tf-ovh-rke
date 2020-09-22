output kubeconfig_yaml {
  description = "Kubeconfig file"
  value       = module.rke.kubeconfig_yaml
  sensitive   = true
}

output rke_state {
  description = "rke state"
  value       = module.rke.rke_state
  sensitive   = true
}

locals {
  kube_node = [
    for cert in module.rke.cluster.certificates :
    cert if cert.id == "kube-node"
  ][0]
  kube_ca = [
    for cert in module.rke.cluster.certificates :
    cert if cert.id == "kube-ca"
  ][0]
}

output etcd_cert {
  description = "kubernetes config root admin for rke compat"
  sensitive   = true
  value = {
    cacert = local.kube_ca.certificate
    cert   = local.kube_node.certificate
    key    = local.kube_node.key
  }
}

output cluster {
  description = "kubernetes config root admin for rke compat"
  sensitive   = true
  value = {
    host                   = module.rke.cluster.api_server_url
    username               = module.rke.cluster.kube_admin_user
    client_certificate     = module.rke.cluster.client_cert
    client_key             = module.rke.cluster.client_key
    cluster_ca_certificate = module.rke.cluster.ca_crt
  }
}

output cluster_yaml {
  description = "rke cluster config yaml"
  value       = module.rke.cluster_yaml
  sensitive   = true
}

output helper {
  description = "How to fallback to rke manual"
  value       = <<EOF
wget https://github.com/rancher/rke/releases/download/v1.1.4/rke_linux-amd64
chmod +x rke_linux-amd64
sudo mv rke_linux-amd64 /usr/local/bin/rke
TMPDIR=$(mktemp -d)
terraform output cluster_yaml > $TMPDIR/cluster.yml
terraform output kubeconfig_yaml > $TMPDIR/kube_config_cluster.yml
terraform output rke_state > $TMPDIR/cluster.rkestate
cd $TMPDIR
rke ...
EOF
}
