RSpec.describe ThreeScaleToolbox::Commands::BackendCommand::CopyCommand::CopyMethodsTask do
  let(:backendmethod_class) { class_double(ThreeScaleToolbox::Entities::BackendMethod).as_stubbed_const }
  let(:source_backend) { instance_double(ThreeScaleToolbox::Entities::Backend, 'source_backend') }
  let(:target_backend) { instance_double(ThreeScaleToolbox::Entities::Backend, 'target_backend') }
  let(:source_hits_metric) { instance_double(ThreeScaleToolbox::Entities::BackendMetric) }
  let(:target_hits_metric) { instance_double(ThreeScaleToolbox::Entities::BackendMetric) }
  let(:target_hits_id) { 12345 }
  let(:source_methods) { [] }
  let(:target_methods) { [] }
  let(:context)  do
    {
      source_backend: source_backend,
      target_backend: target_backend
    }
  end
  subject { described_class.new(context) }

  context '#run' do
    before :each do
      allow(source_backend).to receive(:methods).and_return(source_methods)
      allow(source_backend).to receive(:hits).and_return(source_hits_metric)
      allow(target_backend).to receive(:methods).and_return(target_methods)
      allow(target_backend).to receive(:hits).and_return(target_hits_metric)
      allow(target_hits_metric).to receive(:id).and_return(target_hits_id)
    end

    it 'no method created' do
      subject.run
    end

    context 'only missing methods created' do
      let(:method_src_0) { instance_double(ThreeScaleToolbox::Entities::BackendMethod, 'method_src_0') }
      let(:method_src_1) { instance_double(ThreeScaleToolbox::Entities::BackendMethod, 'method_src_1') }
      let(:method_src_1_attrs) { { 'name' => 'method_1' } }
      let(:method_tgt) { instance_double(ThreeScaleToolbox::Entities::BackendMethod, 'method_tgt') }
      let(:source_methods) { [method_src_0, method_src_1] }
      let(:target_methods) { [method_tgt] }

      it 'method with same system_name not created' do
        allow(method_src_0).to receive(:system_name).and_return('system_name_0')
        allow(method_src_1).to receive(:system_name).and_return('system_name_1')
        # same as method_src_0
        allow(method_tgt).to receive(:system_name).and_return('system_name_0')

        expect(method_src_1).to receive(:attrs).and_return(method_src_1_attrs)
        expect(backendmethod_class).to receive(:create).with(backend: target_backend,
                                                             parent_id: target_hits_id,
                                                             attrs: method_src_1_attrs)

        subject.run
      end
    end
  end
end
