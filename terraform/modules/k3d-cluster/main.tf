resource "random_integer" "port" {
  for_each = toset(var.k3d_cluster_name)
  min      = 8000
  max      = 8099
}

resource "null_resource" "cluster" {
  for_each = toset(var.k3d_cluster_name)
  triggers = {
    agent_count  = var.agent_count
    server_count = var.server_count
    ip           = var.k3d_cluster_ip
    k3s_version  = var.k3s_version
    host_lb_port = coalesce(var.k3d_host_lb_port, random_integer.port[each.key].result)
  }
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      set -e
      if ! k3d cluster get ${each.key} >/dev/null 2>&1; then
        echo "Cluster ${each.key} not found. Creating..."
        k3d cluster create ${each.key} --agents ${self.triggers.agent_count} --servers ${self.triggers.server_count} --port ${self.triggers.host_lb_port}:${var.k3d_cluster_lb_port}@loadbalancer --image rancher/k3s:${self.triggers.k3s_version}
      else
        echo "Cluster ${each.key} already exists. Skipping creation."
      fi
    EOT
  }
}

resource "null_resource" "cluster_delete" {
  for_each = toset(var.k3d_cluster_name)
  provisioner "local-exec" {
    command = "k3d cluster delete ${each.key}"
    when    = destroy
  }
}

data "docker_network" "k3d" {
  for_each = toset(var.k3d_cluster_name)
  depends_on = [
    null_resource.cluster
  ]
  name = "k3d-${each.key}"
}