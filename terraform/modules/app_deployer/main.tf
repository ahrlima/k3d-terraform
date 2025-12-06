variable "cluster_name" {
  description = "The name of the k3d cluster to deploy to."
  type        = string
}

variable "namespace" {
  description = "The Kubernetes namespace for the deployment."
  type        = string
}

variable "manifests_path" {
  description = "Path to the Kubernetes manifests directory."
  type        = string
}

resource "null_resource" "deploy" {
  # Este trigger garante que o deploy aconteça se o nome do cluster mudar.
  triggers = {
    cluster_name = var.cluster_name
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      set -e
      echo "Importing images to cluster ${var.cluster_name}..."
      k3d image import dummy-backend:latest -c ${var.cluster_name}
      k3d image import dummy-frontend:latest -c ${var.cluster_name}

      echo "Ensuring namespace ${var.namespace} exists..."
      kubectl --context k3d-${var.cluster_name} create namespace ${var.namespace} --dry-run=client -o yaml | kubectl --context k3d-${var.cluster_name} apply -f -

      echo "Applying manifests from ${var.manifests_path} to namespace ${var.namespace}..."
      kubectl --context k3d-${var.cluster_name} apply -f ${var.manifests_path} -n ${var.namespace}
    EOT
  }
}