# CTFd-dropbox-plugin

Plugin that converts CTFd file uploads and deletions to Dropbox calls

## Installation

1. To install clone this repository to the [CTFd/plugins](https://github.com/CTFd/CTFd/tree/master/CTFd/plugins) folder.
2. Install the requirements specified in the [requirements.txt](https://github.com/erseco/CTFd-dropbox-plugin/blob/master/requirements.txt) file.
3. Add next values as environment variables or edit [CTFd/config.py](https://github.com/CTFd/CTFd/blob/master/CTFd/config.py) to add the following entries:
  * UPLOAD_PROVIDER = "dropbox"
  * DROPBOX_OAUTH2_TOKEN = "YOUR_SECRET_TOKEN"
  * DROPBOX_ROOT_PATH = "/CTFd"

`UPLOAD_PROVIDER` set it to "dropbox" to use this plugin.

`DROPBOX_OAUTH2_TOKEN` is your Dropbox OAUTH2 secret token secret you can generate it in [Dropbox API tutorial](https://www.dropbox.com/developers/documentation/python#tutorial).

`DROPBOX_ROOT_PATH` is the root folder inside your Dropbox where to store files. Default to _/CTFd"_.

## Note

This plugin will not yet backfill any files you've uploaded. If you install the plugin after you've uploaded files, you will need to previously export backup and import to upload to Dropbox.
