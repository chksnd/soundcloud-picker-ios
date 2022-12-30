Pod::Spec.new do |spec|
  spec.name           = "SoundCloudPicker"
  spec.version        = "1.0.3"
  spec.summary        = "SoundCloudPicker is an iOS UI component that allows you to quickly search the SoundCloud tracks with just a few lines of code."
  spec.license        = { :type => "MIT" }
  spec.homepage       = "https://github.com/chksnd/soundcloud-picker-ios"
  spec.author         = { "Aibek Mazhitov" => "aimazhdev@gmail.com" }
  spec.source         = { :git => "https://github.com/chksnd/soundcloud-picker-ios.git", :tag => "#{spec.version}" }
  spec.source_files   = "SoundCloudPicker/**/*.{h,m,swift,xib,strings,stringsdict}"
  spec.exclude_files  = "SoundCloudPickerDemo"
  spec.frameworks     = "Foundation", "UIKit"
  spec.platform       = :ios, "13.0"
  spec.requires_arc   = true
  spec.swift_version  = "5.6.1"
end