## Projeto

Implementação de um Data Lake para a empresa SiCooperative LTDA, com objetivo de resolver problemas de agregação de diferentes informações em um único ponto, criação de relatórios individuais e apoio a nova equipe de Data Science na criação de modelos preditivos.

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

Foi uso do Terraform como ferramenta de criação de IAC - infraestrutura como código na construção da infraestrutura de serviços necessária para implementar o projeto. 

- **[provider.tf](https://github.com/wesleyst5/Sicredi-SiCooperative-Ltda/blob/master/infrastructure/aws/provider.tf)** - Script que define a cloud que será utilizada no projeto..

- **[variables.tf](https://github.com/wesleyst5/Sicredi-SiCooperative-Ltda/blob/master/infrastructure/aws/variables.tf)** - Script que armazena as variáveis. Está sendo usado na definição do nome bucket e região usado no provisionamento dos recursos.

- **[iam.tf](https://github.com/wesleyst5/Sicredi-SiCooperative-Ltda/blob/master/infrastructure/aws/iam.tf)** - Script responsável por criar as políticas de segurança para acesso aos recursos no AWS. Foi criado uma role para liberar o acesso do serviço AWS EKS para o AWS S3.

- **[s3.tf](https://github.com/wesleyst5/Sicredi-SiCooperative-Ltda/blob/master/infrastructure/aws/s3.tf)** - Script que cria um bucket privado chamado datalake-sicredi no AWS S3. O bucket será usado como repositório de saída do processamento Spark através do SparkOperator no AWS EKS.

- **[rds.tf](https://github.com/wesleyst5/Sicredi-SiCooperative-Ltda/blob/master/infrastructure/aws/rds.tf)** - Este script cria um banco de dados relacional Mysql no AWS RDS, configura acessos e permissões de rede, security groups, tipo de instância e faz a criação da estrutura com a inserção da massa de dados. (Está sendo usado a instância t3.micro, do free tier).

- **[eks.tf](https://github.com/wesleyst5/Sicredi-SiCooperative-Ltda/blob/master/infrastructure/aws/eks.tf)** - Script reponsável por provisionar uma cluster Kubernates através do serviço AWS EKS.

### Infrastructure\aws\sql
- **[db_structure.sql](https://github.com/wesleyst5/Sicredi-SiCooperative-Ltda/blob/master/infrastructure/aws/sql/db_structure.sql)** - Script SQL usado no **rds.tf**, para criar e popular as tabelas do banco de dados.

### kubernates\spark 

- **[Dockerfile](https://github.com/wesleyst5/Sicredi-SiCooperative-Ltda/blob/master/kubernates/spark/Dockerfile)** - Script que contem as etapas na construção de uma imagem cutomizada, a partir da imagem contendo spark-operator. Será usado no provisionamento de container que irão processar uma SparkApplication

- **[cluster-role-binding-spark-operator-processing.yaml](https://github.com/wesleyst5/Sicredi-SiCooperative-Ltda/blob/master/kubernates/spark/cluster-role-binding-spark-operator-processing.yaml)** - Aquivo de manifesto usado na criação da conta de serviço com permissão de cluster-admin (superusuário) dentro do namespace **processing**

- **[spark-batch-operator-k8s-v1beta2.yaml](https://github.com/wesleyst5/Sicredi-SiCooperative-Ltda/blob/master/kubernates/spark/spark-batch-operator-k8s-v1beta2.yaml)** - Arquivo de manifesto usado para especificação de uma aplicação SparkApplication que irá executar o processamento definido no arquivo **spark-operator-processing-job-batch.py**

- **[spark-operator-processing-job-batch.py](https://github.com/wesleyst5/Sicredi-SiCooperative-Ltda/blob/master/kubernates/spark/spark-operator-processing-job-batch.py)** - Código escrito em Pyspark usado na realização para extrair os dados do banco AWS RDS (Mysql) e escrever no Datalake em formato CSV.

### kubernates\spark \jars
- **aws-java-sdk-1.7.4.jar** - Permite uso das APIs para todos os serviços AWS.
- ~~**delta-core_2.12-1.0.0.jar** - Permite usar a camada delta lake (Não usado no projeto~~)
- **hadoop-aws-2.7.3.jar** - Permite o suporte à integração com Amazon Web Services.
- **mysql-connector-java-8.0.17.jar** - Permite interação com o banco de dados mysql através do driver jdbc.
- ~~**postgresql-42.3.3.jar** - Permite interação com o banco de dados postgres através do driver jdbc. (Não usado no projeto)~~
- ~~**spark-sql-kafka-0-10_2.12-3.0.1.jar** - Permite integraçao com o kafka. (Não usado no projeto)~~

## Executar o projeto

### Pre-Requisites
- VSCODE (https://code.visualstudio.com/download)
- AWS-CLI (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- KUBECTL (https://kubernetes.io/docs/tasks/tools/)
- HELM (https://helm.sh/pt/docs/intro/install/)
- DBEAVER (https://dbeaver.io/download/)
- Terraform (https://www.terraform.io/downloads)
- GitBash (https://git-scm.com/)

### Instruções
Primeiro, é preciso ter uma conta na AWS (https://portal.aws.amazon.com/billing/signup#/start/email), GitHub (https://github.com/join) e DockerHub(https://hub.docker.com/) para execução dos próximos passos.

**Próximos passos:**

- Através do client AWS-CLI na linha de comando, execute a instrução abaixo, para habilitar o acesso aos recursos da sua conta AWS.
 Ao executar o comando, será solicitado o Access Key ID, Secret access key, região e formato de saída.
O projeto foi implementado utilizando a região us-east-2 (Ohio)

`$ AWS configure`

- Clonar o repositório do GitHub
-  Provisionar a os serviços (infraestrutura) necessários para executar o projeto
- Acessar a pasta infrastructure\aws atráves da linha de comando e execute as instruções abaixo:
`$ terraform init`
`$ terraform validate`
`$ terraform plan`
`$ terraform apply`

	***Destruir toda infraestrutura provisionada, execute o comando*** 
`$ terraform destroy`

- Configurar o kubectl para possa se conectar ao  cluster Kubernates (Amazon EKS)
`$ aws eks --region us-east-2 update-kubeconfig --name sicredi-eks`

	***Listar os nós do cluster do AWS EKS execute a seguinte instrução:***
`$ kubectl get nodes`


- Criar um namespace para separar os objetos ligados ao spark application 
`$ kubectl create namespace processing`

- Atráves do gerenciador de pacotes para Kubernates Helm, execute o comando abaixo.
Será adicionado um spark-operator, onde permitira suporte a execução de Spark applications.
`$ helm repo add spark-operator https://googlecloudplatform.github.io/spark-on-k8s-operator`
`$ helm repo update`
`$ helm install spark spark-operator/spark-operator -n processing`

	***Listar os operator e pods presentes no namespace processing***
	`$ helm ls -n processing`
	`$ kubectl get pods -n processing`

- Criar uma imagem customizada e subir para o docker hub
	`$ docker login -u [meuusername] -p [minhasenha]`
	`$ docker build -t wesleyst5/spark-operator:v3.0.0-aws .`
	`$ docker push wesleyst5/spark-operator:v3.0.0-aws`


- Criar uma conta de serviço através através do manifesto **cluster-role-binding-spark-operator-processing.yaml**
`$ kubectl apply -f cluster-role-binding-spark-operator-processing.yaml -n processing`

- Criar um secret no kubernates, que irá conter as informações de aws_access_key_id e aws_access_key para uso futuro no código .py que irá executar o processamento.
`kubectl create secret generic aws-credentials --from-literal=aws_access_key_id=[meukeyid] --from-literal=aws_secret_access_key=[meusecretkey] -n processing`
	***Subistituir [meukeyid] e [meusecretkey] pelas informações da sua conta AWS.***

- Criar uma SparkApplication para executar o processamento (Ler Mysql -> Escrever no Datalake)
`$ kubectl apply -f spark-batch-operator-k8s-v1beta2.yaml -n processing`

	**Instruições de verificação:**
`$ kubectl get sparkapplications -n processing`
`$ kubectl get pods -n processing --watch`
`$ kubectl logs job-pyspark-batch-driver -n processing`

	***Deletar uma uma sparkapplications***
`$ kubectl logs job-pyspark-batch-driver -n processing`

- Conforme requisitos do projeto, chegou a hora de conferir o resultado. 
Verificar no bucket S3 (s3://datalake-sicredi/processing/movimentacao-conta/) se o arquivo csv foi gerado.

### Dificuldades

As situações que eu não havia me deparado ainda e que me tomaram mais tempo para pesquisar e solucionar foram:

- Automatizar a criação de tabelas e inserção dos dados durante o provisionamento do banco de dados Mysql.
- Funcionar a comunicação do AWS EKS e AWS S3. (Como solução foi adicionado a instrução na proriedade do SparkContext a configuração ***sc.setSystemProperty('com.amazonaws.services.s3.enableV4', 'true')***


### Com mais tempo..

- Implementar e fazer o uso do de integração continua, através do recurso action Workflows do GitHub.
- Provisionar a ferramenta Apache Airflow (gerenciamento e orquestração de fluxo) e a ferramenta Argo CD na abordagem GitOps e implantação de aplicações no Kubernetes.


### Alternativas de solução:
- Uso do notebook nos serviço gerenciados AWS EMR para processamento do pipeline.
- Uso do notebook serviço gerenciado AWS Glue para processamento do pipeline.
- Uso de Docker

