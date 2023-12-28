class Photo < OpenStruct
  include ActiveRecord

  ITEMS_MAX_PAGE_SIZE = 100
  ATTRIBUTES = ['id', 'mimeType', 'filename', 'creationTime', 'cameraMake', 'cameraModel']

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
    #
    # This works, but I prefer to be explicit in digging into mediaMetaData.photo.cameraMake
    #   data = object.deep_slice(*ATTRIBUTES)
    #

    data = object.slice('id', 'productUrl', 'mimeType', 'filename')

    data['creationTime'] = object.dig('mediaMetadata', 'creationTime')

    if object.dig('mediaMetadata', 'photo', 'cameraMake').present?
      data['cameraMake'] = object.dig('mediaMetadata', 'photo', 'cameraMake')
    end

    if object.dig('mediaMetadata', 'photo', 'cameraModel').present?
      data['cameraModel'] = object.dig('mediaMetadata', 'photo', 'cameraModel')
    end

    Photo.new(data)
  end

  def self.from_csv row
    data = row.to_h.slice(*ATTRIBUTES)
    Photo.new(data)
  end

  def to_csv
    #
    # This table is the OpenStruct table... it doesn't have an "attributes" method
    # This doesn't work because missing attributes aren't populated, we need to make them nil
    #   data = table.deep_slice(*ATTRIBUTES.map(&:to_sym))
    #
    ATTRIBUTES.map{|key| self.send(key) }
  end

  def productUrl 
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

  def date_from_google
    string = mediaMetadata.fetch('creationTime')
    DateTime.parse string
  end

  def date_from_filename
    string = creationTime_from_filename
    return nil if string.nil?

    Time.find_zone("Jakarta").parse(string).to_datetime
  rescue Exception => e
    $log.error e.message
    $log.error self
    return nil
  end

  def diff? hours = 7
    @diff ||= if date_from_filename.nil?
      false
    elsif TimeDifference.between(date_from_google, date_from_filename).in_hours > hours
      true
    else
      false
    end

  end

  def diff
    return nil if date_from_google.nil? || date_from_filename.nil?
    TimeDifference.between(date_from_google, date_from_filename).humanize
  end

  def creationTime_from_filename
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
