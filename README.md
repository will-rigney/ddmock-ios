![Deloitte Digital](https://raw.githubusercontent.com/DeloitteDigitalAPAC/ddmock-ios/master/dd-logo.png)

# DDMockiOS

An API mocking library for iOS.

[![CI Status](https://img.shields.io/travis/DeloitteDigitalAPAC/ddmock-ios.svg?style=flat)](https://travis-ci.com/DeloitteDigitalAPAC/ddmock-ios)
[![Version](https://img.shields.io/cocoapods/v/DDMockiOS.svg?style=flat)](https://cocoapods.org/pods/DDMockiOS)
[![License](https://img.shields.io/cocoapods/l/DDMockiOS.svg?style=flat)](https://cocoapods.org/pods/DDMockiOS)
[![Platform](https://img.shields.io/cocoapods/p/DDMockiOS.svg?style=flat)](https://cocoapods.org/pods/DDMockiOS)

## Features

* Runtime configuration of mock responses.


## Requirements

## Installation

### CocoaPods

DDMockiOS is available through [CocoaPods](https://cocoapods.org). 
1. Add the following line to your Podfile:

```ruby
pod 'DDMockiOS'
```
2. Run `pod install`

3. Create a new run script in the target build phase and add:

```bash
python3 "${PODS_ROOT}/Generators/ddmock.py" "<path_to_mock_files_directory>/mockfiles"
```

4. Follow Getting Started steps

### Building from scratch

1. Run `sh build-xcframework.sh`

2. Framework should be added in `output/DDMockiOS`

3. Drag `output/DDMockiOS/` into project root folder

4. Create a new run script in the target build phase and add

`python "${SRCROOT}/DDMockiOS/init-mocks.py" "<path_to_mock_files_directory>/mockfiles"`

5. Follow Getting Started steps

## Getting started

1. Add `DDMock.shared.initialise()` to AppDelegate

2. Add `DDMockProtocol.initialise(config: ...)` to networking library

e.g. 

```
let configuration = URLSessionConfiguration.default
// other configuration set up
DDMockProtocol.initialise(config: configuration)
```

3. Check if after first run of the app, the `Settings.bundle` file underneath the `DDMockiOS/` is added to the project. If not add this to the project.

## Mock API files

* All API mock files must be stored under a directory called __/mockfiles__.
* The  __/mockfiles__ must be a folder reference and not a group and stored under the __Resources__ folder
* All API mock files are mapped based on the __endpoint path__ and __HTTP method__.
* e.g. login mock response file for endpoint __POST__ BASE_URL/__mobile-api/v1/auth/login__ should be stored under __mobile-api/v1/auth/login/post__
* For dynamic endpoint url, create directories with __\___ and __\___ for every replacement blocks and parameters
* e.g. mock files for __GET__ BASE_URL/__mobile-api/v1/users/\_usersId\___ should be stored under __mobile-api/v1/users/{usersId}/get__
* see `sample`
* All mock files need to be JSON files
* There can be more than one mock file stored under each endpoint path
* By default, the first file listed (alphabetically ordered) under each endpoint path is selected as the mock response

### Headers

* Headers can be configured for each endpoint by including a file named `h.json` in the endpoint directory.
* Currently only string values for header entries are supported.

## License

DDMockiOS is available under the MIT license. See the LICENSE file for more info.
