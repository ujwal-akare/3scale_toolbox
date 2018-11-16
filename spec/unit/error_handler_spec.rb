require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::CLI::ErrorHandler do
  include_context :temp_dir

  let(:exit_on_error) { false }
  context '#run' do
    context 'exit_on_error: true' do
      let(:exit_on_error) { true }
      it 'raises SystemExit' do
        expect do
          subject.error_watchdog(exit_on_error: exit_on_error) do
            raise ThreeScaleToolbox::Error, 'some error'
          end
        end.to output(/some error/).to_stderr.and raise_error(SystemExit)
      end
    end

    context 'exit_on_error: false' do
      it 'does not raise SystemExit' do
        expect do
          subject.error_watchdog(exit_on_error: exit_on_error) do
            raise ThreeScaleToolbox::Error, 'some error'
          end
        end.to output(/some error/).to_stderr
      end
    end

    context 'raises expected error' do
      it 'error is shown on stderr' do
        expect do
          subject.error_watchdog(exit_on_error: exit_on_error) do
            raise ThreeScaleToolbox::Error, 'some error'
          end
        end.to output(/some error/).to_stderr
        expect(File).not_to exist('crash.log')
      end
    end

    context 'raises unexpected error' do
      it 'crash.log is generated' do
        Dir.chdir(tmp_dir) do
          expect do
            subject.error_watchdog(exit_on_error: exit_on_error) do
              raise 'some error'
            end
          end.to output(/some error/).to_stderr
          expect(File).to exist('crash.log')
        end
      end
    end
  end
end
