import os
import plistlib
import pathlib
import logging
import json
import argparse
import copy


# create the map of endpoints from mockfiles
def generate_map(mockfiles_path):
    # init an empty map object
    endpoint_map = {}

    # init header object
    # this is actually keyed including the individual file, not just the endpoint
    # this is a map between string keys and idk what
    header_map = {}

    # todo: may be a way to do this in two traversals using glob

    # walks all the mockfiles and for each creates just the leading path?

    # recursive directory traversal
    # todo: define subdir - it is the subdirectory configured (?)
    for current, dirs, files in os.walk(mockfiles_path):

        # iterate through mockfiles
        for file in files:
            # todo: open this up to all filetypes
            # should potentially change the application type
            # or do this with headers?
            # only the json files
            if not file.endswith(".json"):
                continue

            # process header files separately
            if file.endswith(".h.json"):
                with open(current + '/' + file, "r+") as headers:
                    res = json.load(headers)
                    # todo: duplicate
                    key = current.replace(mockfiles_path, "")

                    # strip the leading slash if present
                    if key.startswith("/"):
                        key = key.replace("/", "", 1)

                    # add the trailing file path for header keys
                    key = f"{get_canonical_key(key)}.{file}"

                    # not working in xcode
                    # key.removesuffix(".h.json")
                    if key.endswith('.h.json'):
                        key = key[:-7]  # ugly magic

                    header_map[key] = res
                continue

            # currently this only needs to look at files
            # and create the key from the path
            # should be a simpler api to use

            # todo: think there is a more normal way to check for only json files

            # this is to get the key from the json object path
            key = current.replace(mockfiles_path, "")

            # strip the leading slash if present
            if key.startswith("/"):
                key = key.replace("/", "", 1)

            # map is accessed here (therefore make this a function return point)
            # this logic is duplicated in the swift code
            # this does the same thing as swift code to run it
            # "get or insert"
            if key in endpoint_map:
                files = endpoint_map[key]
                files.append(file)
            else:
                endpoint_map[key] = [file]

    return (endpoint_map, header_map)


# def generate_header_map():

    # open a file with the name res and return it


def load_json_resource(res):
    logging.info(f"loading json resource: {res}")
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


# create an item to add to endpoint plist for the group header for headers
def create_headers_group_item(title):
    new_item = {}
    new_item['Type'] = 'PSGroupSpecifier'
    new_item['Title'] = title
    return new_item


# create a new item to represent a header from the key, title & value
def create_headers_item(key, title, value):
    new_item = {}
    new_item['Type'] = "PSTextFieldSpecifier" # PSTitleValueSpecifier"
    new_item['DefaultValue'] = value
    new_item['Title'] = title
    new_item["Key"] = key
    return new_item


# get resource path from canonical path of script
def get_ddmock_path(resources_path):
    path = os.path.dirname(os.path.realpath(__file__))
    path = pathlib.Path(path)
    path = path.parent.joinpath(resources_path).absolute()
    return path


# transforms some input (most likely a path) into a canonical key
# relies on the input being unique to be "canonical"
def get_canonical_key(path):
    key = path.replace("/", ".")
    return key


# creates a copy of endpoint & replaces keys
# for endpointh path and endpoint key (filename)
def create_endpoint_plist(endpoint, endpoint_path, filename, files):

    # copy a new endpoint object
    new_endpoint = copy.deepcopy(endpoint)

    logging.info(f"new endpoint: {new_endpoint}")

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
                # value can be any type, may not be string
                new_item[key] = value

        new_endpoint["PreferenceSpecifiers"][index] = new_item

    # set the mockfile "values" and "titles" fields
    for setting in filter(lambda item: item['Title'] == "Mock file", new_endpoint['PreferenceSpecifiers']):
        setting["Values"] = list(range(0, len(files)))
        setting["Titles"] = files

    return new_endpoint


def main(mockfiles_path, output_path):
    print("Running *.plist generation...")
    print(f"Path to mockfiles: {mockfiles_path}")
    print(f"Output path: {output_path}")

    path = get_ddmock_path("Resources")
    # print(f"Template path: {path}")

    # first create the map
    # this is where the directory traversal happens
    print("Creating map of endpoint paths and mock files...")
    (endpoint_map, header_map) = generate_map(mockfiles_path)

    # todo: lazy evaluation in logging
    logging.info(f" map: {endpoint_map}")

    # start creating settings bundle
    print("Creating Settings.bundle...")

    # Settings.bundle is really just a directory
    # first create directory if it doesn't exist
    if not os.path.exists(output_path):
        os.makedirs(output_path)

    # load templates
    print("Loading JSON templates...")
    root = load_json_resource(path.joinpath("root.json"))
    endpoint = load_json_resource(path.joinpath("endpoint.json"))

    # save each endpoint as a plist
    for endpoint_path, files in endpoint_map.items():

        print(f"Adding endpoint: {endpoint_path}")

        # replaces the slashes with periods for ...
        canonical_key = get_canonical_key(endpoint_path)

        # add endpoint to root plist
        new_item = create_root_item(canonical_key)
        root['PreferenceSpecifiers'].append(new_item)

        # create new endpoint object from endpoint template
        new_endpoint = create_endpoint_plist(
            endpoint, endpoint_path, canonical_key, files)

        # header generation

        # todo: this is currently not very good, selecting different mockfiles should change headers

        # check if there are any headers and add them if there are
        for file in files:
            try:
                # try and get some headers
                # this is the header key e.g. todos.get.010_title
                key = get_canonical_key(f"{endpoint_path}.{file[:-5]}")
                headers = header_map[key]

            except KeyError:
                print(f"no headers for {endpoint_path}.{file}, key: {key}")
                continue

            # use python dicts to build ios plists more easily

            # todo: list comprehension is more pythonic
            for (index, (title, value)) in enumerate(headers.items()):

                # if we survived this far, add the group settings heading
                # group specifiers are needed for the correct ordering
                group = create_headers_group_item(title)
                new_endpoint['PreferenceSpecifiers'].append(group)

                # separate items for title and value
                # keys for headers is endpoint path + header index
                # this is the oother header key
                key = get_canonical_key(f"{endpoint_path}.{file[:-5]}")
                key = f"{key}{index}_title"
                # create a new item for the header
                group = create_headers_item(key, "Title", title)
                # add the item to the list of preference specifiers
                new_endpoint['PreferenceSpecifiers'].append(group)

                key = get_canonical_key(f"{endpoint_path}.{file[:-5]}")
                key = f"{key}{index}_value"
                # create a new item for the header
                group = create_headers_item(key, "Value", value)
                # add the item to the list of preference specifiers
                new_endpoint['PreferenceSpecifiers'].append(group)

            print(f"added headers: {headers}")

        # dump the endpoint to plist
        with open(output_path + canonical_key + ".plist", "wb") as fout:
            plistlib.dump(new_endpoint, fout, fmt=plistlib.FMT_XML)

    # create general plist from json template
    print("Load general.plist template...")
    general = path.joinpath("general.json")
    general = load_json_resource(general)

    # write general plist
    print("Writing general.plist...")
    with open(os.path.join(output_path, "general.plist"), "wb") as output:
        plistlib.dump(general, output, fmt=plistlib.FMT_XML)

    # write root plist
    print("Writing Root.plist...")
    with open(output_path + "Root.plist", "wb") as output:
        plistlib.dump(root, output, fmt=plistlib.FMT_XML)

    # finished
    print("Done!")


if __name__ == "__main__":

    # create argument parser
    parser = argparse.ArgumentParser(
        description='Generate Settings.bundle for DDMockiOS')

    # 1st argument is mockfiles directory
    parser.add_argument('mockfiles_path', nargs='?',
                        default="Resources/mockfiles")

    # 2nd argument is output path
    parser.add_argument('output_path', nargs='?',
                        default="Settings.bundle/")

    # parse arguments
    args = parser.parse_args()

    # start execution
    main(args.mockfiles_path, args.output_path)
