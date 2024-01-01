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
      expect(photo.file.creation_time).must_be_close_to Date.civil(2018, 4, 21), 1.day
    end
  end

  # AFYxATHGlckhUefGGANjoyjbBBseMYzmRy9aURXNstvmjhoiKgp3jecCEARU3rUdePm1f9yqnRZCiXm15u7GQ7QYE00Wv9PGnA	Screenshot_20231228_100105_Instagram.jpg	image/jpeg			2023-12-28T02:01:05+00:00			
  # AFYxATHpww6nV4j8Q2Eg6yD8xpC-ufg9ngIjj_NJB_Obm_ZITfD-AL8htzfDA4MgDWSaA6W-J5IFElRgRidu1H4ahcOxU5TtmA	20231227_115918(0).heic	image/heif	samsung	Galaxy S23	2023-12-27T03:59:18+00:00			
  # AFYxATHMCAq4Vn02gV7lgEa-EOhkQ__jWqXpqoJyPeGKnESqBES-60uFph3EFpT2nUhLztM6AQujAUZTgE3WOG-8uvVMlwOJLg	20231225_165510~2.jpg	image/jpeg			2023-12-25T11:01:44+00:00			
  # AFYxATHxkOZk6icAlbWQmWKeK8_C2lW1wO9ezKO1JeTg-29vWzheAS2U_saSZXKZMjvDwyIMQk4oP12AzHWoZCz9LQD3NzDDag	Photo on 25-12-23 at 10.43.jpg	image/jpeg			2023-12-25T03:43:47+00:00			
  # AFYxATH0PNjH1joQ1e4EiKmg36Wgxr6IX2Tvdg_umrQ-3BJaqcA88Gz5oETcGERJ17hb1sL3V4Z8M767OY0zVATxDZwyuRumCQ	Screenshot_20231224_163131_Speedtest.jpg	image/jpeg			2023-12-24T08:31:31+00:00			
  # AFYxATEgZLs0ttFzez4SKinSQa7_bu3WJYnRYz0aMcGaqZYcxIN23Kh2bD3M7zomAWiUNm9SV18xbRF1w4EsxuGd9Y_hIA5yRw	Screenshot_20231222_183930_Chess.jpg	image/jpeg			2023-12-22T11:39:30+00:00			

end
