RSpec.describe ThreeScaleToolbox::Entities::ProxyConfig do
  include_context :random_name
  let(:remote) { instance_double('ThreeScale::API::Client', 'remote') }
  let(:service_ref) { "3" }
  let(:proxy_config_env) { "production" }
  let(:proxy_config_version) { 7 }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:proxy_config_res) { { "id" => 25, "environment" => proxy_config_env, "version" => proxy_config_version } }

  before :example do
    expect(service).to receive(:id).and_return(service_ref)
  end

  context "ProxyConfig.find" do
    before :example do
      expect(service).to receive(:remote).and_return(remote)
    end
    it "returns an instance when it is found" do
      expect(remote).to receive(:show_proxy_config).and_return(proxy_config_res)
      pc_obj = described_class.find(service: service, environment: proxy_config_env, version: proxy_config_version)
      expect(pc_obj).to_not be_nil
      expect(pc_obj.remote).to eq(remote)
      expect(pc_obj.service).to eq(service)
      expect(pc_obj.version).to eq(proxy_config_version)
      expect(pc_obj.attrs).to eq(proxy_config_res)
    end

    it "returns nil when it is not found" do
      expect(remote).to receive(:show_proxy_config).and_raise(ThreeScale::API::HttpClient::NotFoundError.new(nil))
      pc_obj = described_class.find(service: service, environment: proxy_config_env, version: proxy_config_version)
      expect(pc_obj).to be_nil
    end
  end

  context "ProxyConfig.find_latest" do
    it "returns an instance when it is found" do
      expect(remote).to receive(:proxy_config_latest).and_return(proxy_config_res)
      expect(service).to receive(:remote).and_return(remote).twice
      pc_obj = described_class.find_latest(service: service, environment: proxy_config_env)
      expect(pc_obj).to_not be_nil
      expect(pc_obj.remote).to eq(remote)
      expect(pc_obj.service).to eq(service)
      expect(pc_obj.version).to eq(proxy_config_version)
      expect(pc_obj.attrs).to eq(proxy_config_res)
    end

    it "returns nil when it is not found" do
      expect(remote).to receive(:proxy_config_latest).and_raise(ThreeScale::API::HttpClient::NotFoundError.new(nil))
      expect(service).to receive(:remote).and_return(remote)

      pc_obj = described_class.find_latest(service: service, environment: proxy_config_env)
      expect(pc_obj).to be_nil
    end
  end

  context "Instance method" do
    subject { described_class.new(environment: proxy_config_env, service: service, version: proxy_config_version) }

    before :example do
      expect(service).to receive(:remote).and_return(remote)
    end

    context "#attrs" do

      it 'calls show_proxy_config method' do
        expect(remote).to receive(:show_proxy_config).and_return(proxy_config_res)
        subject.attrs
      end

      context 'API cannot be contacted' do
        let(:response_body) { { 'errors' => 'some error' } }

        it 'returns an error' do
          expect(remote).to receive(:show_proxy_config).and_return(response_body)
          expect do
            subject.attrs
          end.to raise_error(ThreeScaleToolbox::ThreeScaleApiError)
        end
      end
    end

    context "#promote" do
      let(:proxy_config_to) { "production" }

      it "calls promote_proxy_config" do
        expect(remote).to receive(:promote_proxy_config).with(service_ref, proxy_config_env, proxy_config_version, proxy_config_to).and_return(proxy_config_res)
        expect(subject.promote(to: proxy_config_to)).to eq proxy_config_res
      end

      context 'API cannot be contacted' do
        let(:response_body) { { 'errors' => 'some error' } }

        it 'returns an error' do
          expect(remote).to receive(:promote_proxy_config).and_return(response_body)
          expect do
            subject.promote(to: proxy_config_to)
          end.to raise_error(ThreeScaleToolbox::ThreeScaleApiError)
        end
      end
    end
  end
end
