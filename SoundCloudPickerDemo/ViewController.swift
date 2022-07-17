//
//  ViewController.swift
//  SoundCloudPickerDemo
//
//  Created by Aibek Mazhitov on 16.07.22.
//

import UIKit
import SoundCloudPicker

class ViewController: UIViewController {

  var picker: SoundCloudPicker!

  override func viewDidLoad() {
    super.viewDidLoad()

    let conf = SoundCloudPickerConfiguration(
      clientId: ProcessInfo.processInfo.environment["CLIENT_ID"] ?? "",
      clientSecret: ProcessInfo.processInfo.environment["CLIENT_SECRET"] ?? ""
    )

    picker = SoundCloudPicker(configuration: conf)
    picker.pickerDelegate = self
  }

  @IBAction func handleClickOpen(_ sender: Any) {
    present(picker, animated: true)
  }
}

extension ViewController: SoundCloudPickerDelegate {
  func soundCloudPicker(_ soundCloudPicker: SoundCloudPicker, didSelectTrack track: Track) {
    print("--- track info:")
    print(track)
    print("---")
    dismiss(animated: true)
  }

  func soundCloudPickerDidCancel(_ soundCloudPicker: SoundCloudPicker) {
    dismiss(animated: true)
  }
}
