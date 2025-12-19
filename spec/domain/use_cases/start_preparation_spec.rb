require 'rails_helper'

RSpec.describe StartPreparation do
  let(:repo) { instance_double(RedisOrderRepository) }
  subject { described_class.new(repo) }
  let(:order) { build(:order) }

  it 'inicia a preparação do pedido' do
    allow(repo).to receive(:find_by_id).with(order.id).and_return(order)

    expect(repo).to receive(:update).with(order) do |updated_order|
      expect(updated_order.status).to eq('EM_PREPARACAO')
    end

    result = subject.execute(order_id: order.id)
    expect(result.status).to eq('EM_PREPARACAO')
  end

  it 'lança erro se pedido não encontrado' do
    allow(repo).to receive(:find_by_id).and_return(nil)
    expect { subject.execute(order_id: '999') }.to raise_error('Order not found')
  end
end
