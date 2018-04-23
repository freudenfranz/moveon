from __future__ import print_function
import os
import shutil
import sys
import traceback

class ThunderBackup:
    def __init__(self, tb_path=".thunderbird", backup_folder_name="thunderbird_backup"):
        home = os.environ['HOME']
        working_folder = os.getcwd()
        print("currently in folder %s"%os.getcwd())
        tb_path = home + '/' + tb_path

        if os.access(tb_path, os.F_OK):
            print("Accessing path %s"%tb_path)
        else:
            print("Error: Access to path \n%s\nnot granted!"%tb_path)

        #extracting profiles and profilepaths
        profiles = tb_path + "/profiles.ini"
        fd = open(profiles, 'r')
        profiles = {}
        content = fd.readline()
        name = ''
        while content:
            name_index = content.find('Name')
            if name_index >= 0:
                name = content[name_index+5:-1]

            path_index = content.find('Path')
            if path_index >= 0:
                profiles[name] = content[path_index+5:-1]

            content = fd.readline()
        print("Available Profiles are:%s"%profiles)

        #create necesery folder
        backup_folder = working_folder + '/' + backup_folder_name
        try:
            os.mkdir(backup_folder)
            print("Createt folder at %s")%backup_folder

        #except FileExistsError: #TODO make sure it works only for right exeption
        except OSError:
            print("ERROR: Backup-Folder %s already exists. Choose new name or delete folder!"%os.path.abspath(backup_folder))
            exit()

        for profile in profiles:
            print("Do you want to backup profile \'%s\'? [y/n]"%str(profile))
            choice = raw_input()
            if choice[0] == 'y':
                source_folder = tb_path +'/'+ profiles[profile]
                files = ['prefs.js', 'abook.mab', 'history.mab', 'storage.sdb', 'storage.sqlite', 'persdict.dat', 'popstate.dat', 'msgFilterRules.dat', 'training.dat', 'mailviews.dat', 'cookies.sqlite', 'local.sqlite', 'permissions.sqlite', 'key3.db']
                folders = ['extensions', 'cardbook', 'Mail', 'ImapMail']
                not_copied = []
                for f in files:
                    try:
                        full_path = source_folder+'/'+f
                        print("copying %s"%full_path, end='')
                        shutil.copy(full_path, backup_folder+'/'+f)
                        if os.access(backup_folder+'/'+f, os.F_OK):
                            print("  ..OK")
                    except IOError:
                        print("No such file %s"%f)
                        not_copied.append(f)

                for f in folders:
                    try:
                        full_path = source_folder+'/'+f
                        print("copying %s"%full_path, end='')
                        shutil.copytree(full_path, backup_folder+'/'+f, symlinks=False, ignore=None)
                        if os.access(backup_folder+'/'+f, os.F_OK):
                            print("  ..OK")
                    except IOError:
                        print("No such folder %s"%f)
                        not_copied.append(f)


                #TODO remove extensions.ini, extensions.cache extensions.
            if not_copied:
                print("List of items who have not been copied:\n%s"%not_copied)
            print("If you need any help, use http://kb.mozillazine.org/Transferring_data_to_a_new_profile_-_Thunderbird#Identify_what_you_want_to_salvage")

        '''
        if os.access(tb_path, os.F_OK):
            print("Accessing path %s")%tb_path
        else:
            print("Error: Access to path \n%s\nnot granted!")%tb_path
        '''

def main():
    backup = ThunderBackup()

if __name__ == "__main__":
    main()
