# SOAT4 - Kitchen Service (Microsserviço de Cozinha) - Fase 04
O Kitchen Service é o microsserviço responsável pela gestão da fila de produção e do estado dos pedidos em preparação na lanchonete SOAT. Ele garante a orquestração do fluxo de trabalho na cozinha, desde o recebimento do pedido pago até a sua finalização, utilizando uma arquitetura orientada a eventos.

## 🚀 Tecnologias e Dependências
Linguagem: Ruby 3.2.2.

Framework: Rails 7.2.3 (API Mode).

Base de Dados: Redis (utilizado como armazenamento principal de estado para a fila de produção rápida).

Processamento em Background: Sidekiq (para gestão de tarefas de longa duração e retentativas).

Mensageria: RabbitMQ (via gem bunny) para comunicação assíncrona entre microsserviços.

Qualidade: SonarCloud, RuboCop e Brakeman (Segurança).

## 🏗️ Arquitetura e Organização
O serviço segue os princípios de Clean Architecture e Arquitetura Hexagonal, assegurando o desacoplamento entre as regras de negócio e os adaptadores de infraestrutura:

Domain: Entidades puras como Order que definem os estados de produção (RECEBIDO, EM_PREPARACAO, PRONTO, FINALIZADO).

Use Cases: Implementação de fluxos críticos como EnqueueOrder, StartPreparation, MarkReady e FinalizeOrder.

Infrastructure (Adapters):

Persistence: Repositório especializado para Redis (RedisOrderRepository) para alta performance na fila.

Messaging: Adaptadores para consumo e publicação de mensagens no RabbitMQ.

Workers: ProductionWorker para simular e gerir o ciclo de vida do preparo via Sidekiq.

## 📥 Consumo de Mensagens (Consumers)
O serviço é acionado automaticamente através de eventos do sistema, garantindo um fluxo contínuo sem intervenção manual:

Evento PagamentoAprovado: O Consumer dedicado escuta a fila kitchen.pagamento-aprovado. Ao receber a confirmação de pagamento vinda do Payment Service, ele enfileira o pedido para produção no Redis e dispara o ProductionWorker.

Sidekiq Workers: Gerem o processamento assíncrono interno, permitindo que a cozinha escale independentemente da API.

## 🛠️ Configuração e Instalação
O projeto inclui um script de setup para automatizar a preparação do ambiente:
```
# Instala dependências e prepara o ambiente
./bin/setup

# Para execução via Docker Compose (inclui Redis e workers):
docker-compose up --build
```

## 🧪 Testes e Cobertura
A integridade do sistema é validada através de testes automatizados com RSpec, utilizando MockRedis para simular o comportamento da base de dados em ambiente controlado.

Executar Testes: bundle exec rspec.

Cobertura Mínima: 80% (exigida pelo Quality Gate do SonarCloud).

## 🎡 Pipeline de CI/CD
O fluxo de entrega contínua via GitHub Actions automatiza a qualidade e o deploy:

Test-and-analyze: Executa linting, scan de vulnerabilidades, testes unitários (com serviço Redis em container) e análise profunda no SonarCloud.

Build-and-push: Constrói a imagem Docker imutável e a envia para o Amazon ECR.

Secrets Management: Sincroniza e atualiza tags de imagem e chaves sensíveis no AWS Secrets Manager.

## ⚓ Deployment no Kubernetes
O microsserviço é implantado no Amazon EKS com segregação de responsabilidades:

API (Web): Atende requisições de consulta de fila e comandos manuais de status na porta 3002.

Sidekiq (Worker): Deployment dedicado para o processamento de tarefas em background.

Consumer (Worker): Processo rails runner dedicado exclusivamente a escutar o RabbitMQ.

As credenciais e URLs de conexão (Redis, RabbitMQ) são injetadas via ConfigMaps e Secrets integrados nativamente com o ambiente AWS.
