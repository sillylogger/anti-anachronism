# Project Brief

## Core Requirements and Goals
- This project checks and corrects Google Photos' inaccurate date and time metadata by parsing the photos filename.  The project has three flows:
1. Retrieving all of my Google Photos' media items and storing that information in a CSVs.
2. Parsing photos' filenames for the original creation date and time, comparing that to Google Photos' metadata, calculating the difference in date, storing that information in the original CSV.
3. Reading a CSV of photos to be corrected, opening a web browser, and updating the photo's metadata through Google Photos UI -- because they do not have an API for metadata editing.

## Scope
- Improvements in parsing datetime information from filenames, ideally this is done through a library as opposed to flaky regex calls.
- Improvements in the robustness of browser interactions with Google Photos' UI.
- Improvements in project file / folder structure.
