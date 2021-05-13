import plistlib
import json

def create_general_plist():
    print("creating plist in future")


def plist_to_json(path):

    with open(path, "rb") as general:
        # string = general.read()
        # print(string)
        plist = plistlib.load(general, fmt=plistlib.FMT_XML)
        print(plist)
        with open("general.json", "w") as output:
            json.dump(plist, output, indent=4)