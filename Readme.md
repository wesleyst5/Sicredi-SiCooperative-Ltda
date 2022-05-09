## Projeto

Implantação de Data Lake para a empresa SiCooperative LTDA, com objetivo de ajudar o time nas atividades de agregação de diferentes informações em um único ponto, criação de relatórios individuais e apoio a nova equipe de Data Science na criação de modelos preditivos.

### Definição Estratégica:
- Criação de um Data Lake
- Ingestão dos dados de movimentações dos cartões

### Requisitos do Cliente:

- Criar a estrutura do banco a ser ingerido, utilizando a tecnologia de sua preferência (MySQL, PostgreSQL).
- Inserir uma massa de dados fictícia nas tabelas, não precisa ser um volume tão grande.
- Utilizar a linguagem de programação de sua preferência.
- Para realizar o ETL dos dados, deve ser utilizado algum framework de processamento distribuído para Big Data, Ex: Hadoop, Spark, Flink e Storm.
- Escrever um arquivo CSV, em um diretório parametrizado pelo usuário.
- Disponibilizar esse projeto em um repositório privado no seu GitHub.


### Arquitetura da Solução:

![](https://i.ibb.co/jwSmhRj/Arquitetura.png)
> Desenho da arquitetura.

### Construindo o Banco de Dados

- **SGBD escolhido:** MySql
- **Ambiente de execução:** AWS RDS 
- **Database Name**: dbsicredi

### .github\workflows

- A pasta .github contém arquivos yaml que serão usados na automatização da esteira de deploy através do GitHub.
	- **test.yaml:**  Será usado para testar a criação dos recursos na aws ao realizar um pull request na branch master
	- **deploy.yaml:**  Será usado para fazer deploy dos recursos definidos no terraform na aws ao realizar um merge na branch master

### Infrastructure\aws

Foi usado Terraform como ferramenta de criação de IAC - infraestrutura como código na construção da infraestrutura de serviços necessárias para implementar o projeto. 

- **[provider.tf](https://github.com/wesleyst5/Sicredi-SiCooperative-Ltda/blob/master/infrastructure/aws/provider.tf)** - Responsável por definir a cloud  usado no projeto.

- **[variables.tf](https://github.com/wesleyst5/Sicredi-SiCooperative-Ltda/blob/master/infrastructure/aws/variables.tf)** - Responsável por armazenar as variáveis. Usado na definição do nome bucket e região usado no provisionamento dos recursos.

- **[iam.tf](https://github.com/wesleyst5/Sicredi-SiCooperative-Ltda/blob/master/infrastructure/aws/iam.tf)** - Responsável por criar as políticas de segurança para acesso aos recursos no AWS. Foi criado uma role para liberar o acesso do serviço AWS EKS para o AWS S3.

- **[s3.tf](https://github.com/wesleyst5/Sicredi-SiCooperative-Ltda/blob/master/infrastructure/aws/s3.tf)** - Responsável por criar um bucket privado chamado datalake-sicredi no AWS S3. O bucket será usado como repositório de saída do processamento Spark através do SparkOperator no AWS EKS.

- **[rds.tf](https://github.com/wesleyst5/Sicredi-SiCooperative-Ltda/blob/master/infrastructure/aws/rds.tf)** - Responsável por criar um banco de dados relacional Mysql no AWS RDS, configura acessos e permissões de rede, security groups, tipo de instância e faz a criação da estrutura com a inserção da massa de dados. (Foi usado a instância t3.micro, do free tier).

- **[eks.tf](https://github.com/wesleyst5/Sicredi-SiCooperative-Ltda/blob/master/infrastructure/aws/eks.tf)** - Responsável por provisionar uma cluster Kubernetes através do serviço AWS EKS.

### Infrastructure\aws\sql
- **[db_structure.sql](https://github.com/wesleyst5/Sicredi-SiCooperative-Ltda/blob/master/infrastructure/aws/sql/db_structure.sql)** - Script SQL usado no **rds.tf**, para criar e popular as tabelas do banco de dados.

### kubernetes\spark 

- **[Dockerfile](https://github.com/wesleyst5/Sicredi-SiCooperative-Ltda/blob/master/kubernetes/spark/Dockerfile)** - Contém as etapas de construção da imagem customizada, a partir de uma imagem spark-operator. Usado no provisionamento de container de processamento do SparkApplication

- **[cluster-role-binding-spark-operator-processing.yaml](https://github.com/wesleyst5/Sicredi-SiCooperative-Ltda/blob/master/kubernetes/spark/cluster-role-binding-spark-operator-processing.yaml)** - Arquivo de manifesto usado para criação da conta de serviço com permissão de cluster-admin (superusuário) dentro do namespace **processing**

- **[spark-batch-operator-k8s-v1beta2.yaml](https://github.com/wesleyst5/Sicredi-SiCooperative-Ltda/blob/master/kubernetes/spark/spark-batch-operator-k8s-v1beta2.yaml)** - Arquivo de manifesto usado para especificação de uma aplicação SparkApplication que irá executar o processamento definido no arquivo **spark-operator-processing-job-batch.py**

- **[spark-operator-processing-job-batch.py](https://github.com/wesleyst5/Sicredi-SiCooperative-Ltda/blob/master/kubernetes/spark/spark-operator-processing-job-batch.py)** - Código escrito em Pyspark usado no processamento (Leitura banco de dados -> escrita no Datalake em formato CSV).

### kubernetes\spark\jars
- **aws-java-sdk-1.7.4.jar** - Permite uso das APIs para todos os serviços AWS.
- ~~**delta-core_2.12-1.0.0.jar** - Permite usar a camada delta lake (Não usado no projeto~~)
- **hadoop-aws-2.7.3.jar** - Permite o suporte à integração com Amazon Web Services.
- **mysql-connector-java-8.0.17.jar** - Permite interação com o banco de dados mysql através do driver jdbc.
- ~~**postgresql-42.3.3.jar** - Permite interação com o banco de dados postgres através do driver jdbc. (Não usado no projeto)~~
- ~~**spark-sql-kafka-0-10_2.12-3.0.1.jar** - Permite integraçao com o kafka. (Não usado no projeto)~~

## Executar o projeto

### Pré-Requisitos
- VSCODE (https://code.visualstudio.com/download)
- AWS-CLI (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- KUBECTL (https://kubernetes.io/docs/tasks/tools/)
- HELM (https://helm.sh/pt/docs/intro/install/)
- DBEAVER (https://dbeaver.io/download/)
- Terraform (https://www.terraform.io/downloads)
- GitBash (https://git-scm.com/)
- MySQL Client (https://www.configserverfirewall.com/ubuntu-linux/ubuntu-install-mysql-client/)
***Obs: O projeto foi implementado com uso do WSL(Ubuntu) no Windows***
![](https://i.ibb.co/6ZmST16/VSCode.png)
> VSCode com WSL (Ubuntu) no Windows.

### Instruções
Para iniciar a execução do projeto, é necessário ter uma conta na AWS, (https://portal.aws.amazon.com/billing/signup#/start/email), uma conta no GitHub (https://github.com/join) e uma conta no DockerHub(https://hub.docker.com/).

**Próximos passos:**
- Realizar clone do projeto do GitHub para o ambiente local com uso da linha de comando **Git Bash**, em seguida abra o projeto no **VSCode**.
```sh 
git clone  https://github.com/wesleyst5/Sicredi-SiCooperative-Ltda.git
```
- Configurar uma conta para acesso aos recursos da AWS,  através do client AWS-CLI na linha de comando no VSCode. 
Será solicitado o Access Key ID, Secret access key, região e formato de saída.
O projeto foi implementado  na região **us-east-2** (Ohio)
![](https://i.ibb.co/q0r11N7/AWSConfigure.png)
> VSCode aws configure.
```sh 
AWS configure
```

- Provisionar os serviços (infraestrutura) necessários para execução do projeto.
 Acessar a pasta **infrastructure\aws** e executar os comandos abaixo para criação dos recursos na AWS:
```sh 
terraform init
terraform validate
terraform plan
terraform apply
```
***Se necessitar destruir os recursos provisionados, execute o comando " terraform destroy "***

- Após o cluster EKS chamado **sicredi-eks** ter sido provisionado através o terraform, execute o comando abaixo para configuração do acesso ao cluster via linha de comando local.
![](https://i.ibb.co/rMXLrGQ/eks-Kubeconfig.png)
> EKS update-kubeconfig.
```sh 
aws eks --region us-east-2 update-kubeconfig --name sicredi-eks
```
***Listar os nós do cluster do AWS EKS execute a seguinte instrução:***
```sh 
kubectl get nodes
```
- Criar um namespace chamado **processing** para separar agrupar os container ligados a processamento em um unico espaço de trabalho.
```sh
kubectl create namespace processing
```

- Criar um spark-operator (https://operatorhub.io/operator/spark-gcp) para processamento de aplicações spark, usando o gerenciador de pacotes Helm para Kubernetes, através comando abaixo:
![](https://i.ibb.co/NZPwp7W/Helm.png)
> Install spark-operator
```sh
helm repo add spark-operator https://googlecloudplatform.github.io/spark-on-k8s-operator
helm repo update
helm install spark spark-operator/spark-operator -n processing
```
***Listar os operators e pods presentes no namespace processing***
```sh
helm ls -n processing
kubectl get pods -n processing
```

- Acessar a pasta **kubernetes/spark**, para execução de comandos que irão criar uma imagem docker customizada, contendo o código python e a infraestrutura necessária, para processamento e ingestão de dados no datalake.
```sh
docker login -u [meuusername] -p [minhasenha]
docker build -t wesleyst5/spark-operator:v3.0.0-aws .
docker push wesleyst5/spark-operator:v3.0.0-aws
```
***Colocar o usuário e senha do docker hub no comando docker login***

- Criar uma conta de serviço através do manifesto **cluster-role-binding-spark-operator-processing.yaml**
```sh
kubectl apply -f cluster-role-binding-spark-operator-processing.yaml -n processing
```

- Criar um secret no kubernetes, que irá conter as informações de aws_access_key_id e aws_access_key para uso futuro no código .py que irá executar o processamento.
```sh
kubectl create secret generic aws-credentials --from-literal=aws_access_key_id=[meukeyid] --from-literal=aws_secret_access_key=[meusecretkey] -n processing
```
***Substituir [meukeyid] e [meusecretkey] pelas informações da sua conta AWS.***

- Criar uma SparkApplication para executar o processamento (Ler Mysql -> Escrever no Datalake)
![](https://i.ibb.co/GCW8zc2/Processamento-Job.png)
> Processamento sparkApplication

```sh
kubectl apply -f spark-batch-operator-k8s-v1beta2.yaml -n processing
```
**Instruções de verificação:**
```sh
kubectl get sparkapplications -n processing
kubectl get pods -n processing --watch
kubectl logs job-pyspark-batch-driver -n processing
```
***Deletar uma sparkapplications***
```sh
kubectl logs job-pyspark-batch-driver -n processing
```

- Conforme requisitos do projeto, chegou a hora de conferir o resultado. 
Verificar no bucket S3 (s3://datalake-sicredi/processing/movimentacao-conta/) se o arquivo csv foi gerado.
![](https://i.ibb.co/q7tF3s1/S3-Data-Lake.png)
> S3 - Datalake - CSV File 

![](https://i.ibb.co/hLz7WHQ/CSVFile.png)
> CSV File 

### Dificuldades

- Automatizar a criação de tabelas e inserções dos dados durante o provisionamento do banco de dados Mysql.
- Estabeceler a comunicação do AWS EKS e AWS S3. (Como solução foi adicionado a instrução abaixo na proriedade do SparkContext: ***sc.setSystemProperty('com.amazonaws.services.s3.enableV4', 'true')***


### Com mais tempo..

- Implementar e fazer o uso de integração contínua, através do recurso action Workflows do GitHub.
- Provisionar a ferramenta Apache Airflow (gerenciamento e orquestração de fluxo) e a ferramenta Argo CD na abordagem GitOps e implantação de aplicações no Kubernetes.


### Alternativas de solução:
- Uso do notebook nos serviços gerenciados AWS EMR para processamento do pipeline.
- Uso do notebook serviço gerenciado AWS Glue para processamento do pipeline.
- Uso de Docker

