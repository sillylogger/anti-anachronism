class Filename < Struct.new(:name)

  # def initialize name
  #   super
  # end

  # def peek_into_matcher_and_match
  #   @matcher_and_match
  # end

  # def time
  #   string = parse_with_regex name
  #   return nil if string.nil?
  #   return unix_time(string) if epoch?(string)
  #
  #   parsed = Time.find_zone("Jakarta").parse string
  #   return parsed.to_datetime
  #
  # rescue Exception => e
  #   $log.error self
  #   $log.error e
  #   return nil
  # end
  #
  # def datetime
  # end

  def date_patterns
    csv = [
      [ 11214, '(?<!\d)(?<date>[2]\d{3}[01]\d{1}[0123]\d{1})',          '%Y%m%d' ],
      [  3162, '(?<!\d)(?<date>[2]\d{3}-[01]\d{1}-[0123]\d{1})(?!\))',  '%Y-%m-%d' ],
      [    36, '(?<!\d)(?<date>\d{2}-[01]\d{1}-[2]\d{3})',              '%d-%m-%Y' ],
      [    30, '(?<!\d)(?<date>\d{1,2}\d{2}[2]\d{3})',                  '%-d%B%Y' ],
      [    14, '(?<!\d)(?<date>\d{1,2}\.[01]\d{1}\.[2]\d{3})',          '%-m.%-d.%y' ]
    ]

    csv.each do |count, regex, format|
      match = name.match Regexp.new(regex, 'i')
      next if match.nil? || match[:date].nil?

      begin 
        parsed = Date.strptime(match[:date], format)
        if !parsed.nil?
          return parsed 
        end

      rescue Date::Error
        debugger
        puts "fix meee"
      end
    end

    return nil

  end

  def time_patterns
    csv = [
      [ 9865, '(?<!\d)(?<time>[012]\d{1}[0-5]\d{1}[0-5]\d{1})(?!\d)',      '%H%M%S' ],
      [ 2957, '(?<!\d)(?<time>[012]\d{1}\.[0-5]\d{1}\.[0-5]\d{2})(?!\d)',  '%H.%M.%S' ],
      [   77, '(?<!\d)(?<time>\d{10})(?!\d)',                                '%s' ],
      [   46, '(?<!\d)(?<time>\d{2}\.[0-5]\d{1}\.[0-5]\d{1} (?:AM|PM))',     '%H.%M.%S %p' ],
      [   52, '(?<!\d)(?<time>\d{1,2}\.[0-5]\d{1}\.[0-5]\d{2} (?:AM|PM))',   '%l.%M.%S %p' ],
      [   32, '(?<!\d)(?<time>\d{16})(?!\d)',                                '%s%6N' ],
      [   27, '(?<!\d)(?<time>[012]\d{1} [0-5]\d{1} [0-5]\d{1})',            '%H %M %S' ],
      [   19, '(?<!\d)(?<time>[012]\d{1}-[0-5]\d{1}-[0-5]\d{1})',            '%H-%M-%S' ],
      [   15, '(?<!\d)(?<time>[012]\d{1}-[0-5]\d{1})(?!(\d|\)))',               '%H-%M' ]
    ]

    csv.each do |count, regex, format|
      match = name.match Regexp.new(regex, 'i')
      next if match.nil? || match[:time].nil?

      begin 
        parsed = Time.strptime(match[:time], format)
        if !parsed.nil?
          return parsed 
        end

      rescue ArgumentError => e
        debugger
        puts "fix meee"
      end
    end

    return nil
  end

  # try just looking for certain stubstrings
  # Count, Date, Spacer, Time
  def datetime_patterns
    csv = [
      [ 2871, '(?<date>[2]\d{3}-\d{2}-\d{2}) (?<time>\d{2}.\d{2}.\d{2})',                '%Y-%m-%d %H.%M.%S'],
      [ 9763, '(?<date>[2]\d{7})_(?<time>\d{6})',                                        '%Y%m%d %H%M%S'],
      [   88, '(?<date>[2]\d{7})-(?<time>\d{6})',                                        '%Y%m%d %H%M%S'],
      [   86, '(?<date>[2]\d{1}-\d{2}-\d{2}) at (?<time>\d{2}.\d{2}.\d{2})',             '%Y-%m-%d %H.%M.%S'],
      [   46, '(?<date>[2]\d{1}-\d{2}-\d{2}) at (?<time>\d{2}.\d{2}.\d{2} (?:AM|PM))',   '%Y-%m-%d %H.%M.%S %p'],
      [   43, '(?<date>[2]\d{1}-\d{2}-\d{2}) at (?<time>\d{1,2}.\d{2}.\d{2} (?:AM|PM))', '%Y-%m-%d %l.%M.%S %p'],
      [   27, '(?<date>[2]\d{1}-\d{2}-\d{2}) (?<time>\d{2} \d{2} \d{2})',                '%Y-%m-%d %H.%M.%S'],
      [   19, '(?<date>[2]\d{1}-\d{2}-\d{2})-(?<time>\d{2}-\d{2}-\d{2})',                '%Y-%m-%d %H-%M-%S'],
      [   15, '(?<date>[2]\d{1}-\d{2}-\d{2})-(?<time>\d{2}-\d{2})',                      '%Y-%m-%d %H-%M'],
      [   14, '(?<date>[2]\d{3}-\d{2}-\d{2})(?<time>\d{6})',                             '%Y-%m-%d %H%M%S'],
      [    9, '(?<date>\d{2}-\d{2}-[2]\d{1}), (?<time>\d{1,2}\.\d{2}\.\d{2} (?:AM|PM))', '%d-%m-%Y %l.%M.%S %p'],
      [   68, '(?<date>[2]\d{1}-\d{2}-\d{2})',                                           '%Y-%m-%d'],
      [   32, '(?<time>\d{16})'                                                       '%s%6N'],
      [   77, '(?<time>\d{10})',                                                      '%s'],
      [ 1363, '(?<date>[2]\d{7})',                                                       '%Y%m%d'],
      [   30, '(?<date>[2]\d{6,7})',                                                     '%-d%B%Y'],
      [   14, '(?<date>\d{1,2}\.\d{1,2}\.[2]\d{3})',                                     '%-m.%-d.%y'],
    ]

    csv.each do |count, regex, format|
      match = name.match Regexp.new(regex, 'i')
      next if match.nil?

      begin 
        parts = []
        parts << match[:date] if match.names.include?('date')
        parts << match[:time] if match.names.include?('time')
        parsed = DateTime.strptime(parts.join(" "), format)

        if !parsed.nil?
          return parsed 
        end

      rescue DateTime::Error
        debugger
        puts "fix meee"
      end
    end

    return nil
  end

  # def match_v1 name
  #   matchers = [
  #     /(?:Screen Shot )?(\d{4}-\d{2}-\d{2} at \d{1,2}\.\d{2}\.\d{2})(?:-\d+)?.(?:png)/i,
  #     /(?:WhatsApp Image )?(\d{4}-\d{2}-\d{2} at \d{1,2}\.\d{2}\.\d{2} (?:PM|AM))(?:-\d+)?.(?:png|jpeg)/i,
  #     /(\d{4}-\d{2}-\d{2} \d{1,2}\.\d{2}\.\d{2})(?:-\d+|-Pano)?.(?:jpg|png|mp4|dng)/i,
  #     /IMG_(\d{8}_\d{6}).jpg/i,
  #     /IMG-(\d{8})-WA\d+.jpe?g/i,
  #     /IMG-(\d{8})-wa\d+.jpe?g/i,
  #     /(\d{8}_\d{6})(?:[_-]\d+)?.(?:mp4|heic|jpg)/i,
  #     /(\d{8}_\d{6})(?:_\d+)?.(?:mp4|heic)/i,
  #     /(\d{8}_\d{6})_HDR.jpg/i,
  #     /(\d{8}_\d{6}).jpg/i,
  #     /(\d{8})-DSC_\d{4}.jpg/i,
  #     /(\d{4}-\d{2}-\d{2})(?:-\d+).jpg/i,
  #     # /(\d{10})-(?:\d+).jpg/i,
  #   ]
  #
  #   matchers.each do |matcher|
  #     if match = matcher.match(name)
  #       $log.debug "Name: #{name} with #{matcher} results in #{match[1]}"
  #       # @matcher_and_match = [matcher, match]
  #       return match[1]
  #     end
  #   end
  #
  #   return nil
  # end
  #
  # def epoch? string
  #   # return false if string.size != 10
  #   #                         👆️ covered with the regex
  #
  #   # 1000000000 == Sun Sep 09 2001 01:46:40 GMT+0000
  #   # 2000000000 == Wed May 18 2033 03:33:20 GMT+0000
  #   /^1\d{9}$/.match? string
  # end
  #
  # def unix_time string
  #   Time.find_zone("Jakarta").at string.to_i
  # end

end

