module ThreeScaleToolbox
  module Commands
    module ProductCommand
      class SerializeStep
        include Step

        def call
          select_output do |output|
            output.write(serialized_object.to_yaml)
          end
        end

        private

        def select_output
          ios = if file
                  File.open(file, 'w')
                else
                  $stdout
                end
          begin
            yield(ios)
          ensure
            ios.close
          end
        end

        def serialized_object
          {
            'created_at' => Time.now.utc.iso8601,
            'toolbox_version' => ThreeScaleToolbox::VERSION
          }
        end
      end
    end
  end
end
