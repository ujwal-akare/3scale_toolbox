require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::ThreeScaleClientFactory do
  let(:remotes) { double('remotes') }
  let(:threescale_api) { class_double('ThreeScale::API').as_stubbed_const }
  let(:endpoint) { 'https://example.com' }
  let(:authentication) { '123456789' }
  let(:verify_ssl) { true }
  let(:origin) do
    u = URI(endpoint)
    u.user = authentication
    u.to_s
  end
  let(:api_info) { { endpoint: endpoint, provider_key: authentication, verify_ssl: verify_ssl } }
  let(:remote_info) { { endpoint: endpoint, authentication: authentication } }
  let(:client) { double('client') }
  subject { described_class.get(remotes, remote_str, verify_ssl) }

  context '#call' do
    context 'remote url param' do
      let(:remote_str) { origin }

      it 'client is returned' do
        expect(threescale_api).to receive(:new).with(api_info).and_return(client)
        expect(subject).to eq(client)
      end
    end

    context 'remote name param' do
      let(:remote_str) { 'remoteA' }

      it 'client is returned' do
        expect(remotes).to receive(:fetch).with(remote_str).and_return(remote_info)
        expect(threescale_api).to receive(:new).with(api_info).and_return(client)
        expect(subject).to eq(client)
      end
    end
  end
end
