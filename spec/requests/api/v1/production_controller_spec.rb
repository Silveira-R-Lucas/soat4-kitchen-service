require 'rails_helper'

RSpec.describe "Api::V1::Production", type: :request do
  let(:repo_mock) { instance_double(RedisOrderRepository) }
  let(:order) { build(:order) }

  before do
    allow(RedisOrderRepository).to receive(:new).and_return(repo_mock)
  end

  describe "POST /api/v1/production/enqueue" do
    it "cria pedido e retorna 201" do
      use_case = instance_double(EnqueueOrder)
      allow(EnqueueOrder).to receive(:new).with(repo_mock).and_return(use_case)
      allow(use_case).to receive(:execute).and_return(order)

      post "/api/v1/production/enqueue", params: { pedido_id: "10" }

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['id']).to eq(order.id)
    end

    it "retorna 422 em caso de erro" do
      allow(EnqueueOrder).to receive(:new).and_raise(StandardError.new("Erro"))
      post "/api/v1/production/enqueue", params: { pedido_id: "10" }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /api/v1/production/next" do
    it "retorna o próximo pedido" do
      allow(repo_mock).to receive(:pop_next).and_return(order)

      get "/api/v1/production/next"
      expect(response).to have_http_status(:ok)
    end

    it "retorna no_content se fila vazia" do
      allow(repo_mock).to receive(:pop_next).and_return(nil)
      get "/api/v1/production/next"
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/v1/production/:id/start" do
    it "executa o use case StartPreparation" do
      use_case = instance_double(StartPreparation)
      allow(StartPreparation).to receive(:new).with(repo_mock).and_return(use_case)
      allow(use_case).to receive(:execute).with(order_id: "abc").and_return(order)

      post "/api/v1/production/abc/start"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "Tratamento de Exceções Globais" do
    it "retorna erro tratado (422) mesmo em falhas de infraestrutura" do
      allow(RedisOrderRepository).to receive(:new).and_raise(StandardError.new("Redis Down"))
      post "/api/v1/production/enqueue", params: { pedido_id: "123" }

      # Correção: Aceitamos que o controller trata o erro como unprocessable_entity
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
