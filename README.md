# SoundCloud Picker for iOS

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SoundCloudPicker.svg?style=flat-square)](https://cocoapods.org/pods/SoundCloudPicker)
[![Platform](https://img.shields.io/cocoapods/p/SoundCloudPicker.svg?style=flat-square)](https://github.com/chksnd/soundcloud-picker-ios)
[![License](https://img.shields.io/github/license/chksnd/soundcloud-picker-ios.svg?style=flat-square)](https://github.com/chksnd/soundcloud-picker-ios)

SoundCloudPicker is an iOS UI component that allows you to quickly search the SoundCloud tracks with just a few lines of code.

## Description

SoundCloudPicker is a view controller. You present it to offer your users to search and use tracks from [SoundCloud](https://soundcloud.com). Once they have selected track, the picker downloads it and the view controller returns the track info a `URL` object that you can use for further purposes.

## Requirements

- iOS 13.0+
- Xcode 13.4+
- Swift 5.6+

## Installation

### CocoaPods

To integrate SoundCloudPicker into your Xcode project using [CocoaPods](https://cocoapods.org), specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'SoundCloudPicker'
end
```

Then run `pod install`.

## Usage

⚠️ Before you get started, you need to register as a developer on [SoundCloud for Developers](https://developers.soundcloud.com/) portal. Once registered, create a new app to get an **Client ID** and a **Client Secret**.

### Configuration

The `SoundCloudPicker` is configured with an instance of `SoundCloudPickerConfiguration`:

```swift
SoundCloudPickerConfiguration(clientId: String, clientSecret: String)
```

|Property|Type|Optional/Required|Default|
|--------|----|-----------------|-------|
|**`clientId`**|_String_|Required|N/A|
|**`clientSecret`**|_String_|Required|N/A|

### Presenting

`SoundCloudPicker` is a subclass of `UINavigationController`. We recommend that you present it modally or as a popover on iPad. Before presenting it, you need to implement the `SoundCloudPickerDelegate` protocol, and use the `pickerDelegate` property to get the results.

```swift
protocol SoundCloudPickerDelegate {
  func soundCloudPicker(_ soundCloudPicker: SoundCloudPicker, didSelectTrack url: URL)
  func soundCloudPickerDidCancel(_ soundCloudPicker: SoundCloudPicker)
}
```

### Using the results

`SoundCloudPicker` returns a `URL` object that represents the track information including *artist*, *title*, and *artwork* within metadata of the file.

## License

MIT License

Copyright (c) ChkSnd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
