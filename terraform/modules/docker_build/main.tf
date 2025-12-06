variable "app_source_paths" {
  description = "A map of application names to their source code paths."
  type        = map(string)
  default     = {}
}

variable "trigger_rebuild" {
  description = "An arbitrary value that can be changed to force a rebuild."
  type        = string
  default     = ""
}

# Este recurso calcula um hash de todos os arquivos de código-fonte.
# Se qualquer arquivo mudar, o hash muda, e o provisioner será acionado.
resource "null_resource" "image_builder" {
  triggers = {
    # Um gatilho estático para garantir que isso rode apenas uma vez, a menos que o código mude.
    build_on_change = join(",", [
      for app_path in values(var.app_source_paths) : filesha256("${app_path}/Dockerfile")
    ])
    force_rebuild = var.trigger_rebuild
  }

  provisioner "local-exec" {
    working_dir = "${path.root}/../" # Sobe um nível para o diretório raiz do projeto
    command = <<-EOT
      echo "Building Docker images..."
      docker build -t dummy-backend:latest -f app/backend/Dockerfile ./app/backend
      docker build -t dummy-frontend:latest -f app/frontend/Dockerfile ./app/frontend
    EOT
  }
}