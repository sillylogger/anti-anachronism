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

CSVDatabase.read './data/photos.csv', Photo

$browser.goto "https://photos.google.com/lr/photo/#{Photo.all[6].id}"
cookie = File.join($root, 'data', 'google.cookie')
$browser.cookies.load cookie if File.exist? cookie

photos_by_diff = Photo.all.select{|p|
  p.diff_in_hours.present?
}.sort_by{|p|
  p.diff_in_hours
}.reverse

photos_that_need_fixing = photos_by_diff.slice(2 .. 100)
photos_that_need_fixing.each do |photo|
  $browser.goto "https://photos.google.com/lr/photo/#{photo.id}"
  sleep 1

  unless $browser.button(aria_label: 'Close info').visible?
    $browser.button(aria_label: 'Open info').click
  end

  $browser.div(aria_label: /Date:.*/).click

  # the UI wants you to clear the value first and it auto advances to the next
  # DateTime element after fully filled
  year_input = $browser.input(aria_label: "Year")

  time = photo.creation_time_from_filename
  time_formatted = time.strftime("\b\b\b\b%Y\b\b%m\b\b%d\b\b%I\b\b%M")
  year_input.set(time_formatted)

  meridian_input = $browser.input(aria_label: "AM/PM")
  meridian_input.set(time.strftime("%p"))

  # I *cannot* find a way to locate the save button... tab tab it is
  # save_button = $browser.button(data_id: 'EBS5u')
  $browser.send_keys :tab, :tab, :tab, :enter

  rescue Watir::Exception::UnknownObjectException => e
    $log.error "Watir exception: #{e}"
    debugger
    puts "Fix it?"
end

FileUtils.rm(cookie) if File.exist?(cookie)
$browser.cookies.save cookie
