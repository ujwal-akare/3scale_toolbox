RSpec.describe ThreeScaleToolbox::Tasks::DestroyMappingRulesTask do
  context '#call' do
    let(:target) { instance_double('ThreeScaleToolbox::Entities::Service', 'target') }
    subject { described_class.new(target: target) }

    context 'several mapping rules available' do
      let(:n_rules) { 10 }
      let(:target_mapping_rules) do
        Array.new(n_rules) do |idx|
          {
            'id' => idx,
            'metric_id' => 0,
            'pattern' => "/rule_#{idx}",
            'http_method' => 'GET',
            'delta' => 1,
            'redirect_url' => nil,
            'created_at' => '2014-08-07T11:15:10+02:00',
            'updated_at' => '2014-08-07T11:15:13+02:00',
            'links' => []
          }
        end
      end

      it 'it calls delete_mapping_rule method on each rule' do
        expect(target).to receive(:mapping_rules).and_return(target_mapping_rules)
        expect(target_mapping_rules.size).to be > 0
        target_mapping_rules.each do |mapping_rule|
          expect(target).to receive(:delete_mapping_rule).with(mapping_rule['id'])
        end

        # Run
        subject.call
      end
    end
  end
end
