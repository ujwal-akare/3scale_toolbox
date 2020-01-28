RSpec.describe 'Product copy' do
  include_context :real_api3scale_client
  include_context :random_name
  include_context :real_copy_cleanup

  let(:source_url) { client_url }
  let(:destination_url) { client_url }
  let(:target_system_name) { "service_#{random_lowercase_name}_#{Time.now.getutc.to_i}" }
  let(:command_line_str) do
    "product copy -t #{target_system_name}" \
      " -s #{source_url} -d #{destination_url} #{source_service.id}"
  end
  let(:command_line_args) { command_line_str.split }
  subject { ThreeScaleToolbox::CLI.run(command_line_args) }
  # source product is being created for testing
  let(:source_service) { Helpers::ServiceFactory.new_service api3scale_client }
  let(:target_service) do
    ThreeScaleToolbox::Entities::Service.find(ref: target_system_name, remote: api3scale_client)
  end

  it_behaves_like 'service copied'

  context 'with backends' do
    let(:source_backend_01) { Helpers::BackendFactory.new_backend api3scale_client }
    let(:source_backend_02) { Helpers::BackendFactory.new_backend api3scale_client }

    before :each do
      # backend_usage_01
      attrs = { 'backend_api_id' => source_backend_01.id, 'service_id' => source_service.id, 'path' => '/v1' }
      ThreeScaleToolbox::Entities::BackendUsage.create(product: source_service, attrs: attrs)
      # backend_usage_02
      attrs = { 'backend_api_id' => source_backend_02.id, 'service_id' => source_service.id, 'path' => '/v2' }
      ThreeScaleToolbox::Entities::BackendUsage.create(product: source_service, attrs: attrs)
    end

    after :each do
      target_service.backend_usage_list.each(&:delete)
      source_service.backend_usage_list.each(&:delete)
      source_backend_01.delete
      source_backend_02.delete
    end

    it 'copied' do
      expect { subject }.to output.to_stdout
      expect(subject).to eq(0)

      # only copy of backend usage is verified
      # To verify backend copy, two different accounts are needed
      backend_path_ary = target_service.backend_usage_list.map(&:path)
      expect(backend_path_ary).to include('/v1')
      expect(backend_path_ary).to include('/v2')
    end
  end
end
