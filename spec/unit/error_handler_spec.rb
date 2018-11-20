require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::CLI::ErrorHandler do
  include_context :temp_dir

  context '#error_watchdog' do
    def raise_runtime_error
      raise 'some error'
    end

    def raise_toolbox_error
      raise ThreeScaleToolbox::Error, 'some error'
    end

    context 'raises expected error' do
      it 'error is shown on stderr' do
        Dir.chdir(tmp_dir) do
          expect do
            subject.error_watchdog { raise_toolbox_error }
          end.to output(/some error/).to_stderr
          expect(File).not_to exist('crash.log')
        end
      end

      it 'returns true' do
        expect(
          subject.error_watchdog { raise_toolbox_error }
        ).to be_truthy
      end
    end

    context 'raises unexpected error' do
      it 'crash.log is generated' do
        Dir.chdir(tmp_dir) do
          expect do
            subject.error_watchdog { raise_runtime_error }
          end.to output(/some error/).to_stderr
          expect(File).to exist('crash.log')
        end
      end

      it 'returns true' do
        expect(
          subject.error_watchdog { raise_runtime_error }
        ).to be_truthy
      end
    end

    context 'Does not raise error' do
      it 'returns true' do
        expect(subject.error_watchdog {}).to be_falsey
      end
    end
  end
end
