# k3d-terraform: Orquestração de Clusters K3d com Terraform

![Terraform](https://img.shields.io/badge/Terraform-v1.x-7B42BC?logo=terraform&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.xx-326CE5?logo=kubernetes&logoColor=white)
![k3d](https://img.shields.io/badge/k3d-Local%20Kubernetes-FF6F00?logo=k3d&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Build%20&%20Runtime-2496ED?logo=docker&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-18.x-339933?logo=node.js&logoColor=white)
![Express](https://img.shields.io/badge/Express.js-Backend-black?logo=express&logoColor=white)
![HTML](https://img.shields.io/badge/Frontend-HTML%2FJS-E34F26?logo=html5&logoColor=white)
![IaC](https://img.shields.io/badge/IaC-Automation-blue?logo=hashicorp&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-Repo-181717?logo=github&logoColor=white)

---

Este repositório demonstra uma solução completa para provisionar, construir e implantar aplicações em clusters Kubernetes locais (`dev` e `prod`) usando **k3d** e **Terraform**.

Toda a infraestrutura é gerenciada de forma automatizada: desde a construção das imagens Docker e criação dos clusters até o deploy dos manifestos Kubernetes.

---

## 📁 Estrutura do Projeto

O projeto é organizado para separar o código da aplicação, a configuração do Kubernetes e a orquestração do Terraform:

- **terraform/**: Código Terraform (HCL) para orquestrar toda a infraestrutura.
- **terraform/modules/**: Módulos reutilizáveis para Build Docker, Clusters k3d e Deployments.
- **k8s/**: Manifestos Kubernetes (YAML) separados por ambiente (`dev/` e `prod/`).
- **app/backend/**: Aplicação Node.js (Express) que expõe a API.
- **app/frontend/**: Aplicação estática (HTML/JS) que consome o backend.

---

## 🔧 Pré-requisitos

Certifique-se de ter as seguintes ferramentas instaladas e acessíveis no PATH:

- **Terraform**
- **k3d**
- **Docker**
- **kubectl**

---

## 🚀 Como Executar

A automação foi simplificada para um único comando.  
O Terraform gerencia toda a ordem das dependências automaticamente:  
1. Constrói as imagens Docker  
2. Cria o cluster `dev`  
3. Aplica os manifestos do ambiente `dev`  
4. Cria o cluster `prod`  
5. Aplica os manifestos do ambiente `prod`  

---

### 1. Provisionar o Ambiente Completo

```bash
cd k3d-terraform/terraform

# Inicializa os plugins e módulos
terraform init

# Cria infraestrutura, constrói imagens e faz o deploy em dev e prod
terraform apply --auto-approve

## 2. Acessar as Aplicações

Após o término da execução, as aplicações estarão acessíveis via localhost.  
O Terraform exibirá as portas mapeadas no output (`clusters_created` ou `k3d_host_lb_port`).

- **Ambiente Dev:**  
  `http://localhost:<porta-dev>`

- **Ambiente Prod:**  
  `http://localhost:<porta-prod>`

---

## 3. Limpar Recursos

Para destruir os clusters e remover os containers criados:

```bash
terraform destroy --auto-approve

## Melhorias Futuras (Roadmap)

Possíveis evoluções para tornar a infraestrutura mais completa e profissional:

### Gerenciamento de Imagens
- Migrar para `docker_image` (Provider Docker) para permitir rastreamento de estado.

### Ciclo de Vida do Cluster
- Substituir scripts por provider nativo do `k3d` quando estiver estável.

### Deploy Kubernetes
- Migrar de `kubectl apply` para provider Kubernetes ou Helm.

### Backend Remoto
- Usar S3 ou Terraform Cloud para colaboração e versionamento.

### Registry Local
- Adicionar registry Docker interno no k3d para simular pipelines reais.

Arquitetura da Solução:

+----------------+          +-------------------------------------------------+
| Host Machine   |          | Cluster k3d (Gerenciado pelo Terraform)         |
| +------------+ |          |                                                 |
| | Browser    | |          |    +----------------+                           |
| +------^-----+ |          |    | Ingress        |                           |
|        |       | (Porta Mapeada) | (Traefik)      |                         |
+--------|-------+          |    +--^----------^--+                           |
         |                  |       |          |                              |
      (HTTP)                |   /   |          | /api/dados                   |
         |                  |       v          v                              |
         |                  | +-----------+  +-------------+                  |
         +----------------> | | Service   |  | Service     |                  |
                            | | Frontend  |  | Backend     |                  |
                            | | (Porta 80)|  | (Porta 80)  |                  |
                            | +-----+-----+  +------+------+                  |
                            |       | (Porta 80)    | (Porta 3000)            |
                            |       v               v                          |
                            | +-----------+  +-------------+                  |
                            | | Deployment|  | Deployment  |                  |
                            | | Frontend  |  | Backend     |                  |
                            | +-----------+  +-------------+                  |
                            +-------------------------------------------------+
