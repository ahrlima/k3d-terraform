# k3d-terraform

Este repositório contém o código para provisionar um cluster Kubernetes local usando [k3d](https://k3d.io/) e Terraform.

## Estrutura do Projeto

O projeto é dividido em quatro partes principais:

- `infra/`: Contém o código do Terraform para criar a infraestrutura do cluster k3d.
  - `dev/` e `prod/`: Ambientes de configuração.
- `k8s/`: Contém os manifestos Kubernetes para as aplicações.
  - `dev/` e `prod/`: Manifestos por ambiente.
- `backend/`: Uma aplicação Node.js (Express) simples que expõe um endpoint `/api/dados`.
- `frontend/`: Uma página HTML estática com JavaScript que consome a API do backend.

## Nota sobre o Estado do Terraform

**Importante:** Este projeto foi criado para fins de teste e para ser executado exclusivamente em um ambiente local. Por padrão, o Terraform salvará o arquivo de estado (`terraform.tfstate`) localmente no diretório de cada ambiente.

Isso significa que:
- **Nenhum estado remoto é configurado.** O estado não será compartilhado entre diferentes máquinas ou usuários.
- **Nenhum mecanismo de bloqueio (locking) é utilizado.** A execução simultânea de `terraform apply` no mesmo diretório pode corromper o arquivo de estado.

## Pré-requisitos

Antes de começar, certifique-se de ter as seguintes ferramentas instaladas:

- [Terraform](https://www.terraform.io/downloads.html)
- [k3d](https://k3d.io/#installation)
- [Docker](https://docs.docker.com/get-docker/)

## Como Usar

### 1. Provisionar o Cluster

Para criar o cluster k3d, navegue até o diretório do ambiente desejado (por exemplo, `infra/dev`) e execute os seguintes comandos:

```bash
# Navegue para o diretório de desenvolvimento
cd infra/dev

# Inicialize o Terraform
terraform init

# Aplique a configuração para criar o cluster
terraform apply
```

Isso irá criar um novo cluster k3d com o nome e as configurações definidas nas variáveis do Terraform (`variables.tf` e `terraform.tfvars`).

### 2. Construir e Implantar as Aplicações

Após o cluster estar no ar, você pode construir as imagens Docker das aplicações e implantá-las.

#### a. Construir as Imagens Docker

Execute os seguintes comandos a partir do diretório raiz do projeto:

```bash
# Construir a imagem do backend
docker build -t dummy-backend:latest ./backend

# Construir a imagem do frontend
docker build -t dummy-frontend:latest ./frontend
```

#### b. Importar as Imagens para o Cluster k3d

Para que o k3d possa usar as imagens locais, importe-as para o cluster:
```bash
# Obtenha o nome do cluster a partir das saídas do Terraform
CLUSTER_NAME=$(cd infra/dev && terraform output -json clusters_created | jq -r '.[0]' | sed 's/[^a-zA-Z0-9_-]//g')

# Importe as imagens
k3d image import dummy-backend:latest -c $CLUSTER_NAME
k3d image import dummy-frontend:latest -c $CLUSTER_NAME
```
*Nota: O comando `sed` é usado para limpar qualquer caractere inesperado da saída do Terraform.*

#### c. Aplicar os Manifestos Kubernetes

Com as imagens disponíveis no cluster, aplique os manifestos para implantar as aplicações:

```bash
kubectl apply -f ks8/dev/
```

Após alguns instantes, a aplicação estará disponível. O Ingress configurado irá direcionar o tráfego da raiz (`/`) para o frontend e o caminho `/api/dados` para o backend. Você pode acessar a aplicação através do `localhost` na porta mapeada para o Load Balancer do k3d (verifique a saída `k3d_host_lb_port` do Terraform).


### 3. Destruir o Cluster

Para destruir o cluster e limpar os recursos, execute o seguinte comando no mesmo diretório do ambiente:

```bash
terraform destroy
```

## Configuração

Você pode personalizar a configuração do cluster editando o arquivo `terraform.tfvars` no diretório de cada ambiente. As principais variáveis incluem:

- `k3s_version`: A versão do K3s a ser usada.
- `k3d_cluster_name`: O nome do cluster k3d.
- `server_count`: O número de nós de servidor (control plane).
- `agent_count`: O número de nós de agente (worker).
- `k3d_host_lb_port`: A porta do host mapeada para o load balancer do cluster.