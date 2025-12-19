require 'rails_helper'

RSpec.describe EnqueueOrder do
  let(:repo) { instance_double(RedisOrderRepository) }
  subject { described_class.new(repo) }

  it 'cria um novo pedido e o enfileira' do
    expect(repo).to receive(:enqueue).with(an_instance_of(Order))

    result = subject.execute(pedido_id: '123', items: [])

    expect(result).to be_a(Order)
    expect(result.pedido_id).to eq('123')
    expect(result.status).to eq('RECEBIDO')
  end
end
