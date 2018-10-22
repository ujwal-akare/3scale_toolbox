require '3scale_toolbox/cli'

RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::ImportCsvSubcommand do
  context '#run' do
    it 'with insecure flag' do
      expect(described_class).to receive(:import_csv).with('destination_id',
                                                           'file_path_id',
                                                           true)
      opts = {
        destination: 'destination_id',
        file: 'file_path_id',
        insecure: true
      }
      described_class.run(opts, nil)
    end

    it 'without insecure flag' do
      expect(described_class).to receive(:import_csv).with('destination_id',
                                                           'file_path_id',
                                                           false)
      opts = {
        destination: 'destination_id',
        file: 'file_path_id'
      }
      described_class.run(opts, nil)
    end
  end
end
