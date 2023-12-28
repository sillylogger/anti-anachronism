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

      @credentials.refresh!
      raise 'Having trouble refreshing.' if @credentials.expired?
    end
  end
end

