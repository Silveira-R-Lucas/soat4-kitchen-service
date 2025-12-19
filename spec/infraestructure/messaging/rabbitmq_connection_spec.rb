require 'rails_helper'

RSpec.describe RabbitmqConnection do
  let(:bunny_session) { instance_double(Bunny::Session) }
  let(:channel) { instance_double(Bunny::Channel) }

  before do
    allow(Bunny).to receive(:new).and_return(bunny_session)
    allow(bunny_session).to receive(:start)
    allow(bunny_session).to receive(:create_channel).and_return(channel)
    # Importante: Mockar o sleep e puts para o teste ser rápido e limpo
    allow(described_class).to receive(:sleep)
    allow(described_class).to receive(:puts)
  end

  describe '.start' do
    it 'conecta e retorna a sessão' do
      expect(described_class.start).to eq(bunny_session)
    end

    it 'tenta reconectar em caso de falha de rede (branch de rescue/retry)' do
      call_count = 0
      # Na primeira chamada falha, na segunda funciona
      allow(bunny_session).to receive(:start) do
        call_count += 1
        raise Bunny::TCPConnectionFailedForAllHosts if call_count == 1
      end

      expect(described_class).to receive(:sleep).once
      expect(described_class.start).to eq(bunny_session)
    end
  end

  describe '.channel' do
    it 'cria um canal se ainda não existir' do
      # Reseta a variável de classe para forçar criação
      described_class.instance_variable_set(:@channel, nil)
      expect(described_class.channel).to eq(channel)
    end
  end
end
