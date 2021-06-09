import os
import shutil
import sys
import plistlib
import pathlib
import logging
import json
import argparse

# create the map of endpoints from mockfiles


def generate_map(mockfiles_path):
    endpoint_map = {}

    # walks all the mockfiles and for each creates just the leading path?

    # recursive directory traversal
    # todo: what is subdir
    for subdir, dirs, files in os.walk(mockfiles_path):
        print(subdir)

        # iterate through mockfiles
        for file in files:

            # create path
            filepath = subdir + os.sep + file

            # only the json files
            if filepath.endswith(".json"):
                endpointPath = subdir.replace(mockfiles_path, "")

                # strip the leading slash if present
                # todo: presumably this is always present? wt
                if endpointPath.startswith("/"):
                    endpointPath = endpointPath.replace("/", "", 1)

                # map is accessed here (therefore make this a function duh)
                # this does the same thing as swift code to run it
                # "get or insert"
                if endpointPath in endpoint_map:
                    files = endpoint_map[endpointPath]
                    files.append(file)
                else:
                    endpoint_map[endpointPath] = [file]

    return endpoint_map


def load_json(path):
    with open(path, "r") as file:
        return json.load(file)


def main(mockfiles_path):
    cwd = os.getcwd()
    print(f"wd: {cwd}")

    # get resource path from canonical path of script
    path = os.path.dirname(os.path.realpath(__file__))
    path = pathlib.Path(path)
    path = path.parent.joinpath("Resources").absolute()
    print(f"path: {path}")

    # first create the map
    # this is where the directory traversal happens
    print("Creating map of endpoint paths and mock files...")
    endpoint_map = generate_map(mockfiles_path)

    # start creating settings bundle
    # todo: what is the settings bundle & where are we creating it?
    print("Creating Settings.bundle...")

    # todo: args in python are weird, need to check their usage

    # todo: dynamic / configuration
    # is this from cwd or root of project?
    # todo: this should come from arguments
    settings_location = "Settings.bundle/"

    # Settings.bundle is really just a directory
    # first create directory if it doesn't exist
    if not os.path.exists(settings_location):
        os.makedirs(settings_location)

    # load templates
    print("Loading JSON templates...")

    root = path.joinpath("root.json")
    root = load_json(root)

    endpoint = path.joinpath("endpoint.json")
    endpoint = load_json(endpoint)

    # ** short circuit for testing

#    with open(settings_location + "Root.plist", "rb") as root:
    # with open("resources/endpoint.json", "w+") as output:
    #     plist_bytes = plist.encode(encoding='utf-8')
    #     plist = plistlib.loads(plist_bytes, fmt=plistlib.FMT_XML)
    #     json.dump(plist, output, indent=4)
    #     print("dumped root json")

    # return

    # **
    # for path & files in map
    for endpoint_path, files in endpoint_map.items():

        print(f"Creating endpoint plist for {endpoint_path}...")
        # replaces the slashes with periods for
        filename = endpoint_path.replace("/", ".")

        print(root)

        # add endpoint to root plist
        new_item = {}
        new_item['Type'] = 'PSChildPaneSpecifier'
        new_item['File'] = filename
        new_item['Title'] = filename

        root['PreferenceSpecifiers'].append(new_item)

        # create a copy of the endpoint plist replacing
        # the $endpointPathName key     -> endpointPath
        # the $indexMockFiles key       -> indexes
        # the $mockfiles key            -> files[i]
        # then write the new file at settings_location + filename + .plist

        # creating plist file for endpoint
        print("Creating plist file for " + endpoint_path + "...")

        def replaceKeys(item, path, filename):
            # todo: clarify what is happening
            item['DefaultValue'] = item['key'].replace(
                "$endpointPathName", path)
            item['Key'] = item['key'].replace("$endpointPathKey", filename)

        # todo: endpoints added to plist here
        with open(settings_location + filename + ".plist", "wb") as fout:
            new_endpoint = endpoint

            map(lambda item: replaceKeys, new_endpoint["PreferenceSpecifiers"])

            # newplist = newplist.replace("$endpointPathName", endpointPath).replace(
            #     "$endpointPathKey", filename)

            # indexes = "<integer>0</integer>"
            for setting in filter(lambda item: item['Title'] == "Mock file", new_endpoint['PreferenceSpecifiers']):
                setting["Values"] = list(range(0, len(files)))
                setting["Titles"] = files
            #     indexes = indexes + "\n\t\t\t\t<integer>" + \
            #         str(i) + "</integer>"
            # newplist = newplist.replace("$indexMockFiles", indexes)

            # mockFiles = "<string>" + files[0] + "</string>"
            # for i in range(1, len(files)):
            #     mockFiles = mockFiles + "\n\t\t\t\t<string>" + \
            #         files[i] + "</string>"
            # newplist = newplist.replace("$mockFiles", mockFiles)

            plistlib.dump(new_endpoint, fout, fmt=plistlib.FMT_XML)
            # fout.write(new_endpoint)

    # insert: mb generate general plist? even from some config?

    # general_plist_path = "DDMockiOS/DDMockiOS/general.plist"

    # create general plist from json
    # this could be from
    print("Creating general.plist...")
    general = path.joinpath("general.json")
    general = load_json(general)
    with open(os.path.join(settings_location, "general.plist"), "wb") as output:
        plistlib.dump(general, output, fmt=plistlib.FMT_XML)
    # copy static file
    # failing here because it's not from cwd or a variable
    # todo: some var for location
    # copies the "general.plist"
    # todo: generate from the lib
    # shutil.copyfile(general_plist_path,
        # os.path.join(settings_location, "general.plist"))

    # copies from one static path to another (pointlessly?)

    # close the plist
    # root = root + "\n\t</array>"
    # root = root + "\n</dict>"
    # root = root + "\n</plist>"

    # write root plist
    with open(settings_location + "Root.plist", "wb") as output:
        print("Writing root plist...")
        plistlib.dump(root, output, fmt=plistlib.FMT_XML)

    # finished
    print("Done!")


if __name__ == "__main__":

    # parse arguments
    parser = argparse.ArgumentParser(
        description='Generate Settings.bundle for DDMockiOS')
    parser.add_argument('mockfiles_path', nargs='?',
                        default="DDMockiOS/resources/mockfiles")

    args = parser.parse_args()

    # start execution
    main(args.mockfiles_path)
