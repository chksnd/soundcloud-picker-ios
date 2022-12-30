//
//  TokenProvider.swift
//  SoundCloudPicker
//
//  Created by Aibek Mazhitov on 16.07.22.
//

import Foundation

class TokenProvider {
  static let shared = TokenProvider()

  private let soundCloudTokenKey = "sctk"

  private init() {}

  func getToken() -> String {
    guard let encoded = UserDefaults.standard.string(forKey: soundCloudTokenKey) else {
      return ""
    }
    return decode(encoded)
  }

  func setToken(_ token: String) {
    UserDefaults.standard.set(encode(token), forKey: soundCloudTokenKey)
  }

  private func encode(_ string: String) -> String {
    let encoded = Data(string.utf8).base64EncodedString()
    return Data(encoded.utf8).base64EncodedString()
  }

  private func decode(_ encoded: String) -> String {
    var data = Data(base64Encoded: encoded)!
    data = Data(base64Encoded: data)!
    return String(data: data, encoding: .utf8)!
  }
}
