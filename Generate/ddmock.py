import os
import shutil
import sys
import plistlib
import pathlib
import logging
import json
import argparse

# todo: visibility

# create the map of endpoints from mockfiles


def generate_map(mockfiles_path):
    # init an empty map object
    endpoint_map = {}

    # walks all the mockfiles and for each creates just the leading path?

    # recursive directory traversal
    # todo: what is subdir
    for subdir, dirs, files in os.walk(mockfiles_path):
        print(subdir)

        # iterate through mockfiles
        for file in files:
            # only the json files
            if files.endswith(".json"):

                # todo: think there is a more normal way to check for only json files

                # create path
                # filepath = f"{subdir}/{file}"

                # this is to get the key from the json object path
                # we can do this more directly
                endpointPath = subdir.replace(mockfiles_path, "")

                # strip the leading slash if present
                # todo: presumably this is always present?
                # maybe not for relative paths
                # we should use a Path object instead
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


def replace_keys(item, path, filename):
    # todo: clarify what is happening
    # todo: make a type for these string keys
    item['DefaultValue'] = item['DefaultValue'].replace(
        "$endpointPathName", path)
    print(f"dv: {item['DefaultValue']}")
    item['Key'] = item['key'].replace("$endpointPathKey", filename)
    return item


def load_json_resource(res):
    print(f"{res}")
    res = load_json(res)
    return res


def create_item(filename):
    new_item = {}
    new_item['Type'] = 'PSChildPaneSpecifier'
    new_item['File'] = filename
    new_item['Title'] = filename
    return new_item


def main(mockfiles_path, output_path):
    cwd = os.getcwd()
    print(f"wd: {cwd}")

    # get resource path from canonical path of script
    path = os.path.dirname(os.path.realpath(__file__))
    path = pathlib.Path(path)
    path = path.parent.joinpath("Resources").absolute()
    print(f"templates: {path}")

    # first create the map
    # this is where the directory traversal happens
    print("Creating map of endpoint paths and mock files...")
    endpoint_map = generate_map(mockfiles_path)
    print(f"{endpoint_map}")

    # todo: better / dynamic configuration
    # this is from invokation site, turns out
    settings_location = output_path

    # start creating settings bundle
    # todo: what is the settings bundle & where are we creating it?
    print(f"Creating Settings.bundle at {settings_location}...")

    # Settings.bundle is really just a directory
    # first create directory if it doesn't exist
    if not os.path.exists(settings_location):
        os.makedirs(settings_location)

    # load templates
    print("Loading JSON templates...")

    root = load_json_resource(path.joinpath("root.json"))
    endpoint = load_json_resource(path.joinpath("endpoint.json"))

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

        print(f"Adding endpoint: {endpoint_path}")

        # replaces the slashes with periods for
        filename = endpoint_path.replace("/", ".")

        # add endpoint to root plist

        new_item = create_item(filename)
        root['PreferenceSpecifiers'].append(new_item)

        # create a copy of the endpoint plist replacing
        # the $endpointPathName key     -> endpointPath
        # the $indexMockFiles key       -> indexes
        # the $mockfiles key            -> files[i]
        # then write the new file at settings_location + filename + .plist

        # creating plist file for endpoint

        # make a new endpoint plist instance
        new_endpoint = endpoint

        # replace keys in all the endpoint items
        # todo: this doesn't work, try again

        new_endpoint["PreferenceSpecifiers"] = map(lambda item: replace_keys, new_endpoint["PreferenceSpecifiers"])

        # set the mockfile "values" and "titles" fields
        for setting in filter(lambda item: item['Title'] == "Mock file", new_endpoint['PreferenceSpecifiers']):
            setting["Values"] = list(range(0, len(files)))
            setting["Titles"] = files

        with open(settings_location + filename + ".plist", "wb") as fout:
            plistlib.dump(new_endpoint, fout, fmt=plistlib.FMT_XML)

    # create general plist from json
    print("Creating general.plist...")

    # load the template
    general = path.joinpath("general.json")
    general = load_json(general)

    # dump plist
    with open(os.path.join(settings_location, "general.plist"), "wb") as output:
        plistlib.dump(general, output, fmt=plistlib.FMT_XML)

    # write root plist
    print("Writing root plist...")
    with open(settings_location + "Root.plist", "wb") as output:
        plistlib.dump(root, output, fmt=plistlib.FMT_XML)

    # finished
    print("Done!")


if __name__ == "__main__":

    # parse arguments
    parser = argparse.ArgumentParser(
        description='Generate Settings.bundle for DDMockiOS')
    parser.add_argument('mockfiles_path', nargs='?',
                        default="Resources/mockfiles")
    parser.add_argument('output_path', nargs='?',
                        default="Settings.bundle/")

    args = parser.parse_args()

    # start execution
    main(args.mockfiles_path, args.output_path)
