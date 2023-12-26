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
  end

  def self.read path, klass
    return unless File.exist?(path)

    csv = CSV.open path, 'rb', headers: true, encoding: "UTF-8"

    csv.each_with_index do |row, index|
      # break if index >= 10

      model = klass.from_csv row
      model.save
    end
  end

end
