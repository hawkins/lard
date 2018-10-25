# Lard

:green_book: A third-party command line interface for larder.io

Note: This project is a work-in-progress, and as such, may not be fully functional quite yet.

![Screenshot of Lard 0.0.0 folder view for 'Coding'](screenshots/folder.png)

## Installation

To install, simply run `gem install lard`. Then, you can run the binary by calling `lard`.

Next, create a `~/.lard.yml` file with the contents copied from `lard.example.yml` in this repo.

Replace the example token (it won't work!) with your own from the link provided in the example file.

## Features

Checked boxes represent minimally viable completed features, meaning they are feature complete but may leave room for future improvement:

- [x] Log in with your application token in a config file
- [x] List all of your folders
- [x] List all of the bookmarks in a folder
- [x] Search for specific bookmarks
- [x] Create a new bookmark
- [x] Edit existing bookmarks
- [x] List all tags
- [ ] Export bookmarks
- [ ] Import bookmarks
- [ ] Operate offline via cache
- [ ] Login via command line to store in dotfile
