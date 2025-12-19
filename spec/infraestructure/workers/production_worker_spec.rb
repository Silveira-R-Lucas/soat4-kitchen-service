require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

RSpec.describe ProductionWorker do
  let(:repo) { instance_double(RedisOrderRepository) }
  let(:order) { build(:order) }

  before do
    allow(RedisOrderRepository).to receive(:new).and_return(repo)
    allow(described_class).to receive(:puts) # Silenciar puts
    allow_any_instance_of(Object).to receive(:sleep) # Pular sleep
  end

  it 'executa o ciclo completo do pedido' do
    allow(repo).to receive(:find_by_id).with('order_123').and_return(order)

    # Deve chamar update duas vezes (start e ready)
    expect(repo).to receive(:update).twice
    expect(order).to receive(:start_preparation!)
    expect(order).to receive(:mark_ready!)

    subject.perform('order_123')
  end

  it 'sai silenciosamente se pedido não encontrado' do
    allow(repo).to receive(:find_by_id).and_return(nil)
    expect(repo).not_to receive(:update)
    subject.perform('order_inexistente')
  end
end
