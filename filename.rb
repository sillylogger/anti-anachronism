class Filename < Struct.new(:name)

  # def initialize name
  #   super
  # end

  # def peek_into_matcher_and_match
  #   @matcher_and_match
  # end

  def time
    string = parse_with_regex name
    return nil if string.nil?
    return unix_time(string) if epoch?(string)

    parsed = Time.find_zone("Jakarta").parse string
    return parsed.to_datetime

  rescue Exception => e
    $log.error self
    $log.error e
    return nil
  end

  def parse_with_regex name
    matchers = [
      /(?:Screen Shot )?(\d{4}-\d{2}-\d{2} at \d{1,2}\.\d{2}\.\d{2})(?:-\d+)?.(?:png)/i,
      /(?:WhatsApp Image )?(\d{4}-\d{2}-\d{2} at \d{1,2}\.\d{2}\.\d{2} (?:PM|AM))(?:-\d+)?.(?:png|jpeg)/i,
      /(\d{4}-\d{2}-\d{2} \d{1,2}\.\d{2}\.\d{2})(?:-\d+|-Pano)?.(?:jpg|png|mp4|dng)/i,
      /IMG_(\d{8}_\d{6}).jpg/i,
      /IMG-(\d{8})-WA\d+.jpe?g/i,
      /IMG-(\d{8})-wa\d+.jpe?g/i,
      /(\d{8}_\d{6})(?:[_-]\d+)?.(?:mp4|heic|jpg)/i,
      /(\d{8}_\d{6})(?:_\d+)?.(?:mp4|heic)/i,
      /(\d{8}_\d{6})_HDR.jpg/i,
      /(\d{8}_\d{6}).jpg/i,
      /(\d{8})-DSC_\d{4}.jpg/i,
      /(\d{4}-\d{2}-\d{2})(?:-\d+).jpg/i,
      # /(\d{10})-(?:\d+).jpg/i,
    ]

    matchers.each do |matcher|
      if match = matcher.match(name)
        $log.debug "Name: #{name} with #{matcher} results in #{match[1]}"
        # @matcher_and_match = [matcher, match]
        return match[1]
      end
    end

    return nil
  end

  def epoch? string
    # return false if string.size != 10
    #                         👆️ covered with the regex

    # 1000000000 == Sun Sep 09 2001 01:46:40 GMT+0000
    # 2000000000 == Wed May 18 2033 03:33:20 GMT+0000
    /^1\d{9}$/.match? string
  end

  def unix_time string
    Time.find_zone("Jakarta").at string.to_i
  end

end

