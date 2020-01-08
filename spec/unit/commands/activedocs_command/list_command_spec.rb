require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Commands::ActiveDocsCommand::List::ListSubcommand do
  context '#run' do
    let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
    let(:remote_name) { "myremote" }

    let(:options) { {} }
    let(:arguments) { { remote: remote_name } }

    subject { described_class.new(options, arguments, nil) }

    before :example do
      expect(subject).to receive(:threescale_client).with(remote_name).and_return(remote)
    end

    it 'when no activedocs are present the result header is printed' do
      expect(remote).to receive(:list_activedocs).and_return([])
      expect { subject.run }.to output(/.*ID\tNAME\tSYSTEM_NAME.*/).to_stdout
    end

    context 'when activedocs list is returned' do
      let(:activedocs_1) { { "id" => 1, "name" => "name1", "system_name" => "sysname1" } }
      let(:activedocs_2) { { "id" => 2, "name" => "name2", "system_name" => "sysname2" } }
      let(:activedocs_3) { { "id" => 3, "name" => "name3", "system_name" => "sysname3" } }
      let(:activedocs_arr) { [activedocs_1, activedocs_2, activedocs_3] }
      before :example do
        expect(remote).to receive(:list_activedocs).and_return(activedocs_arr)
      end

      it "shows activedoc_1" do
        expect { subject.run }.to output(/sysname1/).to_stdout
      end

      it "shows activedoc_2" do
        expect { subject.run }.to output(/sysname2/).to_stdout
      end

      it "shows non defined fields as (empty)" do
        expect { subject.run }.to output(/\(empty\)/).to_stdout
      end

      context 'when list is filtered by service ref' do
        let(:service_ref_filter_class) { class_double(ThreeScaleToolbox::AttributeFilters::ServiceIDFilterFromServiceRef).as_stubbed_const }
        let(:service_ref_filter) { instance_double(ThreeScaleToolbox::AttributeFilters::ServiceIDFilterFromServiceRef, 'serviceRefFilter') }

        context 'when service exists' do
          let(:options) { {:'service-ref' => "name1"}}

          before :example do
            expect(service_ref_filter_class). to receive(:new).with(remote, options[:'service-ref'], "service_id").and_return(service_ref_filter)
            expect(service_ref_filter).to receive(:filter).with(activedocs_arr).and_return([activedocs_1])
          end

          it "only shows the filtered result" do
            expect { subject.run }.to output(/sysname1/).to_stdout
          end
        end
        context 'when service does not exist' do
          let(:options) { {:'service-ref' => "name4"}}

          before :example do
            expect(service_ref_filter_class). to receive(:new).with(remote, options[:'service-ref'], "service_id").and_return(service_ref_filter)
            expect(service_ref_filter).to receive(:filter).with(activedocs_arr).and_return([])
          end

          it "only the result header is printed" do
            expect { subject.run }.to output(/.*ID\tNAME\tSYSTEM_NAME.*/).to_stdout
          end
        end
      end
    end
  end
end