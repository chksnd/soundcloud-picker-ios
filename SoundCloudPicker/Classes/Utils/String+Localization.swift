//
//  String+Localization.swift
//  SoundCloudPicker
//
//  Created by Aibek Mazhitov on 16.07.22.
//

import Foundation

extension String {
  func localized() -> String {
    NSLocalizedString(self, tableName: nil, bundle: Bundle.local, comment: "")
  }
}
