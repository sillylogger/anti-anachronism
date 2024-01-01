require "minitest/autorun"

require_relative File.join('..', '..', 'setup')

describe Photo::File do

  let(:photo) {
    Photo.new({
      filename: "20180421_125025.jpg",
      creation_time_raw: "1970-02-12T04:16:38+00:00"
    })
  }

  it "gets initialized with the photo" do
    expect(photo.file.name).must_equal photo.filename
  end

  describe "#creation_time" do 
    it "reads from the filename" do
      expect(photo.file.creation_time).must_be_close_to DateTime.new(2018, 4, 21, 12, 50, 25, '+07:00')
    end

    it "manages to handle harder matches" do
      file = Photo::File.new("Screenshot_20231228_100105_Instagram.jpg") # "2023-12-28T02:01:05+00:00"
      expect(file.creation_time).must_be_close_to DateTime.new(2023, 12, 28, 10, 1, 5, '+07:00')

      file = Photo::File.new("20231227_115918(0).heic") # "2023-12-27T03:59:18+00:00"
      expect(file.creation_time).must_be_close_to DateTime.new(2023, 12, 27, 11, 59, 18, '+07:00')

      file = Photo::File.new("20231225_165510~2.jpg") # "2023-12-25T11:01:44+00:00"
      expect(file.creation_time).must_be_close_to DateTime.new(2023, 12, 25, 16, 55, 10, '+07:00')

      file = Photo::File.new("Screenshot_20231224_163131_Speedtest.jpg") # "2023-12-24T08:31:31+00:00"
      expect(file.creation_time).must_be_close_to DateTime.new(2023, 12, 24, 16, 31, 31, '+07:00')

      file = Photo::File.new("Screenshot_20231222_183930_Chess.jpg") # "2023-12-22T11:39:30+00:00"
      expect(file.creation_time).must_be_close_to DateTime.new(2023, 12, 22, 18, 39, 30, '+07:00')
    end

    it "can handle custom time parsing" do
      skip "you need to restructure the matching process to enable custom time parsing"
      file = Photo::File.new("Photo on 25-12-23 at 10.43.jpg") # "2023-12-25T03:43:47+00:00"
      expect(file.creation_time).must_be_close_to DateTime.new(2023, 12, 25, 10, 43, 0, '+07:00')
    end
  end


end
