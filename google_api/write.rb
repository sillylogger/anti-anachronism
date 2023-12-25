require 'googleauth'
require 'googleauth/stores/file_token_store'

module GoogleAPI
  class Write
    include Singleton

    def self.authorization_header
      @client = GoogleAPI::Client.new(:write)
      @client.authorize
      @client.refresh!
      "Bearer #{@client.access_token}"
    end
  end
end

