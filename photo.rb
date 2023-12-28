class Photo < OpenStruct
  include ActiveRecord

  ITEMS_MAX_PAGE_SIZE = 100

  CSV_HEADERS = ['id', 'filename', 'mimeType', 'cameraMake', 'cameraModel', 'creationTime', 'creationTimeFromFilename', 'diffInHours']

  def self.fetch_all
    pageToken = nil

    VCR.use_cassette("mediaItems-fetch", :record => :new_episodes) do
      loop do
        items_in_json, pageToken = fetch pageToken
        items_in_json.each do |data|
          Photo.from_json(data).save
        end
        break if pageToken.nil? # || all.size > 100
      end
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
      mime_type:    row.fetch('mimeType'),
      camera_make:  row.fetch('cameraMake'),
      camera_model: row.fetch('cameraModel'),
      creation_time_raw:  row.fetch('creationTime')
    })
  end

  def to_csv
    [ id, filename, mime_type, camera_make, camera_model, creation_time, creation_time_from_filename, diff_in_hours ]
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

  def creation_time_from_filename
    string = creation_time_from_filename_raw
    return nil if string.nil?

    Time.find_zone("Jakarta").parse(string).to_datetime
  rescue Exception => e
    $log.error e.message
    $log.error self
    return nil
  end

  def diff_in_hours
    return nil if creation_time.nil? || creation_time_from_filename.nil?
    @diff_in_hours ||= TimeDifference.between(creation_time, creation_time_from_filename).in_hours
  end

  def creation_time_from_filename_raw
    matchers = [
      /(?:Screen Shot )?(\d{4}-\d{2}-\d{2} at \d{1,2}\.\d{2}\.\d{2})(?:-\d+)?.(?:png)/i,
      /(?:WhatsApp Image )?(\d{4}-\d{2}-\d{2} at \d{1,2}\.\d{2}\.\d{2} (?:PM|AM))(?:-\d+)?.(?:png|jpeg)/i,
      /(\d{4}-\d{2}-\d{2} \d{1,2}\.\d{2}\.\d{2})(?:-\d+|-Pano)?.(?:jpg|png|mp4|dng)/i,
      /IMG_(\d{8}_\d{6}).jpg/i,
      /IMG-(\d{8})-WA\d+.jpe?g/i,
      /IMG-(\d{8})-wa\d+.jpe?g/i,
      /([12]\d{7}_\d{6})(?:[_-]\d+)?.(?:mp4|heic|jpg)/i,
      /([12]\d{7}_\d{6})(?:_\d+)?.(?:mp4|heic)/i,
      /([12]\d{7}_\d{6})_HDR.jpg/i,
      /([12]\d{7}_\d{6}).jpg/i,
      /(\d{8})-DSC_\d{4}.jpg/i,
      /(\d{4}-\d{2}-\d{2})(?:-\d+).jpg/i,
      # /(\d{10})-(?:\d+).jpg/i,
    ]

    matchers.each do |matcher|
      if match = matcher.match(filename)
        $log.debug "Filename: #{filename} with #{matcher} results in #{match[1]}"
        return match[1]
      end
    end

    return nil
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
    return unless response.code == '200'

    json = JSON.parse(response.body)
    return [
      json['mediaItems'],
      json['nextPageToken']
    ]
  end
end
