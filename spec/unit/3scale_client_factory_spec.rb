RSpec.describe ThreeScaleToolbox::ThreeScaleClientFactory do
  let(:remotes) { instance_double('ThreeScaleToolbox::Remotes', 'remotes') }
  let(:threescale_api) { class_double('ThreeScale::API').as_stubbed_const }
  let(:remote_cache) { class_double('ThreeScaleToolbox::RemoteCache').as_stubbed_const }
  let(:endpoint) { 'https://example.com' }
  let(:authentication) { '123456789' }
  let(:verify_ssl) { true }
  let(:keep_alive) { false }
  let(:api_info) do
    {
      endpoint: endpoint, provider_key: authentication,
      verify_ssl: verify_ssl, keep_alive: keep_alive,
    }
  end
  let(:remote_info) { { endpoint: endpoint, authentication: authentication } }
  let(:client) { instance_double('ThreeScale::API::Client', 'client') }
  let(:remote_cache_client) { instance_double('ThreeScaleToolbox::RemoteCache') }
  let(:verbose) { false }
  let(:remote_str) do
    u = URI(endpoint)
    u.user = authentication
    u.to_s
  end
  subject { described_class.get(remotes, remote_str, verify_ssl, verbose, keep_alive) }

  context '#call' do
    context 'verbose mode off' do
      before :each do
        expect(threescale_api).to receive(:new).with(api_info).and_return(client)
        expect(remote_cache).to receive(:new).with(client).and_return(remote_cache_client)
      end

      it 'remote cached client is returned' do
        expect(subject).to eq(remote_cache_client)
      end

    end

    context 'remote name param' do
      let(:remote_str) { 'remoteA' }

      before :each do
        expect(threescale_api).to receive(:new).with(api_info).and_return(client)
        expect(remote_cache).to receive(:new).with(client).and_return(remote_cache_client)
      end

      it 'client is returned' do
        expect(remotes).to receive(:fetch).with(remote_str).and_return(remote_info)
        expect(subject).to eq(remote_cache_client)
      end
    end

    context 'verbose mode on' do
      let(:verbose) { true }
      let(:proxy_logger) { class_double('ThreeScaleToolbox::ProxyLogger').as_stubbed_const }
      let(:proxied_client) { instance_double('ThreeScaleToolbox::ProxyLogger') }

      it 'proxy client is included in the chain' do
        expect(threescale_api).to receive(:new).with(api_info).and_return(client)
        expect(proxy_logger).to receive(:new).with(client).and_return(proxied_client)
        expect(remote_cache).to receive(:new).with(proxied_client).and_return(remote_cache_client)
        expect(subject).to eq(remote_cache_client)
      end
    end

    context 'enable keep alive' do
      let(:keep_alive) { true }

      before :each do
        expect(remote_cache).to receive(:new).with(client).and_return(remote_cache_client)
      end

      it '' do
        expect(threescale_api).to receive(:new).with(hash_including(keep_alive: true)).and_return(client)
        subject
      end
    end
  end
end
