module ThreeScaleToolbox
  class ThreeScaleClientFactory
    class << self
      def get(remotes, remote_str, verify_ssl, verbose = false)
        new(remotes, remote_str, verify_ssl, verbose).call
      end
    end

    attr_reader :remotes, :remote_str, :verify_ssl, :verbose

    def initialize(remotes, remote_str, verify_ssl, verbose)
      @remotes = remotes
      @remote_str = remote_str
      @verify_ssl = verify_ssl
      @verbose = verbose
    end

    def call
      begin
        remote = Remotes.from_uri(remote_str)
      rescue InvalidUrlError
        remote = remotes.fetch(remote_str)
      end

      client = remote_client(remote.merge(verify_ssl: verify_ssl))
      return ProxyLogger.new(client) if verbose

      client
    end

    private

    def remote_client(endpoint:, authentication:, verify_ssl:)
      ThreeScale::API.new(endpoint: endpoint, provider_key: authentication, verify_ssl: verify_ssl)
    end
  end
end
