RSpec.shared_examples 'target service params' do
  include_context :source_service_data

  it 'all expected params are copied' do
    target_service_obj = subject.target_service_params(source_service_obj)
    expect(target_service_obj).to include(*target_service_params)
  end

  it 'extra params are not copied' do
    extra_params = {
      'some_weird_param' => 'value0',
      'some_other_weird_param' => 'value1'
    }
    target_service_obj = subject.target_service_params(
      source_service_obj.merge(extra_params)
    )
    expect(target_service_obj).to include(*target_service_params)
    expect(target_service_obj).not_to include(*extra_params)
  end

  it 'missing params are not copied' do
    missing_params = %w[description backend_version]
    missing_params.each do |key|
      source_service_obj.delete(key)
    end
    target_service_obj = subject.target_service_params(source_service_obj)
    expect(target_service_obj).to include(*(target_service_params - missing_params))
    expect(target_service_obj).not_to include(*missing_params)
  end
end
