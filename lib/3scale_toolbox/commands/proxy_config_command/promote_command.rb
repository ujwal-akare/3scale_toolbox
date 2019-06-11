module ThreeScaleToolbox
  module Commands
    module ProxyConfigCommand
      module Promote
        class PromoteSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'promote'
              usage       'promote <remote> <service>'
              summary     'Promote latest staging Proxy Configuration to the production environment'
              description 'Promote latest staging Proxy Configuration to the production environment'
              runner PromoteSubcommand

              param   :remote
              param   :service_ref
            end
          end

          def run
            latest_proxy_config.promote(to: to_env)
            puts "Proxy Configuration promoted to '#{to_env}'"
          end

          private

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def latest_proxy_config
            @proxy_config ||= find_proxy_config_latest
          end

          def find_proxy_config_latest
            Entities::ProxyConfig.find_latest(service: service, environment: from_env).tap do |pc|
              raise ThreeScaleToolbox::Error, "ProxyConfig #{from_env} in service #{service.id} does not exist" if pc.nil?
            end
          end

          def service_ref
            arguments[:service_ref]
          end

          def find_service
            Entities::Service.find(remote: remote,
                                   ref: service_ref).tap do |svc|
              raise ThreeScaleToolbox::Error, "Service #{service_ref} does not exist" if svc.nil?
            end
          end

          def service
            @service ||= find_service
          end

          def to_env
            "production"
          end

          def from_env
            "sandbox"
          end
        end
      end
    end
  end
end