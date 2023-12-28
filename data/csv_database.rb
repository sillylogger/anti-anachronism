require 'csv'

class CSVDatabase

  def self.create path, klass
    FileUtils.rm(path) if File.exist?(path)

    CSV.open(path, 'wb') do |csv|
      csv << klass::CSV_HEADERS
      klass.all.each do |model|
        csv << model.to_csv
      end
    end
  end

  def self.read path, klass
    return unless File.exist?(path)

    CSV.foreach(path, 'rb', headers: true, encoding: "UTF-8").
        with_index(1) do |row, index|

      # break if index >= 10
      klass.from_csv(row).save
    end
  end

end
