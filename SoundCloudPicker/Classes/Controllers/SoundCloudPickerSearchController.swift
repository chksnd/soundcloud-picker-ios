//
//  SoundCloudSearchController.swift
//  SoundCloudPicker
//
//  Created by Aibek Mazhitov on 16.07.22.
//

import UIKit

class SoundCloudPickerSearchController: UISearchController {
  lazy var customSearchBar = CustomSearchBar(frame: CGRect.zero)

  override var searchBar: UISearchBar {
    customSearchBar.showsCancelButton = false
    return customSearchBar
  }
}

class CustomSearchBar: UISearchBar {
  override func setShowsCancelButton(_ showsCancelButton: Bool, animated: Bool) {
    super.setShowsCancelButton(false, animated: false)
  }
}
