RSpec.describe ThreeScaleToolbox::Commands::ActiveDocsCommand::Apply::ApplySubcommand do
  let(:activedocs_class) { class_double(ThreeScaleToolbox::Entities::ActiveDocs).as_stubbed_const }
  let(:activedocs) { instance_double(ThreeScaleToolbox::Entities::ActiveDocs) }
  let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
  let(:remote_name) { "myremote" }
  let(:default_options) { { publish: false, hide: false } }
  let(:options) { default_options }
  let(:activedocs_ref) { "activedocsref" }
  let(:activedocs_id) { "1" }
  let(:activedocs_attrs) { { 'id' => activedocs_id, "name" => activedocs_ref, "system_name" => activedocs_ref, "body" => activedocs_body_pretty_json } }
  let(:activedocs_body_str) do
    <<~YAML
      ---
      value1: "content1"
    YAML
  end
  let(:activedocs_body_pretty_json) do
    activedocs_body_content = YAML.safe_load(activedocs_body_str)
    JSON.pretty_generate(activedocs_body_content)
  end
  let(:arguments) do
    {
      remote: remote_name,
      activedocs_id_or_system_name: activedocs_ref,
    }
  end

  subject { described_class.new(options, arguments, nil) }

  before :example do
    allow(activedocs).to receive(:attrs).and_return(activedocs_attrs)
    allow(subject).to receive(:threescale_client).with(remote_name).and_return(remote)
  end

  context '#run' do
    context 'when --publish and --hide set' do
      let(:options) { default_options.merge(publish: true, hide: true) }
      it 'error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error, /mutually exclusive/)
      end
    end

    context 'when activedocs does not exist and --openapi-spec is not provided' do
      before :example do
        expect(activedocs_class).to receive(:find).with(remote: remote, ref: activedocs_ref).and_return(nil)
      end

      it 'an error is raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error, /mandatory/)
      end
    end

    context 'valid params' do
      let(:general_options) { default_options.merge(:'openapi-spec' => "-") }

      context 'when activedocs not found' do
        let(:create_attrs) do
          {
            'name' => activedocs_ref,
            'system_name' => activedocs_ref,
            'body' => activedocs_body_pretty_json
          }
        end
        let(:options) { general_options }
        before :example do
          expect(activedocs_class).to receive(:find).with(remote: remote, ref: activedocs_ref).and_return(nil)
          expect(STDIN).to receive(:read).and_return(activedocs_body_str)
        end

        shared_examples 'activedocs created' do
          it do
            expect(activedocs_class).to receive(:create).with(remote: remote, attrs: create_attrs).and_return(activedocs)
            expect { subject.run }.to output(/Applied ActiveDocs id: #{activedocs_id}/).to_stdout
          end
        end

        include_examples 'activedocs created'

        context 'when name in options' do
          let(:options) { general_options.merge(name: 'new name') }
          let(:create_attrs) { { "name" => options[:name], "system_name" => activedocs_ref, "body" => activedocs_body_pretty_json } }
          include_examples 'activedocs created'
        end

        context 'when service-id in options' do
          let(:options) { general_options.merge(:'service-id' => '7') }
          let(:create_attrs) { { "service_id" => options[:'service-id'], "name" => activedocs_ref, "system_name" => activedocs_ref, "body" => activedocs_body_pretty_json } }
          include_examples 'activedocs created'
        end
      end

      context 'when activedocs found' do
        before :example do
          expect(activedocs_class).to receive(:find).with(remote: remote, ref: activedocs_ref).and_return(activedocs)
        end

        context 'with default options' do
          it 'activedocs not updated' do
            expect { subject.run }.to output(/Applied ActiveDocs id: #{activedocs_id}/).to_stdout
          end
        end

        context 'with options' do
          let(:options) { default_options.merge(name: 'some name', description: 'some descr', :'skip-swagger-validations' => true, :'service-id' => "5") }
          let(:update_attrs) do
            {
              'name' => options[:name],
              'description' => options[:description],
              'skip_swagger_validations' => options[:'skip-swagger-validations'],
              'service_id' => options[:'service-id'],
            }
          end

          it 'activedocs updated' do
            expect(activedocs).to receive(:update).with(update_attrs)
            expect { subject.run }.to output(/Applied ActiveDocs id: #{activedocs_id}/).to_stdout
          end
        end

        context 'with publish option' do
          let(:options) { default_options.merge(publish: true) }
          let(:activedocs_attrs) { { "published" => true } }

          it 'activedocs published' do
            expect(activedocs).to receive(:update).with(activedocs_attrs)
            expect { subject.run }.to output(/Published/).to_stdout
          end
        end

        context 'with hide option' do
          let(:options) { default_options.merge(hide: true) }
          let(:activedocs_attrs) { { "published" => false } }

          it 'activedocs hidden' do
            expect(activedocs).to receive(:update).with(activedocs_attrs)
            expect { subject.run }.to output(/Hidden/).to_stdout
          end
        end
      end
    end
  end
end
