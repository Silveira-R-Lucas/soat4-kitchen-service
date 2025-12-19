require 'rails_helper'

RSpec.describe RabbitmqConsumer do
  let(:channel) { double("Channel", fanout: double, queue: double(bind: true, subscribe: true), close: true) }

  before do
    allow(RabbitmqConnection).to receive(:channel).and_return(channel)
  end

  describe '#handle_message (via send)' do
    let(:consumer) { described_class.new('ex', 'q') }
    let(:repo) { instance_double(RedisOrderRepository) }
    let(:use_case) { instance_double(EnqueueOrder) }
    let(:order) { build(:order, id: 'uuid-123') }

    before do
      allow(RedisOrderRepository).to receive(:new).and_return(repo)
      allow(EnqueueOrder).to receive(:new).with(repo).and_return(use_case)
    end

    it 'processa PagamentoAprovado e enfileira worker' do
      payload = { event: "PagamentoAprovado", payload: { "pedido_id" => 10, "items" => [] } }.to_json

      expect(use_case).to receive(:execute).with(pedido_id: 10, items: []).and_return(order)
      expect(ProductionWorker).to receive(:perform_async).with('uuid-123')

      consumer.send(:handle_message, payload)
    end
  end
end
