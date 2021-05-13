import os
import shutil
import sys
import plistlib
import logging
import json

# todo: document args

# todo: is this not passed straight to main
# path to mockfiles passed as argument
# e.g. IOOF/Resources/mockfiles
mock_files_location = sys.argv[1]

# todo: dynamic / configuration
# is this from cwd or root of project?
# todo: move to correct location
settings_location = "DDMockiOS/Settings.bundle/"

# create the map of endpoints from mockfiles
def generate_map():
    map = {}

    ## walks all the mockfiles and for each creates just the leading path?

    # recursive directory traversal
    # todo: what is subdir
    # damn dynamic languages
    for subdir, dirs, files in os.walk(mock_files_location):
        print(subdir)

        # iterate through mockfiles
        for file in files:

            # create path
            filepath = subdir + os.sep + file

            # only the json files
            if filepath.endswith(".json"):
                endpointPath = subdir.replace(mock_files_location, "")

                # strip the leading slash if present
                # todo: presumably this is always present? wt
                if endpointPath.startswith("/"):
                    endpointPath = endpointPath.replace("/", "", 1)

                # map is accessed here (therefore make this a function duh)
                if endpointPath in map:
                    files = map[endpointPath]
                    files.append(file)
                else:
                    map[endpointPath] = [file]

    return map


def main():
    map = generate_map()

    # todo: can we log as part of build process? is that what this does?
    # todo: yes it is
    print("Creating map of endpoint paths and mock files...")

    # start creating settings bundle
    print("Creating Settings.bundle...")

    # create file if it doesn't exist
    if not os.path.exists(settings_location):
        os.makedirs(settings_location)

    
    # todo: update to use the plist interpreter module and a model plist

    # Root plist file
    root = '<?xml version="1.0" encoding="UTF-8"?>'
    root = root + '\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">'
    root = root + '\n<plist version="1.0">'
    root = root + "\n<dict>"
    root = root + "\n\t<key>StringsTable</key>"
    root = root + "\n\t<string>Root</string>"
    root = root + "\n\t<key>PreferenceSpecifiers</key>"
    root = root + "\n\t<array>"
    root = root + "\n\t\t<dict>"
    root = root + "\n\t\t\t<key>Type</key>"
    root = root + "\n\t\t\t\t<string>PSToggleSwitchSpecifier</string>"
    root = root + "\n\t\t\t\t<key>Title</key>"
    root = root + "\n\t\t\t\t<string>Use real APIs</string>"
    root = root + "\n\t\t\t\t<key>Key</key>"
    root = root + "\n\t\t\t\t<string>use_real_apis</string>"
    root = root + "\n\t\t\t\t<key>DefaultValue</key>"
    root = root + "\n\t\t\t\t<true/>"
    root = root + "\n\t\t</dict>"
    root = root + "\n\t\t<dict>"
    root = root + "\n\t\t\t<key>Type</key>"
    root = root + "\n\t\t\t<string>PSChildPaneSpecifier</string>"
    root = root + "\n\t\t\t<key>File</key>"
    root = root + "\n\t\t\t<string>general</string>"
    root = root + "\n\t\t\t<key>Title</key>"
    root = root + "\n\t\t\t<string>General</string>"
    root = root + "\n\t\t</dict>"
    root = root + "\n\t\t<dict>"
    root = root + "\n\t\t\t<key>Type</key>"
    root = root + "\n\t\t\t<string>PSGroupSpecifier</string>"
    root = root + "\n\t\t\t<key>Title</key>"
    root = root + "\n\t\t\t<string>MOCK</string>"
    root = root + "\n\t\t</dict>"

    # Endpoints plist file
    plist = '<?xml version="1.0" encoding="UTF-8"?>'
    plist = plist + '\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">'
    plist = plist + '\n<plist version="1.0">'
    plist = plist + "\n<dict>"
    plist = plist + "\n\t<key>PreferenceSpecifiers</key>"
    plist = plist + "\n\t<array>"
    plist = plist + "\n\t\t<dict>"
    plist = plist + "\n\t\t\t<key>Type</key>"
    plist = plist + "\n\t\t\t<string>PSToggleSwitchSpecifier</string>"
    plist = plist + "\n\t\t\t<key>Title</key>"
    plist = plist + "\n\t\t\t<string>Use real API</string>"
    plist = plist + "\n\t\t\t<key>Key</key>"
    plist = plist + "\n\t\t\t<string>$endpointPathKey_use_real_api</string>"
    plist = plist + "\n\t\t\t<key>DefaultValue</key>"
    plist = plist + "\n\t\t\t<false/>"
    plist = plist + "\n\t\t</dict>"
    plist = plist + "\n\t\t<dict>"
    plist = plist + "\n\t\t\t<key>DefaultValue</key>"
    plist = plist + "\n\t\t\t<string>$endpointPathName</string>"
    plist = plist + "\n\t\t\t<key>Type</key>"
    plist = plist + "\n\t\t\t<string>PSTitleValueSpecifier</string>"
    plist = plist + "\n\t\t\t<key>Title</key>"
    plist = plist + "\n\t\t\t<string>Endpoint</string>"
    plist = plist + "\n\t\t\t<key>Key</key>"
    plist = plist + "\n\t\t\t<string>$endpointPathKey_endpoint</string>"
    plist = plist + "\n\t\t</dict>"
    plist = plist + "\n\t\t<dict>"
    plist = plist + "\n\t\t\t<key>Type</key>"
    plist = plist + "\n\t\t\t<string>PSTextFieldSpecifier</string>"
    plist = plist + "\n\t\t\t<key>DefaultValue</key>"
    plist = plist + "\n\t\t\t<string>400</string>"
    plist = plist + "\n\t\t\t<key>Title</key>"
    plist = plist + "\n\t\t\t<string>Response Time (ms)</string>"
    plist = plist + "\n\t\t\t<key>Key</key>"
    plist = plist + "\n\t\t\t<string>$endpointPathKey_response_time</string>"
    plist = plist + "\n\t\t</dict>"
    plist = plist + "\n\t\t<dict>"
    plist = plist + "\n\t\t\t<key>Type</key>"
    plist = plist + "\n\t\t\t<string>PSTextFieldSpecifier</string>"
    plist = plist + "\n\t\t\t<key>DefaultValue</key>"
    plist = plist + "\n\t\t\t<string>200</string>"
    plist = plist + "\n\t\t\t<key>Title</key>"
    plist = plist + "\n\t\t\t<string>Status Code</string>"
    plist = plist + "\n\t\t\t<key>Key</key>"
    plist = plist + "\n\t\t\t<string>$endpointPathKey_status_code</string>"
    plist = plist + "\n\t\t</dict>"
    plist = plist + "\n\t\t<dict>"
    plist = plist + "\n\t\t\t<key>Type</key>"
    plist = plist + "\n\t\t\t<string>PSMultiValueSpecifier</string>"
    plist = plist + "\n\t\t\t<key>Title</key>"
    plist = plist + "\n\t\t\t<string>Mock file</string>"
    plist = plist + "\n\t\t\t<key>Key</key>"
    plist = plist + "\n\t\t\t<string>$endpointPathKey_mock_file</string>"
    plist = plist + "\n\t\t\t<key>DefaultValue</key>"
    plist = plist + "\n\t\t\t<real>0</real>"
    plist = plist + "\n\t\t\t<key>Values</key>"
    plist = plist + "\n\t\t\t<array>"
    plist = plist + "\n\t\t\t\t$indexMockFiles"
    plist = plist + "\n\t\t\t</array>"
    plist = plist + "\n\t\t\t<key>Titles</key>"
    plist = plist + "\n\t\t\t<array>"
    plist = plist + "\n\t\t\t\t$mockFiles"
    plist = plist + "\n\t\t\t</array>"
    plist = plist + "\n\t\t</dict>"
    plist = plist + "\n\t</array>"
    plist = plist + "\n</dict>"
    plist = plist + "\n</plist>"

    for endpointPath, files in map.items():
        filename = endpointPath.replace("/", ".")
        # add endpoint to root plist
        root = root + "\n\t\t<dict>"
        root = root + "\n\t\t\t<key>Type</key>"
        root = root + "\n\t\t\t<string>PSChildPaneSpecifier</string>"
        root = root + "\n\t\t\t<key>File</key>"
        root = root + "\n\t\t\t<string>" + filename + "</string>"
        root = root + "\n\t\t\t<key>Title</key>"
        root = root + "\n\t\t\t<string>" + filename + "</string>"
        root = root + "\n\t\t</dict>"

        print("Creating plist file for " + endpointPath + "...")

        # todo: endpoints added to plist here
        with open(settings_location + filename + ".plist", "w+") as fout:
            newplist = plist

            newplist = newplist.replace("$endpointPathName", endpointPath).replace(
                "$endpointPathKey", filename)

            indexes = "<integer>0</integer>"
            for i in range(1, len(files)):
                indexes = indexes + "\n\t\t\t\t<integer>" + \
                    str(i) + "</integer>"
            newplist = newplist.replace("$indexMockFiles", indexes)

            mockFiles = "<string>" + files[0] + "</string>"
            for i in range(1, len(files)):
                mockFiles = mockFiles + "\n\t\t\t\t<string>" + \
                    files[i] + "</string>"
            newplist = newplist.replace("$mockFiles", mockFiles)

            fout.write(newplist)

    # insert: mb generate general plist? even from some config?

    # general_plist_path = "DDMockiOS/DDMockiOS/general.plist"


    # create general plist from json
    with open("DDMockiOS/resources/general.json", "r") as general:
        with open(os.path.join(settings_location, "general.plist"), "wb") as output:
            plist = plistlib.dump(general.read(), output, fmt=plistlib.FMT_XML)

    # copy static file
    # failing here because it's not from cwd or a variable
    # todo: some var for location
    # copies the "general.plist"
    # todo: generate from the lib
    # shutil.copyfile(general_plist_path,
                    # os.path.join(settings_location, "general.plist"))

    # copies from one static path to another (pointlessly?)

    # create root plist
    # todo: create this from a dictionary
    print("Creating root plist...")
    root = root + "\n\t</array>"
    root = root + "\n</dict>"
    root = root + "\n</plist>"

    # write root plist
    with open(settings_location + "Root.plist", "w+") as fout:
        fout.write(root)

    # finished
    print("Done!")


if __name__ == "__main__":
    main()
