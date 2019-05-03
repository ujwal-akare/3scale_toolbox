RSpec.describe ThreeScaleToolbox::Tasks::CopyMethodsTask do
  context '#call' do
    let(:source) { instance_double('ThreeScaleToolbox::Entities::Service', 'source') }
    let(:target) { instance_double('ThreeScaleToolbox::Entities::Service', 'target') }
    let(:method_class) { class_double('ThreeScaleToolbox::Entities::Method').as_stubbed_const }
    let(:method_0) do
      {
        'id' => 0,
        'name' => 'method_0',
        'system_name' => 'method_0',
        'friendly_name' => 'method 0',
        'created_at' => '2014-08-07T11:15:10+02:00',
        'updated_at' => '2014-08-07T11:15:13+02:00',
        'links' => []
      }
    end
    let(:method_1) do
      {
        'id' => 1,
        'name' => 'method_1',
        'system_name' => 'method_1',
        'friendly_name' => 'method 1',
        'created_at' => '2014-08-07T11:15:10+02:00',
        'updated_at' => '2014-08-07T11:15:13+02:00',
        'links' => []
      }
    end

    let(:target_hits_metric_id) { 10 }

    subject { described_class.new(source: source, target: target) }

    before :each do
      expect(source).to receive(:methods).and_return(source_methods)
      expect(source).to receive(:hits).and_return('id' => 1)
      expect(target).to receive(:methods).and_return(target_methods)
      expect(target).to receive(:hits).and_return('id' => target_hits_metric_id)
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
                                                      parent_id: target_hits_metric_id,
                                                      attrs: hash_including('system_name' => method_0['system_name'],
                                                                            'friendly_name' => method_0['friendly_name'])
        )
        expect { subject.call }.to output(/created 1 missing methods/).to_stdout
      end
    end
  end
end
