module ThreeScaleToolbox
  module Commands
    module ServiceCommand
      module CopyCommand
        class CopyMetricsTask
          include Task

          def call
            logger.info "original service has #{source.metrics.size} metrics"
            logger.info "target service has #{target.metrics.size} metrics"
            missing_metrics.each(&method(:create_metric))
            logger.info "created #{missing_metrics.size} metrics on the target service"
            report['missing_metrics_created'] = missing_metrics.size
          end

          private

          def create_metric(metric)
            new_metric = metric.attrs.reject { |key, _| %w[id links].include? key }
            Entities::Metric.create(service: target, attrs: new_metric)
          rescue ThreeScaleToolbox::ThreeScaleApiError => e
            raise e unless ThreeScaleToolbox::Helper.system_name_already_taken_error?(e.apierrors)

            warn "[WARN] metric #{metric.system_name} not created. " \
              'Method with the same system_name exists.'
          end

          def missing_metrics
            @missing_metrics ||= ThreeScaleToolbox::Helper.array_difference(source.metrics, target.metrics) do |s_m, t_m|
              s_m.system_name == t_m.system_name
            end
          end
        end
      end
    end
  end
end
