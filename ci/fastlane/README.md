fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
### deps_install
```
fastlane deps_install
```
Install dependencies
### keychain_delete
```
fastlane keychain_delete
```
Delete temporary keychain
### keychain_create
```
fastlane keychain_create
```
Create temporary keychain
### keychain_unlock
```
fastlane keychain_unlock
```
Unlock temporary keychain
### build
```
fastlane build
```
Build only
### build_ipa
```
fastlane build_ipa
```
Build and generate ipa
### app_store_token
```
fastlane app_store_token
```
Generate App Store Connect token
### testflight_upload
```
fastlane testflight_upload
```
Upload to TestFlight
### app_store_release
```
fastlane app_store_release
```
Release to App Store

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).