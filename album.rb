class Album < OpenStruct # (:id, :title, :productUrl, :mediaItemsCount)
  include ActiveRecord

  ALBUMS_MAX_PAGE_SIZE = 50
  ATTRIBUTES = ['id', 'title', 'productUrl', 'mediaItemsCount', 'coverPhotoMediaItemId']

  def self.fetch_all
    pageToken = nil

    VCR.use_cassette("albums-fetch", :record => :new_episodes) do
      loop do
        albums_in_json, pageToken = fetch pageToken
        albums_in_json.each do |data|
          Album.from_json(data).save
        end
        break if pageToken.nil?
      end
    end

    Album.all
  end

  def self.from_json object
    data = object.slice(*ATTRIBUTES)
    Album.new(data)
  end

  def self.from_csv row
    data = row.to_h.slice(*ATTRIBUTES)
    Album.new(data)
  end

  def to_csv
    ATTRIBUTES.map{|key| self.send(key) }
  end

  private

  def self.fetch pageToken
    uri = URI("#{GoogleAPI::API_BASE_URL}/albums")

    params = { page_size: ALBUMS_MAX_PAGE_SIZE }
    params[:pageToken] = pageToken unless pageToken.nil?
    uri.query = URI.encode_www_form params

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri)
    request['Content-type'] = 'application/json'
    request['Authorization'] = GoogleAPI::Read.authorization_header

    $log.debug "http.request #{request.uri}"
    response = http.request(request)
    return unless response.code == '200'

    json = JSON.parse(response.body)
    return [
      json['albums'],
      json['nextPageToken']
    ]
  end

end
