class Photo < OpenStruct
  include ActiveRecord

  ITEMS_MAX_PAGE_SIZE = 100

  def self.fetch_all
    pageToken = nil

    VCR.use_cassette("mediaItems-fetch", :record => :new_episodes) do
      loop do
        items_in_json, pageToken = fetch pageToken
        items_in_json.each do |item_in_json|
          Photo.new(item_in_json).save
        end
        break if pageToken.nil? # || all.size > 1_000
      end
    end

    Photo.all
  end

  def csv
    table.deep_slice(:id, :mimeType, :filename, 'creationTime', 'cameraMake', 'cameraModel')
  end

  private

  def self.fetch pageToken
    uri = URI("#{GoogleAPI::API_BASE_URL}/mediaItems")

    params = { page_size: ITEMS_MAX_PAGE_SIZE }
    params[:pageToken] = pageToken unless pageToken.nil?
    uri.query = URI.encode_www_form params

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri)
    request['Content-type'] = 'application/json'
    request['Authorization'] = GoogleAPI.authorization_header 

    puts "http.request #{request.uri}"
    response = http.request(request)
    return unless response.code == '200'

    json = JSON.parse(response.body)
    return [
      json['mediaItems'],
      json['nextPageToken']
    ]
  end
end
