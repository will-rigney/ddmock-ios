# DD Mock

An API mocking library for iOS.

## Getting started

1. Drag `output/DDMockiOS/` into project root folder

2. Create a new run script to target build phase and add

`python ${SRCROOT}/DDMockiOS/init.py <path_to_mock_files_directory>/mockfiles`

3. Add `DDMock.shared.initialise()` to AppDelegate

4. Add `DDMockProtocol.initialise(config: ...)` to networking library

e.g. 

```
let configuration = URLSessionConfiguration.default
// other configuration set up
DDMockProtocol.initialise(config: configuration)
```

5. Check if after first run of the app, the `Settings.bundle` file underneath the `DDMockiOS/` is added to the project. If not add this to the project.

## Building from scratch

1. Run `sh frameworkMerge.sh DDMockiOS`

2. FAT framework should be added in `output/DDMockiOS`

3. Follow Getting Started steps

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
