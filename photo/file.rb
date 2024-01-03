class Photo::File

  attr_accessor :name

  def initialize name
    @name = name
  end

  def creation_time
    datetime_patterns
  end

  # try just looking for certain stubstrings
  # Count, Date, Spacer, Time
  def datetime_patterns
    csv = [
      [ 2871, '(?<date>[2]\d{3}-\d{2}-\d{2}) (?<time>\d{2}.\d{2}.\d{2})',                '%Y-%m-%d %H.%M.%S'],
      [ 9763, '(?<date>[2]\d{7})_(?<time>\d{6})',                                        '%Y%m%d %H%M%S'],
      [   88, '(?<date>[2]\d{7})-(?<time>\d{6})',                                        '%Y%m%d %H%M%S'],
      [   -1, '(?<date>[2]\d{1}-\d{2}-\d{2}) at (?<time>\d{2}.\d{2})',                   '%d-%m-%y %H.%M'],
      [   86, '(?<date>[2]\d{1}-\d{2}-\d{2}) at (?<time>\d{2}.\d{2}.\d{2})',             '%Y-%m-%d %H.%M.%S'],
      [   46, '(?<date>[2]\d{1}-\d{2}-\d{2}) at (?<time>\d{2}.\d{2}.\d{2} (?:AM|PM))',   '%Y-%m-%d %H.%M.%S %p'],
      [   43, '(?<date>[2]\d{1}-\d{2}-\d{2}) at (?<time>\d{1,2}.\d{2}.\d{2} (?:AM|PM))', '%Y-%m-%d %l.%M.%S %p'],
      [   27, '(?<date>[2]\d{1}-\d{2}-\d{2}) (?<time>\d{2} \d{2} \d{2})',                '%Y-%m-%d %H.%M.%S'],
      [   19, '(?<date>[2]\d{1}-\d{2}-\d{2})-(?<time>\d{2}-\d{2}-\d{2})',                '%Y-%m-%d %H-%M-%S'],
      [   15, '(?<date>[2]\d{1}-\d{2}-\d{2})-(?<time>\d{2}-\d{2})',                      '%Y-%m-%d %H-%M'],
      [   14, '(?<date>[2]\d{3}-\d{2}-\d{2})(?<time>\d{6})',                             '%Y-%m-%d %H%M%S'],
      [    9, '(?<date>\d{2}-\d{2}-[2]\d{1}), (?<time>\d{1,2}\.\d{2}\.\d{2} (?:AM|PM))', '%d-%m-%Y %l.%M.%S %p'],
      [   68, '(?<date>[2]\d{1}-\d{2}-\d{2})',                                           '%Y-%m-%d'],
      [   32, '(?<time>\d{16})'                                                          '%s%6N'],
      [   77, '(?<time>\d{10})',                                                         '%s'],
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

        if match.names.include?('time')
          parts << match[:time] 
          parts << "+0700"
          format += " %z"
        end

        parsed = DateTime.strptime(parts.join(" "), format)

        if !parsed.nil?
          return parsed.in_time_zone("Jakarta").to_datetime
        end

      rescue DateTime::Error
        debugger
        puts "fix meee"
      end
    end

    return nil
  end

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

end
