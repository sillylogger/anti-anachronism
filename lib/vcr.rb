VCR.configure do |config|
  config.cassette_library_dir = "vcr_cassettes"
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = true

  config.ignore_request do |request|
    # "https://oauth2.googleapis.com/token" == request.uri

    if request.uri.start_with? "https://photoslibrary.googleapis.com"
      false
    else
      $log.warn "Request to: #{request.uri}"
      true
    end
  end
end
