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
      service_obj = { 'name' => service_name }

      ThreeScaleToolbox::Entities::Service.create(
        remote: client, service: service_obj, system_name: system_name
      )
    end

    def create_methods
      hits_id = service.hits['id']
      3.times.each do
        method = { 'system_name' => Helpers.random_lowercase_name,
                   'friendly_name' => Helpers.random_lowercase_name }
        service.create_method(hits_id, method)
      end
    end

    def create_metrics
      4.times.each do
        name = Helpers.random_lowercase_name
        metric = { 'name' => name, 'system_name' => name, 'unit' => '1' }
        service.create_metric(metric)
      end
    end

    def create_application_plans
      Array.new(2) do
        name = Helpers.random_lowercase_name
        application_plan = {
          'name' => name, 'state' => 'published', 'default' => false,
          'custom' => false, 'system_name' => name
        }
        service.create_application_plan(application_plan)
      end
    end

    def create_application_plan_limits(plans)
      hits_id = service.hits['id']
      plans.each do |plan|
        # limits (only limits for hits metric)
        %w[day week month year].each do |period|
          limit = { 'period' => period, 'value' => 10_000 }
          service.create_application_plan_limit(plan.fetch('id'), hits_id, limit)
        end
      end
    end

    def create_mapping_rules
      hits_id = service.hits['id']
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
      hits_id = service.hits['id']
      plans.each do |plan|
        pricing_rule = { 'cost_per_unit' => '2.0', 'min' => 102, 'max' => 200 }
        service.remote.create_pricingrule(plan.fetch('id'), hits_id, pricing_rule)
      end
    end
  end
end
