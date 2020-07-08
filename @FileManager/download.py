# -*- coding: utf-8 -*-
"""Upload the contents of your Downloads folder to Dropbox.

This is an example app for API v2.
"""

from __future__ import print_function

import argparse
import contextlib
import datetime
import os
# import six
import sys
import time
import unicodedata
import threading
import itertools

if sys.version.startswith('2'):
    input = raw_input  # noqa: E501,F821; pylint: disable=redefined-builtin,undefined-variable,useless-suppression

import dropbox

TOKEN = ''
done=False

parser = argparse.ArgumentParser(description='Download selected files from a linked Dropbox account',
        epilog="""Example usage: (python3 download.py --token $DB_TOKEN --dropbox_path /EPIC_DATASETS/sf_post_data --local_path $PWD --params treadmillslope imutrunk /{abo6 ab08/}). Please make sure to specify a path that is not in git.""")
parser.add_argument('--dropbox_path','-dp', nargs='?', default='/EPIC_DATASETS/sf_post_data',
                    help='File Path in Dropbox')
parser.add_argument('--local_path','-lp', nargs='?', default='~/Downloads',
                    help='Local directory to upload')
parser.add_argument('--params','-p', nargs='*', default='',
                    help="""Parameters to match (not case sensitive). Pass in parameters after the param tag
                    as either words separated by spaces, strings separated by spaces, or groups of strings  or
                    spaces surrounded by \{ \}. Each separate entry will be treated as its own list to match. If
                    f represents the file in dropbox, l represents each parameter list, and s_i represents the
                    number of sub-parameters in list l, the following logic is used:
                    all(any(s_i in f for s_i in l)),
                    meaning that for a file to be slected, at least one s_i from each l must be in f.

                    Example --params treadmill \{ab01 ab02\} 'knee exo'""")
parser.add_argument('--token','-t', default=TOKEN,
                    help='Access token '
                    '(see https://www.dropbox.com/developers/apps)')
parser.add_argument('--yes', '-y', action='store_true',
                    help='Answer yes to all questions')
parser.add_argument('--no', '-n', action='store_true',
                    help='Answer no to all questions')
parser.add_argument('--default', '-d', action='store_true',
                    help='Take default answer on all questions')
parser.add_argument('--overwrite', '-o', default='n',
                    help='overwrite existing files')

def main():
    """Main program.

    Parse command line, then iterate over files and directories under
    rootdir and upload all files.  Skips some temporary files and
    directories, and avoids duplicate uploads by comparing size and
    mtime with the server.
    """
    args = parser.parse_args()
    if sum([bool(b) for b in (args.yes, args.no, args.default)]) > 1:
        print('At most one of --yes, --no, --default is allowed')
        sys.exit(2)
    if not args.token:
        print('--token is mandatory')
        sys.exit(2)

    dropbox_path = args.dropbox_path
    local_path = args.local_path

    dbx = dropbox.Dropbox(args.token)
    file_path = []
    params = []
    ind = 0

    # Parse params
    while ind < len(args.params):
        if args.params[ind].startswith('{'):
            hold = ind
            params.append([args.params[ind][1:]])
            ind += 1
            while not args.params[ind].endswith('}'):
                params[hold].append(args.params[ind])
                ind += 1
            params[hold].append(args.params[ind][:-1])
            ind += 1
        else:
            params.append([args.params[ind]])
            ind += 1
    print('Querying Dropbox with the following params:',params)
    d = yesno('Download','Y',args)

    # Find relevant folders on dropbox
    for j in params:
      for p in j:
        r = dbx.files_search(dropbox_path, p,max_results=1000)
        for x in r.matches:
            dirs = x.metadata.path_lower
            if all(any(substring in dirs for substring in sublist) for sublist in params):
                print(x.metadata.path_lower)
                allfiles = dbx.files_list_folder(dirs, recursive=True)
                download_all_files(allfiles, local_path, d, args.overwrite, dbx)
                while allfiles.has_more:
                    allfiles = dbx.files_list_folder_continue(allfiles.cursor)
                    download_all_files(allfiles, local_path, d, args.overwrite, dbx)

def download_all_files(allfiles, local_path, d, o, dbx):
    for files in allfiles.entries:
            # Make sure it is a file
            if '.' in files.path_lower:
                out_path = os.path.join(local_path, 'RawMatlab', files.path_lower[28:])
                if not os.path.isdir(os.path.dirname(out_path)):
                    os.makedirs(os.path.dirname(out_path))
                if d and (not os.path.isfile(out_path) or (os.path.isfile(out_path) and o)):
                    download(dbx, files.path_lower, out_path)

def list_folder(dbx, folder, subfolder):
    """List a folder.

    Return a dict mapping unicode filenames to
    FileMetadata|FolderMetadata entries.
    """
    path = '/%s/%s' % (folder, subfolder.replace(os.path.sep, '/'))
    while '//' in path:
        path = path.replace('//', '/')
    path = path.rstrip('/')
    try:
        with stopwatch('list_folder'):
            res = dbx.files_list_folder(path)
    except dropbox.exceptions.ApiError as err:
        print('Folder listing failed for', path, '-- assumed empty:', err)
        return {}
    else:
        rv = {}
        for entry in res.entries:
            rv[entry.name] = entry
        return rv


def download(dbx, dropbox_path, local_path):
    """Download a file.

    Return the bytes of the file, or None if it doesn't exist.

    path = '/%s/%s/%s' % (folder, subfolder.replace(os.path.sep, '/'), name)
    while '//' in path:
        path = path.replace('//', '/')
    """
    try:
        md = dbx.files_download_to_file(local_path,dropbox_path)
    except dropbox.exceptions.HttpError as err:
        print('*** HTTP error', err)
        return None
    return md

def yesno(message, default, args):
    """Handy helper function to ask a yes/no question.

    Command line arguments --yes or --no force the answer;
    --default to force the default answer.

    Otherwise a blank line returns the default, and answering
    y/yes or n/no returns True or False.

    Retry on unrecognized answer.

    Special answers:
    - q or quit exits the program
    - p or pdb invokes the debugger
    """
    if args.default:
        print(message + '? [auto]', 'Y' if default else 'N')
        return default
    if args.yes:
        print(message + '? [auto] YES')
        return True
    if args.no:
        print(message + '? [auto] NO')
        return False
    if default:
        message += '? [Y/n] '
    else:
        message += '? [N/y] '
    while True:
        answer = input(message).strip().lower()
        if not answer:
            return default
        if answer in ('y', 'yes'):
            return True
        if answer in ('n', 'no'):
            return False
        if answer in ('q', 'quit'):
            print('Exit')
            raise SystemExit(0)
        if answer in ('p', 'pdb'):
            import pdb
            pdb.set_trace()
        print('Please answer YES or NO.')

if __name__ == '__main__':
    main()
