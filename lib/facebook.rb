module OAuth2
  module Clients
    class Facebook < Client
      def initialize(client_id, client_secret, opts = {})
        opts[:site] = 'https://graph.facebook.com/'
        super(client_id, client_secret, opts)
      end
    end
  end
end
