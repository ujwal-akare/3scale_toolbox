module ThreeScaleToolbox
  class ThreeScaleClientFactory
    class << self
      def get(remotes, remote_str, verify_ssl)
        new(remotes, remote_str, verify_ssl).call
      end
    end

    attr_reader :remotes, :remote_str, :verify_ssl

    def initialize(remotes, remote_str, verify_ssl)
      @remotes = remotes
      @remote_str = remote_str
      @verify_ssl = verify_ssl
    end

    def call
      begin
        remote = Remotes.from_uri(remote_str)
      rescue InvalidUrlError
        remote = remotes.fetch(remote_str)
      end

      remote_client(remote.merge(verify_ssl: verify_ssl))
    end

    private

    def remote_client(endpoint:, auth_key:, verify_ssl:)
      ThreeScale::API.new(endpoint: endpoint, provider_key: auth_key, verify_ssl: verify_ssl)
    end
  end
end
