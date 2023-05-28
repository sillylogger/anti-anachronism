## Anti-Anachronism; Google Photo Edition

Have you moved from Adobe Lightroom to Google Photos because Lightroom is *rife* with sync issues? 🙋
Are you fed up with your Photo timeline's cronological inconsistency?! 🙋
Well say no more!

Simply, checkout this project and hack around until you've wasted your weekend!

## todo
- [x] Pull all your albums and photos down from Google Photos
- [x] Write the metadata to a CSV, upload to Google Sheets: [here](https://docs.google.com/spreadsheets/d/1KJ3bmt1csh_zfdnxMHveVQKlVgu0Ww78XuhaeFWAg0I/edit#gid=1936910659)
- [ ] Write a bunch of regular expressions to compare creationTime with a DateTime from the filename
      Need to match the most specific regex first, otherwise truncating information like the time part of the filename
- [ ] Fix the mediaMetadata of one photo on Google Photos via console
- [ ] Fix *aaaallll* ...

### Setup

Explain how to get the credentials.json for the GoogleAuth..

### Development

Still sorting things out now.. 😅

```
./query.rb
```

#### Stats

