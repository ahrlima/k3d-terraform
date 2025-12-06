locals {
  environments = {
    dev = {
      server_count = 1
      agent_count  = 1
      k3s_version  = "v1.31.5-k3s1"
    }
    prod = {
      server_count = 1
      agent_count  = 1
      k3s_version  = "v1.31.5-k3s1"
    }
  }
}

# Passo 1: Construir as imagens (apenas uma vez)
module "docker_build" {
  source = "./modules/docker_build"
  app_source_paths = {
    backend  = "${path.root}/../app/backend"
    frontend = "${path.root}/../app/frontend"
  }
}

# Passo 2 e 3: Criar clusters e fazer deploy sequencialmente para aliviar a carga no PC.

# --- Ambiente DEV ---
module "k3d_cluster_dev" {
  source   = "./modules/k3d-cluster"
  k3d_cluster_name = ["dev"]
  server_count     = local.environments.dev.server_count
  agent_count      = local.environments.dev.agent_count
  k3s_version      = local.environments.dev.k3s_version
}

module "app_deploy_dev" {
  source   = "./modules/app_deployer"
  depends_on = [module.docker_build, module.k3d_cluster_dev]

  cluster_name   = "dev"
  namespace      = "dev-k8s"
  manifests_path = "${path.root}/../k8s/dev"
}

# --- Ambiente PROD ---
# O depends_on garante que o cluster de produção só começará a ser criado
# após o deploy no cluster de desenvolvimento ter sido concluído.
module "k3d_cluster_prod" {
  source           = "./modules/k3d-cluster"
  depends_on       = [module.app_deploy_dev]
  k3d_cluster_name = ["prod"]
  server_count     = local.environments.prod.server_count
  agent_count      = local.environments.prod.agent_count
  k3s_version      = local.environments.prod.k3s_version
}

module "app_deploy_prod" {
  source           = "./modules/app_deployer"
  depends_on       = [module.k3d_cluster_prod]
  cluster_name     = "prod"
  namespace        = "prod-k8s"
  manifests_path   = "${path.root}/../k8s/prod"
}
