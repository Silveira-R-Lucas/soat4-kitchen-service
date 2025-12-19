require 'rails_helper'

RSpec.describe RabbitmqPublisher do
  let(:channel) { instance_double(Bunny::Channel) }
  let(:exchange) { instance_double(Bunny::Exchange) }
  subject { described_class.new("exchange_teste") }

  before do
    allow(RabbitmqConnection).to receive(:channel).and_return(channel)
    allow(channel).to receive(:fanout).with("exchange_teste", durable: true).and_return(exchange)
  end

  it 'publica uma mensagem formatada em JSON' do
    expect(exchange).to receive(:publish) do |msg_json|
      data = JSON.parse(msg_json)
      expect(data['event']).to eq('EventoTeste')
      expect(data['payload']).to eq({ 'id' => 1 })
    end

    subject.publish('EventoTeste', { id: 1 })
  end
end
