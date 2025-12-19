require 'rails_helper'

RSpec.describe MarkReady do
  let(:repo) { instance_double(RedisOrderRepository) }
  subject { described_class.new(repo) }
  let(:order) { build(:order, status: 'EM_PREPARACAO') }

  it 'marca o pedido como pronto' do
    allow(repo).to receive(:find_by_id).with(order.id).and_return(order)
    expect(repo).to receive(:update).with(order)

    result = subject.execute(order_id: order.id)
    expect(result.status).to eq('PRONTO')
  end
end
