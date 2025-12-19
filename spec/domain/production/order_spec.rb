require 'rails_helper'

RSpec.describe Order do
  let(:order) { build(:order, status: 'RECEBIDO') }

  describe '#start_preparation!' do
    it 'muda o status para EM_PREPARACAO e atualiza o timestamp' do
      order.start_preparation!
      expect(order.status).to eq('EM_PREPARACAO')
      expect(order.updated_at).to be_within(1.second).of(Time.now)
    end
  end

  describe '#mark_ready!' do
    it 'muda o status para PRONTO' do
      order.mark_ready!
      expect(order.status).to eq('PRONTO')
    end
  end

  describe '#finalize!' do
    it 'muda o status para FINALIZADO' do
      order.finalize!
      expect(order.status).to eq('FINALIZADO')
    end
  end

  describe '#to_h' do
    it 'retorna a representação em hash' do
      hash = order.to_h
      expect(hash).to include(
        id: order.id,
        pedido_id: order.pedido_id,
        status: 'RECEBIDO'
      )
    end
  end
end
