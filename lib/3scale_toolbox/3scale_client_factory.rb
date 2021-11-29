module ThreeScaleToolbox
  class ThreeScaleClientFactory
    class << self
      def get(remotes, remote_str, verify_ssl, verbose = false, keep_alive = true)
        new(remotes, remote_str, verify_ssl, verbose, keep_alive).call
      end
    end

    attr_reader :remotes, :remote_str, :verify_ssl, :verbose, :keep_alive

    def initialize(remotes, remote_str, verify_ssl, verbose, keep_alive)
      @remotes = remotes
      @remote_str = remote_str
      @verify_ssl = verify_ssl
      @verbose = verbose
      @keep_alive = keep_alive
    end

    def call
      begin
        remote = Remotes.from_uri(remote_str)
      rescue InvalidUrlError
        remote = remotes.fetch(remote_str)
      end

      client = remote_client(**remote.merge(verify_ssl: verify_ssl, keep_alive: keep_alive))
      client = ProxyLogger.new(client) if verbose
      RemoteCache.new(client)
    end

    private

    def remote_client(endpoint:, authentication:, verify_ssl:, keep_alive:)
      ThreeScale::API.new(endpoint: endpoint, provider_key: authentication,
                          verify_ssl: verify_ssl, keep_alive: keep_alive)
    end
  end
end
