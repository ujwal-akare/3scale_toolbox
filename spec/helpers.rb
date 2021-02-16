module Helpers
  def self.random_lowercase_name
    [*('a'..'z')].sample(8).join
  end

  class ServiceFactory
    private_class_method :new
    attr_reader :service

    def self.new_service(client)
      new(client).service
    end

    private

    def initialize(client)
      @service = create_service(client)
      create_methods
      create_metrics
      plans = create_application_plans
      create_application_plan_limits(plans)
      create_mapping_rules
      update_proxy_policies
      create_pricing_rules(plans)
      create_activedocs
    end

    def create_service(client)
      service_name = "API_TEST_#{Helpers.random_lowercase_name}_#{Time.now.getutc.to_i}"
      system_name = service_name.delete("\s").downcase
      service_obj = {
        'name' => service_name,
        'system_name' => system_name,
      }

      ThreeScaleToolbox::Entities::Service.create(
        remote: client, service_params: service_obj
      )
    end

    def create_methods
      3.times.each do
        method = { 'system_name' => Helpers.random_lowercase_name,
                   'friendly_name' => Helpers.random_lowercase_name }
        ThreeScaleToolbox::Entities::Method.create(service: service, attrs: method)
      end
    end

    def create_metrics
      4.times.each do
        name = Helpers.random_lowercase_name
        metric = { 'friendly_name' => name, 'system_name' => name, 'unit' => '1' }
        ThreeScaleToolbox::Entities::Metric.create(service: service, attrs: metric)
      end
    end

    def create_application_plans
      Array.new(2) do
        name = Helpers.random_lowercase_name
        application_plan = {
          'name' => name, 'state' => 'published', 'default' => false,
          'custom' => false, 'system_name' => name
        }
        ThreeScaleToolbox::Entities::ApplicationPlan.create(service: service,
                                                            plan_attrs: application_plan)
      end
    end

    def create_application_plan_limits(plans)
      hits_id = service.hits.id
      plans.each do |plan|
        # limits (only limits for hits metric)
        %w[day week month year].each do |period|
          limit = { 'period' => period, 'value' => 10_000 }
          plan.create_limit(hits_id, limit)
        end
      end
    end

    def create_mapping_rules
      hits_id = service.hits.id
      # mapping rules (only mapping rules for hits metric)
      2.times.each do |idx|
        mapping_rule = {
          'metric_id' => hits_id, 'pattern' => "/rule#{idx}",
          'http_method' => 'GET',
          'delta' => 1
        }

        service.create_mapping_rule(mapping_rule)
      end
    end

    def create_activedocs
      active_docs = {
        name: 'myActiveDocs',
        system_name: "myActiveDocs#{service.id.to_i}",
        service_id: service.id.to_i,
        body: activedocs_sample.to_json,
        description: 'some description'
      }

      res = service.remote.create_activedocs(active_docs)
      raise ThreeScaleToolbox::Error, "ActiveDocs has not been created. Errors: #{res['errors']}" unless res['errors'].nil?
    end

    def activedocs_sample
      {
        'basePath': 'https://hello-world-api.3scale.net',
        'apiVersion': 'v1',
        'apis': [
          {
            'path': '/',
            'operations': [
              {
                'httpMethod': 'GET',
                'summary': 'Say Hello!',
                'description': '<p>This operation says hello.</p>',
                'group': 'words',
                'parameters': [
                  {
                    'name': 'user_key',
                    'description': 'Your API access key',
                    'dataType': 'string',
                    'paramType': 'query',
                    'threescale_name': 'user_keys'
                  }
                ]
              }
            ]
          }
        ]
      }
    end

    def update_proxy_policies
      policies_config = [
        {
          'name' => 'apicast',
          'version' => 'builtin',
          'configuration' => {},
          'enabled' => true
        },
        {
          'name' => 'soap',
          'version' => 'builtin',
          'configuration' => {},
          'enabled' => true
        },
        {
          'name' => 'url_rewriting',
          'version' => 'builtin',
          'configuration' => {},
          'enabled' => true
        },
        {
          'name' => 'ip_check',
          'version' => 'builtin',
          'configuration' => {},
          'enabled' => true
        }
      ]

      service.update_policies('policies_config' => policies_config)
    end

    def create_pricing_rules(plans)
      hits_id = service.hits.id
      plans.each do |plan|
        pricing_rule = { 'cost_per_unit' => '2.0', 'min' => 102, 'max' => 200 }
        plan.create_pricing_rule(hits_id, pricing_rule)
      end
    end
  end

  # wait tries a block of code until it returns true, or the timeout is reached.
  # timeout give an upper limit to the amount of time this method will run
  # Some intervals may be missed if the block takes too long or the time window is too short.
  def self.wait(interval = 0.5, timeout = 30)
    raise 'wait expects block' unless block_given?

    end_time = Time.now + timeout
    until Time.now > end_time
      result = yield
      return if result == true

      sleep interval
    end

    raise "timed out after #{timeout} seconds"
  end

  class BackendFactory
    private_class_method :new
    attr_reader :backend

    def self.new_backend(client)
      new(client).backend
    end

    private

    def initialize(client)
      @backend = create_backend(client)
      create_metrics
      create_methods
      create_mapping_rules
    end

    def create_backend(client)
      attrs = {
        'name' => "API_TEST_#{Helpers.random_lowercase_name}_#{Time.now.getutc.to_i}",
        'private_endpoint' => "https://#{Helpers.random_lowercase_name}.example.com"
      }

      ThreeScaleToolbox::Entities::Backend.create(remote: client, attrs: attrs)
    end

    def create_methods
      hits_id = backend.hits.id
      2.times.each do
        method = { 'system_name' => Helpers.random_lowercase_name,
                   'friendly_name' => Helpers.random_lowercase_name }
        ThreeScaleToolbox::Entities::BackendMethod.create(backend: backend, attrs: method)
      end
    end

    def create_metrics
      2.times.each do
        name = Helpers.random_lowercase_name
        metric = { 'friendly_name' => name, 'system_name' => name, 'unit' => '1' }
        ThreeScaleToolbox::Entities::BackendMetric.create(backend: backend, attrs: metric)
      end
    end

    def create_mapping_rules
      hits_id = backend.hits.id
      # mapping rules (only mapping rules for hits metric)
      2.times.each do |idx|
        attrs = {
          'metric_id' => hits_id, 'pattern' => "/rule#{idx}",
          'http_method' => 'GET',
          'delta' => 1
        }

        ThreeScaleToolbox::Entities::BackendMappingRule.create(backend: backend, attrs: attrs)
      end
    end
  end
end
