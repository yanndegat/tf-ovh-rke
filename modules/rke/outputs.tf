output kubeconfig_yaml {
  description = "Kubeconfig file"
  value       = rke_cluster.cluster.kube_config_yaml
  sensitive   = true
}

output cluster_yaml {
  description = "RKE cluster.yml file"
  value       = rke_cluster.cluster.rke_cluster_yaml
}

output rke_state {
  description = "RKE state file"
  value       = rke_cluster.cluster.rke_state
}

output cluster {
  description = "RKE cluster"
  value       = rke_cluster.cluster
}
