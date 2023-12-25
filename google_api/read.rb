require 'googleauth'
require 'googleauth/stores/file_token_store'

module GoogleAPI
  class Read
    include Singleton

    CREDENTIALS_PATH = './credentials.json'
    TOKEN_PATH = './token-read.yaml'

    SCOPE = 'https://www.googleapis.com/auth/photoslibrary.readonly'
    USER_ID = 'default'

    def initialize
      client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
      token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
      @authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)

      @credentials = @authorizer.get_credentials(USER_ID)
    end

    def self.authorization_header
      instance.authorize
      instance.refresh!
      "Bearer #{instance.access_token}"
    end

    def access_token
      @credentials.access_token
    end

    def authorize
      return unless @credentials.nil?

      url = @authorizer.get_authorization_url(base_url: 'urn:ietf:wg:oauth:2.0:oob')
      puts 'Open the following URL in your browser and authorize the application:'
      puts "\t#{url}"
      puts 'Enter the authorization code:'
      code = gets.chomp
      @credentials = @authorizer.get_and_store_credentials_from_code(user_id: USER_ID, code: code, base_url: 'urn:ietf:wg:oauth:2.0:oob')
    end

    def refresh!
      return unless @credentials.expired?

      @credentials.refresh!
      raise 'Having trouble refreshing.' if @credentials.expired?
    end
  end
end

