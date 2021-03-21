import os
import shutil
import sys

mock_files_location = sys.argv[1]
settings_location = "DDMockiOS/Settings.bundle/"

map = {}

print "Creating map of endpoint paths and mock files..."
for subdir, dirs, files in os.walk(mock_files_location):
    for file in files:
        filepath = subdir + os.sep + file
        
        if filepath.endswith(".json"):
            endpointPath = subdir.replace(mock_files_location, "")
            if endpointPath.startswith("/"):
                endpointPath = endpointPath.replace("/", "", 1)
            if endpointPath in map:
                files = map[endpointPath]
                files.append(file)
            else:
                map[endpointPath] = [file]

print "Creating Settings.bundle..."
if not os.path.exists(settings_location):
    os.makedirs(settings_location)

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
root = root + "\n\t\t\t\t<false/>"
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
    
    print "Creating plist file for " + endpointPath + "..."
    with open(settings_location + filename + ".plist", "w+") as fout:
        newplist = plist
        
        newplist = newplist.replace("$endpointPathName", endpointPath).replace("$endpointPathKey", filename)
        
        indexes = "<integer>0</integer>"
        for i in range(1, len(files)):
            indexes = indexes + "\n\t\t\t\t<integer>" + str(i) + "</integer>"
        newplist = newplist.replace("$indexMockFiles", indexes)
        
        mockFiles = "<string>" + files[0] + "</string>"
        for i in range(1, len(files)):
            mockFiles = mockFiles + "\n\t\t\t\t<string>" + files[i] + "</string>"
        newplist = newplist.replace("$mockFiles", mockFiles)

        fout.write(newplist)

print "Creating root plist..."
root = root + "\n\t</array>"
root = root + "\n</dict>"
root = root + "\n</plist>"
with open(settings_location + "Root.plist", "w+") as fout:
    fout.write(root)
print "Done!"
