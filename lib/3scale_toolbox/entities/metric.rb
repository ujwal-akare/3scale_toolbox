module ThreeScaleToolbox
  module Entities
    class Metric
      include CRD::Metric

      class << self
        def create(service:, attrs:)
          metric = service.remote.create_metric service.id, attrs
          if (errors = metric['errors'])
            raise ThreeScaleToolbox::ThreeScaleApiError.new('Metric has not been created', errors)
          end

          new(id: metric.fetch('id'), service: service, attrs: metric)
        end

        # ref can be system_name or metric_id
        def find(service:, ref:)
          new(id: ref, service: service).tap(&:attrs)
        rescue ThreeScale::API::HttpClient::NotFoundError
          find_by_system_name(service: service, system_name: ref)
        end

        def find_by_system_name(service:, system_name:)
          service.metrics.find { |m| m.system_name == system_name }
        end
      end

      attr_reader :id, :service, :remote

      def initialize(id:, service:, attrs: nil)
        @id = id.to_i
        @service = service
        @remote = service.remote
        @attrs = attrs
      end

      def attrs
        @attrs ||= metric_attrs
      end

      def system_name
        attrs['system_name']
      end

      def friendly_name
        attrs['friendly_name']
      end

      def unit
        attrs['unit']
      end

      def description
        attrs['description']
      end

      def disable
        # For each plan, get limits for the current metric
        # if already disabled -> NOOP
        # if non zero eternity limit exist, update
        # if non eternity limit exist, create
        service.plans.each do |plan|
          eternity_limit = plan_eternity_limit(plan)
          if eternity_limit.nil?
            plan.create_limit(id, zero_eternity_limit_attrs)
          elsif !eternity_limit.value.zero?
            eternity_limit.update(zero_eternity_limit_attrs)
          end
        end
      end

      def enable
        service.plans.each do |plan|
          limit = plan_zero_eternity_limit(plan)
          limit.delete unless limit.nil?
        end
      end

      def update(new_metric_attrs)
        new_attrs = remote.update_metric(service.id, id, new_metric_attrs)
        if (errors = new_attrs['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Metric has not been updated', errors)
        end

        # update current attrs
        @attrs = new_attrs

        new_attrs
      end

      def delete
        remote.delete_metric service.id, id
      end

      private

      def metric_attrs
        metric = remote.show_metric service.id, id
        if (errors = metric['errors'])
          raise ThreeScaleToolbox::ThreeScaleApiError.new('Metric attrs not read', errors)
        end

        metric
      end

      def plan_zero_eternity_limit(plan)
        # only one limit for eternity period is allowed per (plan_id, metric_id)
        #plan.metric_limits(id).find { |limit| limit.attrs > zero_eternity_limit_attrs }
        plan.metric_limits(id).find do |limit|
          limit.attrs > zero_eternity_limit_attrs
        end
      end

      def plan_eternity_limit(plan)
        # only one limit for eternity period is allowed per (plan_id, metric_id)
        plan.metric_limits(id).find { |limit| limit.period == 'eternity' }
      end

      def zero_eternity_limit_attrs
        { 'period' => 'eternity', 'value' => 0 }
      end
    end
  end
end
