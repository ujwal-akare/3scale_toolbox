require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Remotes do
  let(:test_class) do
    Class.new { include ThreeScaleToolbox::Remotes }
  end

  subject { test_class.new }

  context '#remote' do
    let(:threescale_api) { class_double('ThreeScale::API').as_stubbed_const }
    let(:endpoint) { 'https://example.com' }
    let(:authkey) { '123456789' }
    let(:verify_ssl) { true }
    let(:origin) do
      u = URI(endpoint)
      u.user = authkey
      u.to_s
    end
    let(:api_info) { { endpoint: endpoint, provider_key: authkey, verify_ssl: verify_ssl } }

    it '"invalid" raises error on invalid url' do
      expect { subject.remote('invalid', verify_ssl) }.to raise_error(ThreeScaleToolbox::Error, /invalid url/)
    end

    it '"htt://bla" raises error on invalid url' do
      expect { subject.remote('htt://bla', verify_ssl) }.to raise_error(ThreeScaleToolbox::Error, /invalid url/)
    end

    it '"httpss://bla" raises error on invalid url' do
      expect { subject.remote('httpss://bla', verify_ssl) }.to raise_error(ThreeScaleToolbox::Error, /invalid url/)
    end

    it 'valid origin should create remote' do
      expect(threescale_api).to receive(:new).with(api_info)
      subject.remote(origin, verify_ssl)
    end
  end
end
