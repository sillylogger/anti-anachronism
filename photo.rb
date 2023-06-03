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
        break if pageToken.nil? # || all.size > 100
      end
    end

    Photo.all
  end

  def csv
    table.deep_slice(:id, :mimeType, :filename, 'creationTime', 'cameraMake', 'cameraModel')
  end

  def inspect
    clarification = "<Photo"
    methods(false).grep_v(/=$/).each do |method|
      result = send(method)
      result = JSON.pretty_generate(result) if result.is_a? Hash
      clarification << "\n#{method}=#{result}"
    end
    clarification << ">"
  end

  def date_from_google
    string = mediaMetadata.fetch('creationTime')
    DateTime.parse string
  end

  def date_from_filename
    @date_from_filename ||= Filename.new(filename).time
  end

  def diff?
    @diff ||= if date_from_filename.nil?
      false
    elsif TimeDifference.between(date_from_google, date_from_filename).in_hours > 7
      true
    else
      false
    end

  end

  def diff
    return nil if date_from_google.nil? || date_from_filename.nil?
    TimeDifference.between(date_from_google, date_from_filename).humanize
  end

  private

  def method_missing(meth, *args)
    raise Exception, "no #{meth} member set yet" unless meth.to_s.end_with?('=')
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
    request['Authorization'] = GoogleAPI.authorization_header 

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
