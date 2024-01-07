require 'digest/sha1'

class Photo < OpenStruct
  include ActiveRecord

  ITEMS_MAX_PAGE_SIZE = 100

  CSV_HEADERS = ['id',
                 'filename',
                 'mime type',
                 'camera make',
                 'camera model',
                 'creation time',
                 'creation date from filename',
                 'diff (in days)',
                 'matcher']

  def self.fetch_all
    page_token = nil

    loop do
      short_token = page_token.present? ?
        Digest::SHA1.hexdigest(page_token) :
        "nil"

      VCR.use_cassette("mediaItems-#{short_token}", :record => :new_episodes) do
        items_in_json, page_token = fetch page_token
        items_in_json.each do |data|
          Photo.from_json(data).save
        end
      end

      break if page_token.nil? # || all.size > 100
    end

    Photo.all
  end

  def self.from_json object
    Photo.new({
      id:           object.fetch('id'),
      filename:     object.fetch('filename'),
      mime_type:    object.fetch('mimeType'),
      camera_make:  object.dig('mediaMetadata', 'photo', 'cameraMake'),
      camera_model: object.dig('mediaMetadata', 'photo', 'cameraModel'),
      creation_time_raw:  object.dig('mediaMetadata', 'creationTime')
    })
  end

  def self.from_csv row
    Photo.new({
      id:           row.fetch('id'),
      filename:     row.fetch('filename'),
      mime_type:    row.fetch('mime type'),
      camera_make:  row.fetch('camera make'),
      camera_model: row.fetch('camera model'),
      creation_time_raw:  row.fetch('creation time')
    })
  end

  attr_accessor :file

  def initialize options={}
    super
    @file = Photo::File.new(filename)
  end

  def to_csv
    [ id,
      filename,
      mime_type,
      camera_make,
      camera_model,
      creation_time,
      file.date,
      diff,
      file.date_matcher
    ]
  end

  def url
    "https://photos.google.com/lr/photo/#{id}"
  end

  def inspect
    clarification = "<Photo"
    methods(false).grep_v(/=$/).sort.each do |method|
      result = send(method)
      result = JSON.pretty_generate(result) if result.is_a? Hash
      clarification << "\n\t#{method}=#{result}"
    end
    clarification << ">"
  end

  def creation_time
    string = creation_time_raw
    DateTime.parse string
  end

  def diff
    return nil if creation_time.nil? || file.date.nil?
    TimeDifference.between(creation_time, file.date).in_days
  end

  private

  def method_missing(meth, *args)
    # raise Exception, "no #{meth} member set yet" unless meth.to_s.end_with?('=')
    super
  end

  def self.fetch pageToken
    uri = URI("#{GoogleAPI::API_BASE_URL}/mediaItems")

    params = { page_size: ITEMS_MAX_PAGE_SIZE }
    params[:pageToken] = pageToken unless pageToken.nil?
    uri.query = URI.encode_www_form params

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri)
    request['Content-type'] = 'application/json'
    request['Authorization'] = GoogleAPI::Read.authorization_header

    $log.debug "http.request #{request.uri}"
    response = http.request(request)
    if response.code != '200'
      raise RuntimeException.new("Photo.fetch returned != 200")
    end

    json = JSON.parse(response.body)
    return [
      json['mediaItems'],
      json['nextPageToken']
    ]
  end
end
