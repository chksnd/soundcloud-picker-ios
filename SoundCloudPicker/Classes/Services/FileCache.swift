//
//  FileCache.swift
//  SoundCloudPicker
//
//  Created by Aibek Mazhitov (aimazhdev@gmail.com) on 30.12.22.
//  Copyright © 2022. All rights reserved.

import UIKit

class FileCache {
  static let cache: URLCache = {
    let diskPath = "soundcloud"
    let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    let cacheURL = cachesDirectory.appendingPathComponent(diskPath, isDirectory: true)
    return URLCache(
      memoryCapacity: Configuration.shared.memoryCapacity,
      diskCapacity: Configuration.shared.diskCapacity,
      directory: cacheURL
    )
  }()

  static let memoryCapacity: Int = 50.megabytes
  static let diskCapacity: Int = 100.megabytes
}

private extension Int {
  var megabytes: Int { self * 1024 * 1024 }
}
