//
//  Configuration.swift
//  SoundCloudPicker
//
//  Created by Aibek Mazhitov on 16.07.22.
//

import Foundation

struct Configuration {
  static var shared: SoundCloudPickerConfiguration = .init()
}

public struct SoundCloudPickerConfiguration {
  public static let defaultMemoryCapacity: Int = FileCache.memoryCapacity
  public static let defaultDiskCapacity: Int = FileCache.diskCapacity

  public var clientId = ""
  public var clientSecret = ""
  public var memoryCapacity = defaultMemoryCapacity
  public var diskCapacity = defaultDiskCapacity

  var apiURL = "https://api.soundcloud.com"

  public init(
    clientId: String,
    clientSecret: String,
    memoryCapacity: Int = defaultMemoryCapacity,
    diskCapacity: Int = defaultDiskCapacity
  ) {
    self.clientId = clientId
    self.clientSecret = clientSecret
    self.memoryCapacity = memoryCapacity
    self.diskCapacity = diskCapacity
  }

  public init() {}
}
