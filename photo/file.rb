class Photo::File

  attr_accessor :name

  attr_accessor :datetime_matcher,
                :date_matcher,
                :time_matcher

  def initialize name
    @name = name
  end

  def datetime
    csv = [
      [ 2871, '(?<date>(20|19)\d{2}-\d{2}-\d{2}) (?<time>\d{2}\.\d{2}\.\d{2})',                '%Y-%m-%d %H.%M.%S'],
      [   -1, '(?<date>(20|19)\d{2}-\d{2}-\d{2}) (?<time>\d{2}\-\d{2}\-\d{2})',                '%Y-%m-%d %H-%M-%S'],

      [ 9763, '(?<date>(20|19)\d{6})_(?<time>\d{6})',                                          '%Y%m%d %H%M%S'],
      [   88, '(?<date>(20|19)\d{6})-(?<time>\d{6})',                                          '%Y%m%d %H%M%S'],
      [   86, '(?<date>(20|19)\d{2}-\d{2}-\d{2}) at (?<time>\d{2}\.\d{2}\.\d{2})',             '%Y-%m-%d %H.%M.%S'],
      [   46, '(?<date>(20|19)\d{2}-\d{2}-\d{2}) at (?<time>\d{2}\.\d{2}\.\d{2} (?:AM|PM))',   '%Y-%m-%d %H.%M.%S %p'],
      [   43, '(?<date>(20|19)\d{2}-\d{2}-\d{2}) at (?<time>\d{1,2}\.\d{2}\.\d{2} (?:AM|PM))', '%Y-%m-%d %l.%M.%S %p'],
      [   27, '(?<date>(20|19)\d{2}-\d{2}-\d{2}) (?<time>\d{2}\s\d{2} \d{2})',                 '%Y-%m-%d %H.%M.%S'],
      [   19, '(?<date>(20|19)\d{2}-\d{2}-\d{2})-(?<time>\d{2}\-\d{2}-\d{2})',                 '%Y-%m-%d %H-%M-%S'],
      [   15, '(?<date>(20|19)\d{2}-\d{2}-\d{2})-(?<time>\d{2}\-\d{2})',                       '%Y-%m-%d %H-%M'],
      [   -1, '(?<date>\d{2}-\d{2}-\d{2}) at (?<time>\d{2}\.\d{2})',                           '%d-%m-%y %H.%M'],
      [   14, '(?<date>(20|19)\d{2}-\d{2}-\d{2})(?<time>\d{6})',                               '%Y-%m-%d %H%M%S'],
      [    9, '(?<date>\d{2}-\d{2}-[2]\d{1}), (?<time>\d{1,2}\.\d{2}\.\d{2} (?:AM|PM))',       '%d-%m-%Y %l.%M.%S %p'],
      [   68, '(?<date>(20|19)\d{2}-\d{2}-\d{2})',                                             '%Y-%m-%d'],
      [   32, '(?<time>\d{16})'                                                                '%s%6N'],
      [   77, '(?<time>\d{10})',                                                               '%s'],
      [ 1363, '(?<date>(20|19)\d{2}[01]\d{3})',                                                '%Y%m%d'],
      [   30, '(?<date>(20|19)\d{5,6})',                                                       '%-d%B%Y'],
      [   14, '(?<date>\d{1,2}\.\d{1,2}\.[2]\d{3})',                                           '%-m.%-d.%y'],
    ]

    csv.each do |count, regex, format|
      match = name.match Regexp.new(regex, 'i')
      next if match.nil?

      format_maybe_zone = format

      begin 
        parts = []
        parts << match[:date] if match.names.include?('date')

        if match.names.include?('time')
          parts << match[:time] 
          parts << "+0700"
          format_maybe_zone += " %z"
        end

        parsed = DateTime.strptime(parts.join(" "), format_maybe_zone)
        if parsed.nil?
          next
        end

        if parsed > Date.today || parsed < Date.civil(2000, 1, 1)
          # puts [name, regex, format, "invalid"].join("\t")
          next
        end

        @datetime_matcher = [regex, format]

        # TODO: is this :in_time_zone still needed with the adjustment above?
        return parsed.in_time_zone("Jakarta").to_datetime

      rescue DateTime::Error
        # debugger
        puts [name, regex, format, "invalid"].join("\t")
        next
      end
    end

    return nil
  end

  def date
    csv = [
      [ 11214, '(?<!\d)(?<date>[2]\d{3}[01]\d{1}[0123]\d{1})',          '%Y%m%d' ],
      [  3162, '(?<!\d)(?<date>[2]\d{3}-[01]\d{1}-[0123]\d{1})(?!\))',  '%Y-%m-%d' ],
      [    77, '(?<!\d)(?<date>\d{10})(?!\d)',                          '%s' ],
      [    36, '(?<!\d)(?<date>\d{2}-[01]\d{1}-[2]\d{3})',              '%d-%m-%Y' ],
      [    30, '(?<!\d)(?<date>\d{1,2}\d{2}[2]\d{3})',                  '%-d%B%Y' ],
      [    14, '(?<!\d)(?<date>\d{1,2}\.[01]\d{1}\.[2]\d{3})',          '%-m.%-d.%y' ],
    ]

    csv.each do |count, regex, format|
      match = name.match Regexp.new(regex, 'i')
      next if match.nil? || match[:date].nil?

      begin 
        parsed = Date.strptime(match[:date], format)
        if parsed.nil?
          next
        end

        if parsed > Date.today || parsed < Date.civil(2000, 1, 1)
          puts [name, regex, format, "invalid"].join("\t")
          next
        end

        @date_matcher = [regex, format]
        return parsed 

      rescue Date::Error
        #debugger
        puts [name, regex, format, "invalid"].join("\t")
        next
      end
    end

    return nil
  end

  def time
    csv = [
      [ 9865, '(?<!\d)(?<time>[012]\d{1}[0-5]\d{1}[0-5]\d{1})(?!\d)',      '%H%M%S' ],
      [ 2957, '(?<!\d)(?<time>[012]\d{1}\.[0-5]\d{1}\.[0-5]\d{2})(?!\d)',  '%H.%M.%S' ],
      [   77, '(?<!\d)(?<time>\d{10})(?!\d)',                              '%s' ],
      [   46, '(?<!\d)(?<time>\d{2}\.[0-5]\d{1}\.[0-5]\d{1} (?:AM|PM))',   '%H.%M.%S %p' ],
      [   52, '(?<!\d)(?<time>\d{1,2}\.[0-5]\d{1}\.[0-5]\d{2} (?:AM|PM))', '%l.%M.%S %p' ],
      [   32, '(?<!\d)(?<time>\d{16})(?!\d)',                              '%s%6N' ],
      [   27, '(?<!\d)(?<time>[012]\d{1} [0-5]\d{1} [0-5]\d{1})',          '%H %M %S' ],
      [   19, '(?<!\d)(?<time>[012]\d{1}-[0-5]\d{1}-[0-5]\d{1})',          '%H-%M-%S' ],
      [   15, '(?<!\d)(?<time>[012]\d{1}-[0-5]\d{1})(?!(\d|\)))',          '%H-%M' ]
    ]

    csv.each do |count, regex, format|
      match = name.match Regexp.new(regex, 'i')
      next if match.nil? || match[:time].nil?

      begin 
        parsed = Time.strptime(match[:time], format)
        next if parsed.nil?

        @time_matcher = [regex, format]
        return parsed 

      rescue ArugmentError
        debugger
        puts "Oh noes."
      end
    end

    return nil
  end

end
