require 'csv'

class CSVDatabase

  def self.create path, data
    FileUtils.rm(path) if File.exist?(path)

    CSV.open(path, 'wb') do |csv|
      csv << data.first.keys

      data.each do |row|
        csv << row.values
      end
    end

  rescue Exception => e
    debugger
    puts "oh shit"
  end

end
