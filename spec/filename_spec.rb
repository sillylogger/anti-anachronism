require_relative "spec_helper"

describe "Filename" do

  i_suck_and_my_tests_are_order_dependent!

  before do
    # puts "before"
  end

  after do
    # puts "after"
  end

  DATA = [
      [ 7971,'########_######.jpg', '20230526_203003.jpg', '(?i)(\d{8}_\d{6}).jpg', 'TRUE', '20230526_203003' ],
      [ 6709,'img_####.jpg', 'IMG_0320.jpg', '', '', '' ],
      [ 2133,'####-##-## ##.##.##.jpg', '2017-09-03 11.42.08.jpg', '(?i)(\d{4}-\d{2}-\d{2} \d{1,2}\.\d{2}\.\d{2})(?:-\d+|-Pano)?.(?:jpg|png|mp4|dng)', 'TRUE', '2017-09-03 11.42.08' ],
      [ 1061,'dsc#####.jpg', 'DSC04187.jpg', '', '', '' ],
      [ 1005,'imgp####.jpg', 'IMGP3883.JPG', '', '', '' ],
      [ 990,'p#######.jpg', 'P4154179.JPG', '', '', '' ],
      [ 980,'dsc_####.jpg', 'DSC_0148.JPG', '', '', '' ],
      [ 953,'img-########-wa####.jpg', 'IMG-20230430-WA0074.jpg', '(?i)IMG-(\d{8})-WA\d+.jpe?g', 'TRUE', '20230430' ],
      [ 797,'########_######_hdr.jpg', '20160403_113354_HDR.jpg', '(?i)(\d{8}_\d{6})_HDR.jpg', 'TRUE', '20160403_113354' ],
      [ 687,'dscf####.jpg', 'DSCF0890.JPG', '', '', '' ],
      [ 682,'img_####.heic', 'IMG_0319.HEIC', '', '', '' ],
      [ 504,'########.jpg', '19730019.JPG', '', '', '' ],
      [ 419,'########-#.jpg', '00000076-2.JPG', '', '', '' ],
      [ 379,'########_######.mp#', '20230525_190151.mp4', '(?i)(\d{8}_\d{6})(?:_\d+)?.(?:mp4|heic)', 'TRUE', '20230525_190151' ],
      [ 347,'pc######.jpg', 'PC250376.JPG', '', '', '' ],
      [ 338,'####-##-## ##.##.##-#.jpg', '2017-09-03 11.42.09-5.jpg', '(?i)(\d{4}-\d{2}-\d{2} \d{1,2}\.\d{2}\.\d{2})(?:-\d+|-Pano)?.(?:jpg|png|mp4|dng)', 'TRUE', '2017-09-03 11.42.09' ],
      [ 252,'img_########_######.jpg', 'IMG_20221007_103823.jpg', '(?i)IMG_(\d{8}_\d{6}).jpg', 'TRUE', '20221007_103823' ],
      [ 246,'fsl_####.jpg', 'FSL_2438.JPG', '', '', '' ],
      [ 233,'img-########-wa####.jpeg', 'IMG-20230510-WA0007.jpeg', '(?i)IMG-(\d{8})-wa\d+.jpe?g', 'TRUE', '20230510' ],
      [ 201,'f#######.jpg', 'f0628376.jpg', '', '', '' ],
      [ 193,'####-##-## ##.##.##.png', '2017-03-12 03.08.52.png', '(?i)(\d{4}-\d{2}-\d{2} \d{1,2}\.\d{2}\.\d{2})(?:-\d+|-Pano)?.(?:jpg|png|mp4|dng)', 'TRUE', '2017-03-12 03.08.52' ],
      [ 132,'####-##-## ##.##.##.mp#', '2019-10-27 14.21.44.mp4', '(?i)(\d{4}-\d{2}-\d{2} \d{1,2}\.\d{2}\.\d{2})(?:-\d+|-Pano)?.(?:jpg|png|mp4|dng)', 'TRUE', '2019-10-27 14.21.44' ],
      [ 125,'dsc#####.arw', 'DSC04170.ARW', '', '', '' ],
      [ 99,'mouth.## (desktop-c#qnt#ds conflicted copy ####-##-##).png', 'mouth.65 (DESKTOP-C2QNT8Ds conflicted copy 2023-02-07).png', '', '', '' ],
      [ 85,'gfx_eq_b#_#_jt_tiny.##.png', 'GFX_EQ_b1_1_jt_tiny.94.png', '', '', '' ],
      [ 81,'########-dsc_####.jpg', '20120731-DSC_6052.jpg', '(?i)(\d{8})-DSC_\d{4}.jpg', 'TRUE', '20120731' ],
      [ 78,'########_######.heic', '20200409_211937.heic', '(?i)(\d{8}_\d{6})(?:_\d+)?.(?:mp4|heic)', 'TRUE', '20200409_211937' ],
      [ 74,'##.jpg', '58.jpg', '', '', '' ],
      [ 72,'########_######_##.mp#', '20220903_234858_99.mp4', '(?i)(\d{8}_\d{6})(?:_\d+)?.(?:mp4|heic)', 'TRUE', '20220903_234858' ],
      [ 64,'img_####.mov', 'IMG_9068.MOV', '', '', '' ],
      [ 62,'####-##-## ##.##.##-pano.dng', '2017-09-15 13.33.30-Pano.dng', '(?i)(\d{4}-\d{2}-\d{2} \d{1,2}\.\d{2}\.\d{2})(?:-\d+|-Pano)?.(?:jpg|png|mp4|dng)', 'TRUE', '2017-09-15 13.33.30' ],
      [ 61,'eyes_v##.## (desktop-c#qnt#ds conflicted copy ####-##-##).jpg', 'eyes_v01.95 (DESKTOP-C2QNT8Ds conflicted copy 2023-02-07).jpg', '', '', '' ],
      [ 60,'img_####-#.jpg', 'IMG_0818-2.jpg', '', '', '' ],
      [ 58,'##_###x###.png', '20_256x256.png', '', '', '' ],
      [ 56,'screen shot ####-##-## at ##.##.##.png', 'Screen Shot 2022-09-12 at 10.53.12.png', '(?i)(?:Screen Shot )?(\d{4}-\d{2}-\d{2} at \d{1,2}\.\d{2}\.\d{2})(?:-\d+)?.(?:png)', 'TRUE', '2022-09-12 at 10.53.12' ],
      [ 54,'cimg####.jpg', 'CIMG1487.jpg', '', '', '' ],
      [ 54,'screenshot_########-######.png', 'Screenshot_20171214-154300.png', '', '', '' ],
      [ 53,'gopr####.jpg', 'GOPR2546.JPG', '', '', '' ],
      [ 53,'vid-########-wa####.mp#', 'VID-20230126-WA0000.mp4', '', '', '' ],
      [ 46,'whatsapp image ####-##-## at #.##.## pm.jpeg', 'WhatsApp Image 2023-04-15 at 6.41.07 PM.jpeg', '(?i)(?:WhatsApp Image )?(\d{4}-\d{2}-\d{2} at \d{1,2}\.\d{2}\.\d{2} (?:PM|AM))(?:-\d+)?.(?:png|jpeg)', 'TRUE', '2023-04-15 at 6.41.07 PM' ],
      [ 45,'thumbnail.jpg', 'Thumbnail.jpg', '', '', '' ],
      [ 43,'##########-##.jpg', '1523059275-16.jpg', :pending, '(?i)(\d{10})-(?:\d+).jpg', 'TRUE', '1523059275' ],
      [ 43,'imgp####.pef', 'IMGP3814.PEF', '', '', '' ],
      [ 41,'########_######-#.jpg', '20220115_173159-2.jpg', '(?i)(\d{8}_\d{6})(?:[_-]\d+)?.(?:mp4|heic|jpg)', 'TRUE', '20220115_173159' ],
      [ 40,'img_####.dng', 'IMG_1093.dng', '', '', '' ],
      [ 39,'picture #.png', 'Picture 4.png', '', '', '' ],
      [ 37,'##-##.png', '02-01.png', '', '', '' ],
      [ 36,'p#######.mov', 'P8134268.MOV', '', '', '' ],
      [ 35,'####-##-##-#.jpg', '2015-10-23-5.jpg', '(?i)(\d{4}-\d{2}-\d{2})(?:-\d+).jpg', 'TRUE', '2015-10-23' ],
      [ 34,'##########-#.jpg', '1523035601-2.jpg', :pending, '(?i)(\d{10})-(?:\d+).jpg', 'TRUE', '1523035601' ],
      [ 33,'sugarloaf##.jpg', 'sugarloaf18.jpg', '', '', '' ],
      [ 32,'########_######_###.jpg', '20230113_152749_001.jpg', :pending, '', '', '' ],
      [ 31,'mvi_####.mov', 'MVI_0117.MOV', '', '', '' ],
      [ 31,'st#-#.tiff', 'st1-4.tiff', '', '', '' ],
      [ 31,'st#.tiff', 'st0.tiff', '', '', '' ],
      [ 30,'#march####-##.png', '4march2015-30.png', '', '', '' ],
      [ 30,'carrie furnace ##.jpg', 'Carrie Furnace 29.jpg', '', '', '' ],
      [ 30,'img_####_#_#_tonemapped.jpg', 'IMG_3825_6_7_tonemapped.jpg', '', '', '' ],
      [ 30,'whatsapp image ####-##-## at ##.##.##.jpeg', 'WhatsApp Image 2019-08-19 at 21.32.01.jpeg', '', '', '' ],
      [ 29,'########_######-pano.dng', '20200725_171234-Pano.dng', '', '', '' ],
      [ 29,'##-##.jpg', '05-31.jpg', '', '', '' ],
      [ 29,'scan_########_##.jpg', 'Scan_20190606_34.jpg', '', '', '' ],
      [ 28,'gopr#### copy.jpg', 'GOPR1195 copy.JPG', '', '', '' ],
      [ 27,'img_########_######_###.jpg', 'IMG_20221104_212700_703.jpg', :pending, '', '', '' ],
      [ 27,'photo ##-##-#### ## ## ##.jpg', 'Photo 25-03-2015 14 22 51.jpg', :pending, '', '', '' ],
      [ 26,'dorm##.jpg', 'dorm82.jpg', '', '', '' ],
      [ 23,'########_######_##.jpg', '20220903_234858_01.jpg', :pending, '', '' ],
      [ 23,'core-################-##.jpg', 'core-1524646984163049-34.jpg', '', '', '' ],
      [ 23,'screenshot_########-######.jpg', 'Screenshot_20220822-190552.jpg', '', '', '' ],
      [ 22,'########_######(#).jpg', '20221118_220707(0).jpg', '', '', '' ],
      [ 22,'###.jpg', '118.jpg', '', '', '' ],
      [ 19,'########-r#######.jpg', '20220226-R0006029.jpg', '', '', '' ],
      [ 19,'droppedimage-##.tiff', 'droppedImage-35.tiff', '', '', '' ],
      [ 19,'screenshot_####-##-##-##-##-##.png', 'Screenshot_2016-03-05-07-39-08.png', '', '', '' ],
      [ 19,'whatsapp image ####-##-## at #.##.## pm (#).jpeg', 'WhatsApp Image 2020-03-14 at 6.14.03 PM (1).jpeg', '', '', '' ],
      [ 18,'burn_iris##.tif', 'burn_iris00.tif', '', '', '' ],
      [ 17,'####-##-##.jpg', '2017-05-18.jpg', '', '', '' ],
      [ 17,'dixmont ##.jpg', 'Dixmont 17.jpg', '', '', '' ],
      [ 17,'gh######.mp#', 'GH012580.MP4', '', '', '' ],
      [ 16,'####-##-##-##.jpg', '2017-08-25-13.jpg', :pending, '', '' ],
      [ 15,'####-##-##-##-##.jpg', '2017-09-15-22-40.jpg', '', '', '' ],
      [ 14,'####-##-##-######.jpg', '2023-05-23-174617.jpg', :pending, '', '' ],
      [ 14,'#.##.## ###.jpg', '3.19.06 015.jpg', '', '', '' ],
      [ 13,'####-##-## ##.##.##-#.mp#', '2017-09-03 11.29.57-6.mp4', :pending, '', '' ],
      [ 13,'screen shot ####-##-## at #.##.## pm.png', 'Screen Shot 2017-05-05 at 5.28.32 PM.png', :pending, '', '' ],
      [ 12,'########_######_burst##.jpg', '20160305_150955_Burst01.jpg', '', '', '' ],
      [ 12,'burn_anim##.tif', 'burn_anim00.tif', '', '', '' ],
      [ 12,'g#######.jpg', 'G0042562.JPG', '', '', '' ],
      [ 12,'img_####.m#v', 'IMG_6970.m4v', '', '', '' ],
      [ 12,'img_####.mp#', 'IMG_4614.mp4', '', '', '' ],
      [ 12,'img_####_#_#_fused.jpg', 'IMG_4070_1_2_fused.jpg', '', '', '' ],
      [ 12,'imgp####-#.jpg', 'IMGP3509-2.JPG', '', '', '' ],
      [ 12,'scan_########_#-#-#.jpg', 'Scan_20190606_6-2-2.jpg', '', '', '' ],
      [ 12,'scan_########_#-#.jpg', 'Scan_20190606_6-2.jpg', '', '', '' ],
      [ 11,'########-##.jpg', '00000001-10.JPG', '', '', '' ],
      [ 11,'mirror##.jpg', 'mirror17.jpg', '', '', '' ],
      [ 11,'screen shot ####-##-## at ##.##.## am.png', 'Screen Shot 2015-01-16 at 11.00.06 AM.png', :pending, '', '' ],
      [ 11,'screenshot_########-######_chrome.jpg', 'Screenshot_20220815-190823_Chrome.jpg', :pending, '', '' ],
      [ 10,'badge_lvl_##.png', 'badge_lvl_90.png', '', '', '' ],
      [ 10,'google-accounts-#.png', 'google-accounts-9.png', '', '', '' ]
    ]

  DATA.each do |count, format, sample, regex, matches, match|

    it "#{format} with #{count} examples is #{match}" do
      skip("stash pop dulu 😅, you had a ton of formatting you need to finish, then group regex by parts / formats") if regex == :pending

      filename = Filename.new sample
      # expect(filename.match).must_be match

      if match == ''
        expect(filename.time).must_be_nil
      else
        expect(filename.time).must_be_instance_of DateTime

        time = Time.find_zone("Jakarta").parse(match).to_datetime
        expect(filename.time).must_equal time
        # _(n).must_be_close_to m [, delta]
      end
    end

  end

end
