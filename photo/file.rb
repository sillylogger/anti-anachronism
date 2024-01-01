class Photo::File

  MATCHERS = [
    /(?:Screen Shot )?(\d{4}-\d{2}-\d{2} at \d{1,2}\.\d{2}\.\d{2})(?:-\d+)?.(?:png)/i,
    /(?:WhatsApp Image )?(\d{4}-\d{2}-\d{2} at \d{1,2}\.\d{2}\.\d{2} (?:PM|AM))(?:-\d+)?.(?:png|jpeg)/i,
    /(\d{4}-\d{2}-\d{2} \d{1,2}\.\d{2}\.\d{2})(?:-\d+|-Pano)?.(?:jpg|png|mp4|dng)/i,
    /IMG_(\d{8}_\d{6}).jpg/i,
    /IMG-(\d{8})-WA\d+.jpe?g/i,
    /IMG-(\d{8})-wa\d+.jpe?g/i,
    /([12]\d{7}_\d{6})(?:[_-~]\d+)?.(?:mp4|heic|jpg)/i,
    /([12]\d{7}_\d{6})(?:_\d+)?.(?:mp4|heic)/i,
    /([12]\d{7}_\d{6})\(\d+\).heic/i,
    /([12]\d{7}_\d{6})_HDR.jpg/i,
    /([12]\d{7}_\d{6}).jpg/i,
    /(\d{8})-DSC_\d{4}.jpg/i,
    /(\d{4}-\d{2}-\d{2})(?:-\d+).jpg/i,
    /Screenshot_(\d{8}_\d{6})_\w+.jpg/i,
    /Photo on (\d{2}-\d{2}-\d{2} at \d{2}.\d{2}).jpg/i,
    # /(\d{10})-(?:\d+).jpg/i,
  ]

  attr_accessor :name
  attr_accessor :match, :matcher

  def initialize name
    @name = name

    MATCHERS.each do |matcher|
      if match = matcher.match(@name)
        @match = match
        @matcher = matcher
        break
      end
    end

  end

  def creation_time
    return unless @match.present?
    Time.find_zone("Jakarta").parse(@match[1]).to_datetime
  end

end
