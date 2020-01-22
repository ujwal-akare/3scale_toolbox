RSpec.describe 'Backend copy' do
  include_context :real_api3scale_client
  include_context :random_name
  include_context :toolbox_tasks_helper

  let(:target_system_name) { "backend_#{random_lowercase_name}_#{Time.now.getutc.to_i}" }
  let(:source_url) { client_url }
  let(:destination_url) { client_url }
  let(:command_line_str) do
    "backend copy -t #{target_system_name}" \
      " #{source_url} #{destination_url} #{source_backend.id}"
  end
  let(:command_line_args) { command_line_str.split }
  subject { ThreeScaleToolbox::CLI.run(command_line_args) }
  # source backend is being created for testing
  let(:source_backend) { Helpers::BackendFactory.new_backend api3scale_client }

  after :example do
    source_backend.delete
    begin
      target_backend = ThreeScaleToolbox::Entities::Backend.find_by_system_name(
        remote: api3scale_client,
        system_name: target_system_name
      )
    rescue ThreeScale::API::HttpClient::NotFoundError
    else
      target_backend.delete
    end
  end

  it do
    expect { subject }.to output.to_stdout
    expect(subject).to eq(0)

    target_backend = ThreeScaleToolbox::Entities::Backend.find_by_system_name(
      remote: api3scale_client,
      system_name: target_system_name
    )

    # backend settings
    expect(target_backend).not_to eq(source_backend)
    source_settings = source_backend.attrs.slice(ThreeScaleToolbox::Entities::Backend::VALID_PARAMS - ['system_name'])
    target_settings = target_backend.attrs.slice(ThreeScaleToolbox::Entities::Backend::VALID_PARAMS - ['system_name'])
    expect(source_settings).to eq(target_settings)

    # backend metrics
    source_metrics = source_backend.metrics
    expect(source_metrics.size).to be > 0
    expect(source_metrics.map(&:attrs)).to be_subset_of(target_backend.metrics.map(&:attrs)).comparing_keys(%w[name system_name unit])

    # backend methods
    source_methods = source_backend.methods source_backend.hits
    target_methods = target_backend.methods target_backend.hits
    expect(source_methods.size).to be > 0
    expect(source_methods.map(&:attrs)).to be_subset_of(target_methods.map(&:attrs)).comparing_keys(%w[friendly_name system_name])

    # backend mapping rules
    source_mapping_rules = source_backend.mapping_rules
    target_mapping_rules = target_backend.mapping_rules
    mapping_rule_keys = %w[pattern http_method delta]
    expect(source_mapping_rules.size).to be > 0
    source_mapping_rules.each do |source_mapping_rule|
      copied_mapping_rule = target_mapping_rules.find do |target_mapping_rule|
        ThreeScaleToolbox::Helper.compare_hashes(source_mapping_rule.attrs,
                                                 target_mapping_rule.attrs,
                                                 mapping_rule_keys)
      end
      expect(copied_mapping_rule).to be
    end
  end
end
