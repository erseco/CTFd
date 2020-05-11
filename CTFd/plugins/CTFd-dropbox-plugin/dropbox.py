import os
import string

from dropbox import Dropbox
from dropbox.files import FolderMetadata, WriteMode

from flask import current_app, redirect
from flask.helpers import safe_join
from werkzeug.utils import secure_filename

from CTFd.utils import get_app_config
from CTFd.utils.encoding import hexencode
from CTFd.utils import uploads
from CTFd.utils.uploads.uploaders import BaseUploader


class DropboxUploader(BaseUploader):
    def __init__(self):
        super(BaseUploader, self).__init__()
        self.oauth2_access_token = os.getenv("DROPBOX_OAUTH2_TOKEN") or get_app_config(
            "DROPBOX_OAUTH2_TOKEN"
        )
        self.root_path = (
            os.getenv("DROPBOX_ROOT_PATH")
            or get_app_config("DROPBOX_ROOT_PATH")
            or "/CTFd"
        )
        self.client = Dropbox(self.oauth2_access_token, timeout=100)
        self.write_mode = "add"  # can be set to overwrite

    def _clean_filename(self, c):
        if c in string.ascii_letters + string.digits + "-" + "_" + ".":
            return True

    def _full_path(self, name):
        return safe_join(self.root_path, name).replace("\\", "/")

    def store(self, fileobj, filename):
        self.client.files_upload(
            fileobj.read(), self._full_path(filename), mode=WriteMode(self.write_mode)
        )
        return filename

    def upload(self, file_obj, filename):
        filename = filter(
            self._clean_filename, secure_filename(filename).replace(" ", "_")
        )
        filename = "".join(filename)
        if len(filename) <= 0:
            return False

        md5hash = hexencode(os.urandom(16))

        dst = md5hash + "/" + filename
        self.store(file_obj, dst)
        return dst

    def download(self, filename):
        media = self.client.files_get_temporary_link(self._full_path(filename))
        print(media.link)
        return redirect(media.link)

    def delete(self, filename):
        directory = os.path.dirname(self._full_path(filename))
        self.client.files_delete(directory)
        return True

    def sync(self):
        local_folder = current_app.config.get("UPLOAD_FOLDER")

        root_metadata = self.client.files_list_folder(self.root_path)

        for folder_entry in root_metadata.entries:
            if isinstance(folder_entry, FolderMetadata):
                filemetadata = self.client.files_list_folder(folder_entry.path_lower)
                for file_entry in filemetadata.entries:
                    if not isinstance(file_entry, FolderMetadata):

                        dropbox_path = file_entry.path_lower.replace(
                            self.root_path.lower() + "/", ""
                        )
                        local_path = os.path.join(local_folder, dropbox_path)
                        directory = os.path.dirname(local_path)
                        if not os.path.exists(directory):
                            os.makedirs(directory)

                        self.client.files_download_to_file(
                            local_path, file_entry.path_lower
                        )


def load(app):
    uploads.UPLOADERS.update({"dropbox": DropboxUploader})
