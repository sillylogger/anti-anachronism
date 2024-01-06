## Anti-Anachronism; Google Photo Edition

Have you moved from Adobe Lightroom to Google Photos because Lightroom is *rife* with sync issues? 🙋  
Are you fed up with your Photo timeline's cronological inconsistency?! 🙋  
Well say no more!

Simply:
1. Checkout this project
2. Yak shave model responsibilities
3. Remember Google Photo's API doesn't support upating photos that weren't uploaded by the app.
> <https://developers.google.com/photos/library/guides/manage-media>:  
> To change a media item's description, your app must have uploaded the media item.
4. Decide ***f^(&-it*** and write a script to update photos creation time via the photos.google.com website 🤣 🤦

## TODO
- [x] Pull all your albums and photos down from Google Photos
- [x] Write the metadata to a CSV, upload to Google Sheets: [here](https://docs.google.com/spreadsheets/d/1KJ3bmt1csh_zfdnxMHveVQKlVgu0Ww78XuhaeFWAg0I/edit#gid=1936910659)
- [x] Fix the mediaMetadata of one photo on Google Photos via console => **🤦 not possible** per [issue tracker](https://issuetracker.google.com/issues?q=status:open%20componentid:385336%20edit)
- [x] Add the DateTime from filename to the CSV
- [x] Wahhh use Selenium to automate fixing these through the Google Photos ui 🤣 🤦
- [x] Make the VCR recording at a per-request level, not for all Albums / Photos, that way you can query new items more easily
- [x] photo.rb's #to_csv accessing `file.matcher` doesn't exist... you need to expose that 
- [x] Write more complete specs for the DateTime from filename



