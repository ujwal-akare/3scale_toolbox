module ThreeScaleToolbox
  module Commands
    module PlansCommand
      module Import
        class ImportPlanFeaturesStep
          include Step
          ##
          # Writes Plan features
          def call
            missing_features.each do |feature|
              create_plan_feature(feature)
              puts "Created plan feature: #{feature}"
            end
          end

          private

          def missing_features
            ThreeScaleToolbox::Helper.array_difference(resource_features, plan.features) do |a, b|
              ThreeScaleToolbox::Helper.compare_hashes(a, b, ['system_name'])
            end
          end

          def create_plan_feature(feature_attrs)
            feature = find_feature_by_system_name(feature_attrs['system_name']) || create_service_feature(feature_attrs)

            plan.create_feature(feature['id']).tap do |resp|
              if (errors = resp['errors'])
                raise ThreeScaleToolbox::Error, "Plan feature has not been created. #{errors}"
              end
            end
          end

          def create_service_feature(feature_attrs)
            service.create_feature(feature_attrs).tap do |resp|
              if (errors = resp['errors'])
                raise ThreeScaleToolbox::Error, "Service feature has not been created. #{errors}"
              end
            end
          end
        end
      end
    end
  end
end
