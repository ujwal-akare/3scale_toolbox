module ThreeScaleToolbox
  class RemoteCache < BasicObject

    attr_reader :metrics_cache, :methods_cache, :backend_metrics_cache, :backend_methods_cache, :subject

    def initialize(subject)
      @subject = subject
      # Metrics and methods cache data
      @metrics_cache = {}
      # methods cache data
      @methods_cache = {}
      # Backend Metrics and methods cache data
      @backend_metrics_cache = {}
      # Backend methods cache data
      @backend_methods_cache = {}
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
      subject.create_metric(service_id, attributes).tap do |metric_attrs|
        metrics_cache.delete(service_id) unless metric_attrs.respond_to?(:has_key?) && !metric_attrs['errors'].nil?
      end
    end

    def update_metric(service_id, metric_id, attributes)
      subject.update_metric(service_id, metric_id, attributes).tap do |metric_attrs|
        metrics_cache.delete(service_id) unless metric_attrs.respond_to?(:has_key?) && !metric_attrs['errors'].nil?
      end
    end

    def delete_metric(service_id, metric_id)
      subject.delete_metric(service_id, metric_id).tap do |_|
        metrics_cache.delete(service_id)
      end
    end

    def update_method(service_id, parent_id, id, attributes)
      subject.update_method(service_id, parent_id, id, attributes).tap do |method_attrs|
        metrics_cache.delete(service_id) unless method_attrs.respond_to?(:has_key?) && !method_attrs['errors'].nil?
        methods_cache.delete(method_cache_key(service_id, parent_id)) unless method_attrs.respond_to?(:has_key?) && !method_attrs['errors'].nil?
      end
    end


    def create_method(service_id, metric_id, attributes)
      subject.create_method(service_id, metric_id, attributes).tap do |method_attrs|
        metrics_cache.delete(service_id) unless method_attrs.respond_to?(:has_key?) && !method_attrs['errors'].nil?
        methods_cache.delete(method_cache_key(service_id, metric_id)) unless method_attrs.respond_to?(:has_key?) && !method_attrs['errors'].nil?
      end
    end

    def delete_method(service_id, parent_id, id)
      subject.delete_method(service_id, parent_id, id).tap do |_|
        metrics_cache.delete(service_id)
        methods_cache.delete(method_cache_key(service_id, parent_id))
      end
    end

    ###
    # Backends
    ###

    def list_backend_metrics(backend_id)
      return backend_metrics_cache[backend_id] if backend_metrics_cache.has_key? backend_id

      subject.list_backend_metrics(backend_id).tap do |metrics|
        backend_metrics_cache[backend_id] = metrics unless metrics.respond_to?(:has_key?) && !metrics['errors'].nil?
      end
    end

    def list_backend_methods(backend_id, metric_id)
      key = method_cache_key(backend_id, metric_id)
      return backend_methods_cache[key] if backend_methods_cache.has_key? key

      subject.list_backend_methods(backend_id, metric_id).tap do |methods|
        backend_methods_cache[key] = methods unless methods.respond_to?(:has_key?) && !methods['errors'].nil?
      end
    end

    def create_backend_metric(backend_id, attributes)
      subject.create_backend_metric(backend_id, attributes).tap do |metric_attrs|
        backend_metrics_cache.delete(backend_id) unless metric_attrs.respond_to?(:has_key?) && !metric_attrs['errors'].nil?
      end
    end

    def update_backend_metric(backend_id, metric_id, attributes)
      subject.update_backend_metric(backend_id, metric_id, attributes).tap do |metric_attrs|
        backend_metrics_cache.delete(backend_id) unless metric_attrs.respond_to?(:has_key?) && !metric_attrs['errors'].nil?
      end
    end

    def delete_backend_metric(backend_id, metric_id)
      subject.delete_backend_metric(backend_id, metric_id).tap do |_|
        backend_metrics_cache.delete(backend_id)
      end
    end

    def create_backend_method(backend_id, metric_id, attributes)
      subject.create_backend_method(backend_id, metric_id, attributes).tap do |method_attrs|
        unless method_attrs.respond_to?(:has_key?) && !method_attrs['errors'].nil?
          backend_metrics_cache.delete(backend_id)
          backend_methods_cache.delete(method_cache_key(backend_id, metric_id))
        end
      end
    end

    def delete_backend_method(backend_id, metric_id, method_id)
      subject.delete_backend_method(backend_id, metric_id, method_id).tap do |_|
        backend_metrics_cache.delete(backend_id)
        backend_methods_cache.delete(method_cache_key(backend_id, metric_id))
      end
    end

    def update_backend_method(backend_id, metric_id, method_id, attributes)
      subject.update_backend_method(backend_id, metric_id, method_id, attributes).tap do |method_attrs|
        unless method_attrs.respond_to?(:has_key?) && !method_attrs['errors'].nil?
          backend_metrics_cache.delete(backend_id)
          backend_methods_cache.delete(method_cache_key(backend_id, metric_id))
        end
      end
    end

    ###
    # Generic methods
    ###

    def method_missing(name, *args)
      # Correct delegation https://eregon.me/blog/2021/02/13/correct-delegation-in-ruby-2-27-3.html
      @subject.public_send(name, *args)
    end
    ruby2_keywords :method_missing if respond_to?(:ruby2_keywords, true)

    def public_send(name, *args)
      method_missing(name, *args)
    end

    def respond_to_missing?(method_name, include_private = false)
      super
    end

    private

    def method_cache_key(id, metric_id)
      "#{id}#{metric_id}"
    end
  end
end
