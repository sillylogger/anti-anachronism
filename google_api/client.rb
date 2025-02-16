require 'googleauth'
require 'googleauth/stores/file_token_store'

module GoogleAPI
  class Client

    attr_accessor :authorizer, :credentials 

    CONFIG = {
      credentials_path: 'credentials.json',
      user_id: 'default',

      read: {
        token_path: 'token-read.yaml',
        scope: 'https://www.googleapis.com/auth/photoslibrary'
        # scope: 'https://www.googleapis.com/auth/photoslibrary.readonly'
      },
      write: {
        token_path: 'token-write.yaml',
        scope: 'https://www.googleapis.com/auth/photoslibrary.edit.appcreateddata'
      }
    }

    def initialize mode = :read
      if !File.exist?(CONFIG.fetch(:credentials_path))
        raise "I am missing credentials.json"
      end

      client_id = Google::Auth::ClientId.from_file CONFIG.fetch(:credentials_path)
      token_store = Google::Auth::Stores::FileTokenStore.new file: CONFIG[mode].fetch(:token_path)
      @authorizer = Google::Auth::UserAuthorizer.new client_id, CONFIG[mode].fetch(:scope), token_store
      @credentials = @authorizer.get_credentials CONFIG.fetch(:user_id)
    end


    def access_token
      @credentials.access_token
    end

    def authorize!
      if !@credentials.nil?
        return
      end

      url = @authorizer.get_authorization_url(base_url: 'urn:ietf:wg:oauth:2.0:oob')
      puts 'Open the following URL in your browser and authorize the application:'
      puts "\t#{url}"
      puts 'Enter the authorization code:'
      code = gets.chomp
      @credentials = @authorizer.get_and_store_credentials_from_code(user_id: CONFIG.fetch(:user_id),
                                                                     code: code,
                                                                     base_url: 'urn:ietf:wg:oauth:2.0:oob')
    end

    def refresh!
      if !@credentials.expired?
        return
      end

      # TODO:
      #   it seems like the credentials aren't expired but the token is?
      #   there must be another way to validate the @credentials or token that prevents this error
      #
      # [2025-02-16 14:53:30] WARN   : Request to: https://oauth2.googleapis.com/token
      # /Users/tommy/.gem/ruby/3.2.2/gems/signet-0.18.0/lib/signet/oauth_2/client.rb:1061:in `fetch_access_token': Authorization failed.  Server message: (Signet::AuthorizationError)
      # {
      #   "error": "invalid_grant",
      #   "error_description": "Bad Request"
      # }
      #   from /Users/tommy/.gem/ruby/3.2.2/gems/signet-0.18.0/lib/signet/oauth_2/client.rb:1076:in `fetch_access_token!'
      #   from /Users/tommy/.gem/ruby/3.2.2/gems/googleauth-1.9.1/lib/googleauth/signet.rb:58:in `block in fetch_access_token!'
      #   from /Users/tommy/.gem/ruby/3.2.2/gems/googleauth-1.9.1/lib/googleauth/signet.rb:78:in `retry_with_error'
      #   from /Users/tommy/.gem/ruby/3.2.2/gems/googleauth-1.9.1/lib/googleauth/signet.rb:57:in `fetch_access_token!'
      #   from /Users/tommy/.gem/ruby/3.2.2/gems/signet-0.18.0/lib/signet/oauth_2/client.rb:1091:in `refresh!'
      #   from /Users/tommy/Workspace/anti-anachronism/google_api/client.rb:60:in `refresh!'

      @credentials.refresh!
      raise 'Having trouble refreshing.' if @credentials.expired?
    end
  end
end

