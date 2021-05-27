# Zatcher

[![Build Status](https://github.com/lzackx/Zatcher/actions/workflows/ci.yml/badge.svg)](https://github.com/lzackx/Zatcher/actions)
[![Version](https://img.shields.io/cocoapods/v/Zatcher.svg?style=flat)](https://cocoapods.org/pods/Zatcher)
[![License](https://img.shields.io/cocoapods/l/Zatcher.svg?style=flat)](https://cocoapods.org/pods/Zatcher)
[![Platform](https://img.shields.io/cocoapods/p/Zatcher.svg?style=flat)](https://cocoapods.org/pods/Zatcher)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Zatcher is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Zatcher', :path => '../../../../Z/Repositories/Zatcher/', :subspecs => ['Core', 'OrderGenerator']

post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['OTHER_CFLAGS'] = '-fsanitize-coverage=func,trace-pc-guard'
			config.build_settings['OTHER_SWIFT_FLAGS'] = '-sanitize-coverage=func -sanitize=undefined'
		end
	end
end
```

## Author

lzackx, lzackx@lzackx.com

## License

Zatcher is available under the MIT license. See the LICENSE file for more info.
