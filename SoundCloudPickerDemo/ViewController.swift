//
//  ViewController.swift
//  SoundCloudPickerDemo
//
//  Created by Aibek Mazhitov on 16.07.22.
//

import AVFoundation
import SoundCloudPicker
import UIKit

class ViewController: UIViewController {
  @IBOutlet var artwork: UIImageView!
  @IBOutlet var artist: UILabel!
  @IBOutlet var trackName: UILabel!

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

  @IBAction func handleClickOpen(_: Any) {
    present(picker, animated: true)
  }
}

extension ViewController: SoundCloudPickerDelegate {
  func soundCloudPicker(_: SoundCloudPicker, didSelectTrack url: URL) {
    dismiss(animated: true)

    print("--- track url:")
    print(url)
    print("")

    let asset = AVAsset(url: url)
    print("--- common metadata:")
    for item in asset.commonMetadata {
      guard let key = item.commonKey else {
        continue
      }
      switch key {
      case .commonKeyTitle:
        print("title: \(item.stringValue!)")
        trackName.text = item.stringValue
      case .commonKeyArtist:
        artist.text = item.stringValue
        print("artist: \(item.stringValue!)")
      case .commonKeyArtwork:
        artwork.image = UIImage(data: item.dataValue!)
        print("artwork: \(UIImage(data: item.dataValue!))")
      default: continue
      }
    }
  }

  func soundCloudPickerDidCancel(_: SoundCloudPicker) {
    dismiss(animated: true)
  }
}
