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
            if promotable?
              latest_proxy_config_from.promote(to: to_env)
              puts "Proxy Configuration version #{latest_proxy_config_from.version} promoted to '#{to_env}'"
            else
              warn "warning: Nothing to promote. Proxy Configuration version #{latest_proxy_config_from.version} already promoted to production"
            end
          end

          private

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def latest_proxy_config_from
            @proxy_config_from ||= find_proxy_config_latest_from
          end

          def latest_proxy_config_to
            @proxy_config_to ||= find_proxy_config_latest_to
          end

          def promotable?
            return latest_proxy_config_to.nil? || latest_proxy_config_from.version != latest_proxy_config_to.version
          end

          def find_proxy_config_latest_from
            Entities::ProxyConfig.find_latest(service: service, environment: from_env).tap do |pc|
              raise ThreeScaleToolbox::Error, "ProxyConfig #{from_env} in service #{service.id} does not exist" if pc.nil?
            end
          end

          def find_proxy_config_latest_to
            Entities::ProxyConfig.find_latest(service: service, environment: to_env)
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