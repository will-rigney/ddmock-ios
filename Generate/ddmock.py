import os
import shutil
import sys
import plistlib
import pathlib
import logging
import json
import argparse
import copy



# todo: visibility


# create the map of endpoints from mockfiles
def generate_map(mockfiles_path):
    # init an empty map object
    endpoint_map = {}

    # walks all the mockfiles and for each creates just the leading path?

    # recursive directory traversal
    # todo: define subdir - it is the subdirectory configured (?)
    for current, dirs, files in os.walk(mockfiles_path):

        # iterate through mockfiles
        for file in files:
            # only the json files
            if not file.endswith(".json"):
                continue

            # currently this only needs to look at files
            # and create the key from the path
            # should be a simpler api to use

            # todo: think there is a more normal way to check for only json files

            # this is to get the key from the json object path
            endpointPath = current.replace(mockfiles_path, "")

            # strip the leading slash if present
            if endpointPath.startswith("/"):
                endpointPath = endpointPath.replace("/", "", 1)

            # map is accessed here (therefore make this a function return point)
            # this logic is duplicated in the swift code
            # this does the same thing as swift code to run it
            # "get or insert"
            if endpointPath in endpoint_map:
                files = endpoint_map[endpointPath]
                files.append(file)
            else:
                endpoint_map[endpointPath] = [file]

    return endpoint_map


# open a file with the name res and return it
def load_json_resource(res):
    print(f"{res}")
    with open(res, "r") as file:
        res = json.load(file)
    return res


# pure function returns an object to add to root preference specifier
def create_root_item(filename):
    new_item = {}
    new_item['Type'] = 'PSChildPaneSpecifier'
    new_item['File'] = filename
    new_item['Title'] = filename
    return new_item


# get resource path from canonical path of script
def get_ddmock_path(resources_path):
    path = os.path.dirname(os.path.realpath(__file__))
    path = pathlib.Path(path)
    path = path.parent.joinpath(resources_path).absolute()
    return path


def create_endpoint_plist(endpoint, endpoint_path, filename, files):

    # copy a new endpoint object
    new_endpoint = copy.deepcopy(endpoint)

    print(f"new endpoint: {new_endpoint}")

    # replace variable keys in all the endpoint items

    # for each item in preference specifiers list
    for index, item in enumerate(new_endpoint["PreferenceSpecifiers"]):
        # construct a new item
        new_item = {}
        # for every key value par in the item dict
        for key, value in item.items():
            try:
                new_value = value.replace(
                    "$endpointPathName", f"{endpoint_path}")
                new_value = new_value.replace("$endpointPathKey", filename)
                new_item[key] = new_value
            except AttributeError:
                # value can be any type
                new_item[key] = value

        new_endpoint["PreferenceSpecifiers"][index] = new_item

    # set the mockfile "values" and "titles" fields
    for setting in filter(lambda item: item['Title'] == "Mock file", new_endpoint['PreferenceSpecifiers']):
        setting["Values"] = list(range(0, len(files)))
        setting["Titles"] = files

    return new_endpoint


def main(mockfiles_path, output_path):
    path = get_ddmock_path("Resources")
    print(f"Template path: {path}")

    # first create the map
    # this is where the directory traversal happens
    print("Creating map of endpoint paths and mock files...")
    endpoint_map = generate_map(mockfiles_path)

    print(f"{endpoint_map}")

    # todo: better / dynamic configuration
    settings_location = output_path

    # start creating settings bundle
    print(f"Creating Settings.bundle at {settings_location}...")

    # Settings.bundle is really just a directory
    # first create directory if it doesn't exist
    if not os.path.exists(settings_location):
        os.makedirs(settings_location)

    # load templates
    print("Loading JSON templates...")

    root = load_json_resource(path.joinpath("root.json"))
    endpoint = load_json_resource(path.joinpath("endpoint.json"))

    # save each endpoint as a plist
    for endpoint_path, files in endpoint_map.items():

        print(f"Adding endpoint: {endpoint_path}")

        # replaces the slashes with periods for ...
        filename = endpoint_path.replace("/", ".")

        # add endpoint to root plist
        new_item = create_root_item(filename)
        root['PreferenceSpecifiers'].append(new_item)

        # create new endpoint object from endpoint template
        new_endpoint = create_endpoint_plist(
            endpoint, endpoint_path, filename, files)

        # dump the endpoint to plist
        with open(settings_location + filename + ".plist", "wb") as fout:
            plistlib.dump(new_endpoint, fout, fmt=plistlib.FMT_XML)

    # create general plist from json template
    print("Load general.plist template...")
    general = path.joinpath("general.json")
    general = load_json_resource(general)

    # write general plist
    print("Writing general.plist...")
    with open(os.path.join(settings_location, "general.plist"), "wb") as output:
        plistlib.dump(general, output, fmt=plistlib.FMT_XML)

    # write root plist
    print("Writing Root.plist...")
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
