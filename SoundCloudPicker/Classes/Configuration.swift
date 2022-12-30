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
  public var clientId = ""
  public var clientSecret = ""

  var apiURL = "https://api.soundcloud.com"

  public init(clientId: String, clientSecret: String) {
    self.clientId = clientId
    self.clientSecret = clientSecret
  }

  public init() {}
}
