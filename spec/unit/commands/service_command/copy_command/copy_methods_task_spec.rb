RSpec.describe ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::CopyMethodsTask do
  context '#call' do
    let(:source) { instance_double('ThreeScaleToolbox::Entities::Service', 'source') }
    let(:target) { instance_double('ThreeScaleToolbox::Entities::Service', 'target') }
    let(:method_class) { class_double('ThreeScaleToolbox::Entities::Method').as_stubbed_const }
    let(:method_0) { instance_double(ThreeScaleToolbox::Entities::Method) }
    let(:method_1) { instance_double(ThreeScaleToolbox::Entities::Method) }
    let(:hits_metric) { instance_double(ThreeScaleToolbox::Entities::Metric) }

    subject { described_class.new(source: source, target: target) }

    before :each do
      allow(source).to receive(:methods).and_return(source_methods)
      allow(source).to receive(:hits).and_return(hits_metric)
      allow(target).to receive(:methods).and_return(target_methods)
      allow(target).to receive(:hits).and_return(hits_metric)
      allow(method_0).to receive(:system_name).and_return('method_0')
      allow(method_0).to receive(:attrs).and_return('system_name' => 'method_0', 'friendly_name' => 'method_0')
      allow(method_1).to receive(:system_name).and_return('method_1')
      allow(hits_metric).to receive(:id).and_return('1')
    end

    context 'no missing methods' do
      # missing methods is an empty set
      let(:source_methods) { [method_0] }
      let(:target_methods) { [method_0] }

      it 'does not call create_method method' do
        expect { subject.call }.to output(/created 0 missing methods/).to_stdout
      end
    end

    context '1 missing method' do
      let(:source_methods) { [method_0] }
      let(:target_methods) { [method_1] }

      it 'it calls create_method method' do
        # original method has been filtered
        expect(method_class).to receive(:create).with(service: target,
                                                      attrs: hash_including('system_name' => method_0.system_name))
        expect { subject.call }.to output(/created 1 missing methods/).to_stdout
      end
    end
  end
end
