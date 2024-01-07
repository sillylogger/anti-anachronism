#! /usr/bin/env ruby

require_relative '../setup'

client = Selenium::WebDriver::Remote::Http::Default.new
# client.read_timeout = 30

opts = Selenium::WebDriver::Chrome::Options.new
opts.add_argument("--user-data-dir=/Users/tommy/Library/Application\ Support/Google/Chrome")
opts.add_argument("--profile-directory=Default")
# opts.add_argument("--headless")
# opts.add_argument("--no-sandbox")
# opts.add_argument("--disable-dev-shm-usage")

# https://github.com/SeleniumHQ/selenium/blob/trunk/rb/CHANGES#L254
driver = Selenium::WebDriver.for :chrome,
  http_client: client,
  options: opts

# Watir.default_timeout = 30
$browser = Watir::Browser.new driver

file = './photos-to-fix.csv'
exit unless File.exist?(file)
CSVDatabase.read file, Photo

photos_that_need_fixing = Photo.all.
  map{|p| GoogleUI::Photo.new(p) }

cookie = File.join($root, 'data', 'google.cookie')
# $browser.cookies.load cookie if File.exist? cookie

photos_that_need_fixing[0 .. 5].each do |photo|
  photo.visit
  photo.open_info
  photo.open_date_edit
  photo.set_date
  photo.save_date

  rescue Watir::Exception::UnknownObjectException => e
    $log.error "Watir exception: #{e}"
    debugger
    puts "Fix it?"
end

FileUtils.rm(cookie) if File.exist?(cookie)
$browser.cookies.save cookie
