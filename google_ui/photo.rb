class GoogleUI::Photo
  attr_accessor :photo

  def initialize photo
    @photo = photo
  end

  def visit
    #$browser.goto "https://photos.google.com/lr/photo/#{@photo.id}"
    $browser.goto photo.url
    sleep 1.0
  end

  def open_info
    return if $browser.button(aria_label: 'Close info').visible?
    $browser.button(aria_label: 'Open info').click
    sleep 0.25
  end

  def open_date_edit
    return if $browser.div(aria_level: "1", text: /Edit date & time/).visible?
    $browser.div(aria_label: /Date:.*/).click
    sleep 0.25
  end

  def set_date
    # the UI wants you to clear the value first and it auto advances to the next
    # DateTime element after fully filled
    year_input = $browser.input(aria_label: "Year")

    time = photo.file.datetime
    time_formatted = time.strftime("\b\b\b\b%Y\b\b%m\b\b%d\b\b%I\b\b%M")
    if time_formatted.size != 24
      debugger
      puts "This will probably mess up the input"
    end
    year_input.set(time_formatted)
    sleep 0.25

    meridian_input = $browser.input(aria_label: "AM/PM")
    meridian_input.set(time.strftime("%p"))
    sleep 0.25
  end

  def save_date
    # I *cannot* find a way to locate the save button... tab tab it is
    # $browser.send_keys :tab, :tab, :tab, :enter

    save_button = $browser.buttons(data_id: "EBS5u", text: /Save/).filter(&:visible?).first
    raise RuntimeException.new("No save button, I'm lost.") if save_button.nil?

    save_button.click
    sleep 0.25
  end

end
