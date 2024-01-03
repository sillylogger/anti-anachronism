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
      creation_time = photo.file.creation_time
      expect(creation_time).must_be_close_to DateTime.new(2018, 4, 21, 12, 50, 25, '+07:00')
    end

    it "manages to handle harder matches" do
      file = Photo::File.new("Screenshot_20231228_100105_Instagram.jpg")
      expect(file.creation_time).must_be_close_to DateTime.new(2023, 12, 28, 10, 1, 5, '+07:00')

      file = Photo::File.new("20231227_115918(0).heic")
      expect(file.creation_time).must_be_close_to DateTime.new(2023, 12, 27, 11, 59, 18, '+07:00')

      file = Photo::File.new("20231225_165510~2.jpg")
      expect(file.creation_time).must_be_close_to DateTime.new(2023, 12, 25, 16, 55, 10, '+07:00')

      file = Photo::File.new("Screenshot_20231224_163131_Speedtest.jpg")
      expect(file.creation_time).must_be_close_to DateTime.new(2023, 12, 24, 16, 31, 31, '+07:00')

      file = Photo::File.new("Screenshot_20231222_183930_Chess.jpg")
      expect(file.creation_time).must_be_close_to DateTime.new(2023, 12, 22, 18, 39, 30, '+07:00')
    end

    it "can handle custom time parsing" do
      file = Photo::File.new("Photo on 25-12-23 at 10.43.jpg")
      expect(file.creation_time).must_be_close_to DateTime.new(2023, 12, 25, 10, 43, 0, '+07:00')
    end
  end

  # https://docs.google.com/spreadsheets/d/1KJ3bmt1csh_zfdnxMHveVQKlVgu0Ww78XuhaeFWAg0I/edit#gid=1380526985&range=B3
  TEST_DATA = [
    [ 7971, '########_######.jpg', '20230526_203003.jpg', '%Y%m%d', '_', '%H%M%S', '(?i)(\d{8}_\d{6}).jpg'],
    [ 6709, 'img_####.jpg', 'IMG_0320.jpg', '', '', '', ''],
    [ 2133, '####-##-## ##.##.##.jpg', '2017-09-03 11.42.08.jpg', '%Y-%m-%d', 'space', '%H.%M.%S', '(?i)(\d{4}-\d{2}-\d{2} \d{1,2}\.\d{2}\.\d{2})(?:-\d+|-Pano)?.(?:jpg|png|mp4|dng)'],
    [ 1061, 'dsc#####.jpg', 'DSC04187.jpg', '', '', '', ''],
    [ 1005, 'imgp####.jpg', 'IMGP3883.JPG', '', '', '', ''],
    [  990, 'p#######.jpg', 'P4154179.JPG', '', '', '', ''],
    [  980, 'dsc_####.jpg', 'DSC_0148.JPG', '', '', '', ''],
    [  953, 'img-########-wa####.jpg', 'IMG-20230430-WA0074.jpg', '%Y%m%d', '', '', '(?i)IMG-(\d{8})-WA\d+.jpe?g'],
    [  797, '########_######_hdr.jpg', '20160403_113354_HDR.jpg', '%Y%m%d', '_', '%H%M%S', '(?i)(\d{8}_\d{6})_HDR.jpg'],
    [  687, 'dscf####.jpg', 'DSCF0890.JPG', '', '', '', ''],
    [  682, 'img_####.heic', 'IMG_0319.HEIC', '', '', '', ''],
    [  504, '########.jpg', '19730019.JPG', '', '', '', ''],
    [  419, '########-#.jpg', '00000076-2.JPG', '', '', '', ''],
    [  379, '########_######.mp#', '20230525_190151.mp4', '%Y%m%d', '_', '%H%M%S', '(?i)(\d{8}_\d{6})(?:_\d+)?.(?:mp4|heic)'],
    [  347, 'pc######.jpg', 'PC250376.JPG', '', '', '', ''],
    [  338, '####-##-## ##.##.##-#.jpg', '2017-09-03 11.42.09-5.jpg', '%Y-%m-%d', 'space', '%H.%M.%S', '(?i)(\d{4}-\d{2}-\d{2} \d{1,2}\.\d{2}\.\d{2})(?:-\d+|-Pano)?.(?:jpg|png|mp4|dng)'],
    [  252, 'img_########_######.jpg', 'IMG_20221007_103823.jpg', '%Y%m%d', '_', '%H%M%S', '(?i)IMG_(\d{8}_\d{6}).jpg'],
    [  246, 'fsl_####.jpg', 'FSL_2438.JPG', '', '', '', ''],
    [  233, 'img-########-wa####.jpeg', 'IMG-20230510-WA0007.jpeg', '%Y%m%d', '', '', '(?i)IMG-(\d{8})-wa\d+.jpe?g'],
    [  201, 'f#######.jpg', 'f0628376.jpg', '', '', '', ''],
    [  193, '####-##-## ##.##.##.png', '2017-03-12 03.08.52.png', '%Y-%m-%d', 'space', '%H.%M.%S', '(?i)(\d{4}-\d{2}-\d{2} \d{1,2}\.\d{2}\.\d{2})(?:-\d+|-Pano)?.(?:jpg|png|mp4|dng)'],
    [  132, '####-##-## ##.##.##.mp#', '2019-10-27 14.21.44.mp4', '%Y-%m-%d', 'space', '%H.%M.%S', '(?i)(\d{4}-\d{2}-\d{2} \d{1,2}\.\d{2}\.\d{2})(?:-\d+|-Pano)?.(?:jpg|png|mp4|dng)'],
    [  125, 'dsc#####.arw', 'DSC04170.ARW', '', '', '', ''],
    [   99, 'mouth.## (desktop-c#qnt#d\'s conflicted copy ####-##-##).png', 'mouth.65 (DESKTOP-C2QNT8D\'s conflicted copy 2023-02-07).png', '', '', '', ''],
    [   85, 'gfx_eq_b#_#_jt_tiny.##.png', 'GFX_EQ_b1_1_jt_tiny.94.png', '', '', '', ''],
    [   81, '########-dsc_####.jpg', '20120731-DSC_6052.jpg', '%Y%m%d', '', '', '(?i)(\d{8})-DSC_\d{4}.jpg'],
    [   78, '########_######.heic', '20200409_211937.heic', '%Y%m%d', '_', '%H%M%S', '(?i)(\d{8}_\d{6})(?:_\d+)?.(?:mp4|heic)'],
    [   74, '##.jpg', '58.jpg', '', '', '', ''],
    [   72, '########_######_##.mp#', '20220903_234858_99.mp4', '%Y%m%d', '_', '%H%M%S', '(?i)(\d{8}_\d{6})(?:_\d+)?.(?:mp4|heic)'],
    [   64, 'img_####.mov', 'IMG_9068.MOV', '', '', '', ''],
    [   62, '####-##-## ##.##.##-pano.dng', '2017-09-15 13.33.30-Pano.dng', '%Y-%m-%d', 'space', '%H.%M.%S', '(?i)(\d{4}-\d{2}-\d{2} \d{1,2}\.\d{2}\.\d{2})(?:-\d+|-Pano)?.(?:jpg|png|mp4|dng)'],
    [   61, 'eyes_v##.## (desktop-c#qnt#d\'s conflicted copy ####-##-##).jpg', 'eyes_v01.95 (DESKTOP-C2QNT8D\'s conflicted copy 2023-02-07).jpg', '', '', '', ''],
    [   60, 'img_####-#.jpg', 'IMG_0818-2.jpg', '', '', '', ''],
    [   58, '##_###x###.png', '20_256x256.png', '', '', '', ''],
    [   56, 'screen shot ####-##-## at ##.##.##.png', 'Screen Shot 2022-09-12 at 10.53.12.png', '%Y-%m-%d', 'at', '%H.%M.%S', '(?i)(?:Screen Shot )?(\d{4}-\d{2}-\d{2} at \d{1,2}\.\d{2}\.\d{2})(?:-\d+)?.(?:png)'],
    [   54, 'cimg####.jpg', 'CIMG1487.jpg', '', '', '', ''],
    [   54, 'screenshot_########-######.png', 'Screenshot_20171214-154300.png', '%Y%m%d', '-', '%H%M%S', ''],
    [   53, 'gopr####.jpg', 'GOPR2546.JPG', '', '', '', ''],
    [   53, 'vid-########-wa####.mp#', 'VID-20230126-WA0000.mp4', '%Y%m%d', '', '', ''],
    [   46, 'whatsapp image ####-##-## at #.##.## pm.jpeg', 'WhatsApp Image 2023-04-15 at 6.41.07 PM.jpeg', '%Y-%m-%d', 'at', '%H.%M.%S %p', '(?i)(?:WhatsApp Image )?(\d{4}-\d{2}-\d{2} at \d{1,2}\.\d{2}\.\d{2} (?:PM|AM))(?:-\d+)?.(?:png|jpeg)'],
    [   45, 'thumbnail.jpg', 'Thumbnail.jpg', '', '', '', ''],
    [   43, '##########-##.jpg', '1523059275-16.jpg', '', '', '%s', '(?i)(\d{10})-(?:\d+).jpg'],
    [   43, 'imgp####.pef', 'IMGP3814.PEF', '', '', '', ''],
    [   41, '########_######-#.jpg', '20220115_173159-2.jpg', '%Y%m%d', '_', '%H%M%S', '(?i)(\d{8}_\d{6})(?:[_-]\d+)?.(?:mp4|heic|jpg)'],
    [   40, 'img_####.dng', 'IMG_1093.dng', '', '', '', ''],
    [   39, 'picture #.png', 'Picture 4.png', '', '', '', ''],
    #[   37, '##-##.png', '02-01.png', '', '', '', ''],
    #[   36, 'p#######.mov', 'P8134268.MOV', '', '', '', ''],
    #[   35, '####-##-##-#.jpg', '2015-10-23-5.jpg', '%Y-%m-%d', '', '', '(?i)(\d{4}-\d{2}-\d{2})(?:-\d+).jpg']
  ]


  TEST_DATA.each do |count, format, sample, date_format, separator, time_format, regex|
    date_present = !date_format.blank?
    date_format = '' if date_format == 'y'

    time_present = !time_format.blank?
    time_format = '' if time_format == 'y'

    it "#{format} with #{count} examples" do
      msg = [count, format, sample, date_format, separator, time_format, regex].join("\n")

      filename = Photo::File.new sample

      date_match = filename.date_patterns
      if date_present
        expect(date_match).must_be_instance_of Date
      else
        expect(date_match).must_be_nil("Date Failed on #{date_match} with: #{msg}")
      end

      time_match = filename.time_patterns
      if time_present
        expect(time_match).must_be_instance_of Time
      else
        expect(time_match).must_be_nil("Time Failed on #{time_match} with: #{msg}")
      end

      datetime_match = filename.datetime_patterns
      if date_present && time_present
        expect(datetime_match).must_be_instance_of DateTime
      end
    end

  end

end
