class Album < OpenStruct # (:id, :title, :productUrl, :mediaItemsCount)
  include ActiveRecord

  ALBUMS_MAX_PAGE_SIZE = 50
  CSV_HEADERS = ['id', 'title', 'mediaItemsCount', 'coverPhotoMediaItemId']

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
    Album.new({
      id:     object.fetch('id'),
      title:  object.fetch('title'),
      media_items_count:          object.fetch('mediaItemsCount'),
      cover_photo_media_item_id:  object.fetch('coverPhotoMediaItemId')
    })
  end

  def self.from_csv row
    Album.new({
      id:     row.fetch('id'),
      title:  row.fetch('title'),
      media_items_count:          row.fetch('mediaItemsCount'),
      cover_photo_media_item_id:  row.fetch('coverPhotoMediaItemId')
    })
  end

  def to_csv
    [ id, title, media_items_count, cover_photo_media_item_id ]
  end

  def url 
    "https://photos.google.com/lr/album/#{id}"
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
