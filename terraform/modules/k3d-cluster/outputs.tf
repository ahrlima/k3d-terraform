output "clusters_created" {
  description = "A map of created clusters with their configurations."
  value = {
    for name, cluster in null_resource.cluster : name => {
      host_lb_port = cluster.triggers.host_lb_port
    }
  }
}