RSpec.describe ThreeScaleToolbox::Commands::BackendCommand::CopyCommand::DeleteMappingRulesTask do
  let(:target) { instance_double('ThreeScaleToolbox::Entities::Service', 'target') }
  let(:base_context) { { target_backend: target, logger: Logger.new('/dev/null') } }
  let(:task_context) { base_context }
  subject { described_class.new(task_context) }

  context '#run' do
    context 'delete_mapping_rules flag false' do
      let(:task_context) { base_context.merge(delete_mapping_rules: false) }
      it 'no op' do
        # Run
        subject.call
      end
    end

    context 'several mapping rules available' do
      let(:task_context) { base_context.merge(delete_mapping_rules: true) }
      let(:n_rules) { 10 }
      let(:target_mapping_rules) do
        Array.new(n_rules) do |_|
          instance_double('ThreeScaleToolbox::Entities::MappingRule')
        end
      end

      it 'it calls delete_mapping_rule method on each rule' do
        expect(target).to receive(:mapping_rules).and_return(target_mapping_rules)
        expect(target_mapping_rules.size).to be > 0
        target_mapping_rules.each do |mapping_rule|
          expect(mapping_rule).to receive(:delete)
        end

        # Run
        subject.call
      end
    end
  end
end
