module ThreeScaleToolbox
  class RemoteCache < BasicObject

    attr_reader :metrics_cache, :methods_cache, :subject

    def initialize(subject)
      @subject = subject
      # Metrics and methods cache data
      # Methods cache data
      @metrics_cache = {}
      @methods_cache = {}
    end

    def list_metrics(service_id)
      return metrics_cache[service_id] if metrics_cache.has_key? service_id

      subject.list_metrics(service_id).tap do |metrics|
        metrics_cache[service_id] = metrics unless metrics.respond_to?(:has_key?) && !metrics['errors'].nil?
      end
    end

    def list_methods(service_id, metric_id)
      key = method_cache_key(service_id, metric_id)
      return methods_cache[key] if methods_cache.has_key? key

      subject.list_methods(service_id, metric_id).tap do |methods|
        methods_cache[key] = methods unless methods.respond_to?(:has_key?) && !methods['errors'].nil?
      end
    end

    def create_metric(service_id, attributes)
      subject.create_metric(service_id, attributes).tap do |_|
        metrics_cache.delete(service_id)
      end
    end

    def update_metric(service_id, metric_id, attributes)
      subject.update_metric(service_id, metric_id, attributes).tap do |_|
        metrics_cache.delete(service_id)
      end
    end

    def delete_metric(service_id, metric_id)
      subject.delete_metric(service_id, metric_id).tap do |_|
        metrics_cache.delete(service_id)
      end
    end

    def update_method(service_id, parent_id, id, attributes)
      subject.update_method(service_id, parent_id, id, attributes).tap do |_|
        metrics_cache.delete(service_id)
        methods_cache.delete(method_cache_key(service_id, parent_id))
      end
    end


    def create_method(service_id, metric_id, attributes)
      subject.create_method(service_id, metric_id, attributes).tap do |_|
        metrics_cache.delete(service_id)
        methods_cache.delete(method_cache_key(service_id, metric_id))
      end
    end

    def delete_method(service_id, parent_id, id)
      subject.delete_method(service_id, parent_id, id).tap do |_|
        metrics_cache.delete(service_id)
        methods_cache.delete(method_cache_key(service_id, parent_id))
      end
    end

    def method_missing(name, *args)
      subject.public_send(name, *args)
    end

    def respond_to_missing?(method_name, include_private = false)
      super
    end

    private

    def method_cache_key(service_id, metric_id)
      "#{service_id}#{metric_id}"
    end
  end
end
