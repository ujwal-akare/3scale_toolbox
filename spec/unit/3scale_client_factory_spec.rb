require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::ThreeScaleClientFactory do
  let(:remotes) { double('remotes') }
  let(:threescale_api) { class_double('ThreeScale::API').as_stubbed_const }
  let(:endpoint) { 'https://example.com' }
  let(:authentication) { '123456789' }
  let(:verify_ssl) { true }
  let(:api_info) { { endpoint: endpoint, provider_key: authentication, verify_ssl: verify_ssl } }
  let(:remote_info) { { endpoint: endpoint, authentication: authentication } }
  let(:client) { double('client') }
  let(:verbose) { false }
  let(:remote_str) do
    u = URI(endpoint)
    u.user = authentication
    u.to_s
  end
  subject { described_class.get(remotes, remote_str, verify_ssl, verbose) }

  context '#call' do
    before :each do
      expect(threescale_api).to receive(:new).with(api_info).and_return(client)
    end

    it 'client is returned' do
      expect(subject).to eq(client)
    end

    context 'remote name param' do
      let(:remote_str) { 'remoteA' }

      it 'client is returned' do
        expect(remotes).to receive(:fetch).with(remote_str).and_return(remote_info)
        expect(subject).to eq(client)
      end
    end

    context 'verbose mode' do
      let(:verbose) { true }

      it 'proxy client is returned' do
        proxy_logger = class_double('ThreeScaleToolbox::ProxyLogger').as_stubbed_const
        proxied_client = double('proxied_client')
        expect(proxy_logger).to receive(:new).with(client).and_return(proxied_client)
        expect(subject).to eq(proxied_client)
      end
    end
  end
end
