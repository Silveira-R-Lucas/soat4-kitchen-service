require 'rails_helper'

RSpec.describe RedisOrderRepository do
  let(:mock_redis) { MockRedis.new }
  subject { described_class.new(mock_redis) }

  describe '#enqueue' do
    let(:order) { build(:order, pedido_id: '123') }

    it 'salva o pedido e coloca na fila' do
      id = subject.enqueue(order)

      # Verifica persistência
      data = mock_redis.hgetall("default:order:#{id}")
      expect(data['pedido_id']).to eq('123')

      # Verifica fila
      expect(mock_redis.lrange("default:queue", 0, -1)).to include(id)
    end
  end

  describe '#pop_next' do
    it 'retorna o próximo da fila e move para in_progress' do
      order = build(:order, pedido_id: '001')
      id = subject.enqueue(order)

      popped = subject.pop_next

      expect(popped.pedido_id).to eq('001')
      # Saiu da fila?
      expect(mock_redis.llen("default:queue")).to eq(0)
      # Foi para o set de processamento?
      expect(mock_redis.sismember("default:in_progress", id)).to be true
    end

    it 'retorna nil se fila vazia' do
      expect(subject.pop_next).to be_nil
    end
  end

  describe '#find_by_id' do
    it 'recupera um pedido salvo' do
      order = build(:order)
      id = subject.enqueue(order)

      found = subject.find_by_id(id)
      expect(found.pedido_id).to eq(order.pedido_id)
    end

    it 'retorna nil se não existe' do
      expect(subject.find_by_id('nada')).to be_nil
    end
  end

  describe '#update' do
    it 'atualiza os dados e gerencia o set in_progress' do
      order = build(:order, status: 'RECEBIDO')
      subject.enqueue(order)

      # Simula mudança para EM_PREPARACAO
      order.start_preparation!
      subject.update(order)

      data = mock_redis.hgetall("default:order:#{order.id}")
      expect(data['status']).to eq('EM_PREPARACAO')
      expect(mock_redis.sismember("default:in_progress", order.id)).to be true

      # Simula finalização (deve sair do set)
      order.finalize!
      subject.update(order)
      expect(mock_redis.sismember("default:in_progress", order.id)).to be false
    end
  end
end
