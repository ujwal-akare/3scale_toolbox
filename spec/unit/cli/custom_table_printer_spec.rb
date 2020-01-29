RSpec.describe ThreeScaleToolbox::CLI::CustomTablePrinter do
  let(:fields) { %w[my_field_name_a my_field_name_b] }
  let(:record_a) { { 'my_field_name_a' => 11, 'my_field_name_b' => 22 } }
  let(:record_b) { { 'my_field_name_a' => 33, 'my_field_name_b' => 44 } }

  shared_examples 'header printed' do
    it 'header_printed' do
      expect { subject }.to output(/#{fields.map(&:upcase).join('\t')}/).to_stdout
    end
  end

  context '#print_record' do
    subject { described_class.new(fields).print_record(record_a) }

    include_examples 'header printed'

    it 'record_a printed' do
      expect { subject }.to output(/#{record_a.values.join('\t')}/).to_stdout
    end
  end

  context '#print_collection' do
    subject { described_class.new(fields).print_collection([record_a, record_b]) }

    include_examples 'header printed'

    it 'record_a printed' do
      expect { subject }.to output(/#{record_a.values.join('\t')}/).to_stdout
    end

    it 'record_b printed' do
      expect { subject }.to output(/#{record_b.values.join('\t')}/).to_stdout
    end
  end
end
