//
//  SoundCloudPicker.swift
//  SoundCloudPicker
//
//  Created by Aibek Mazhitov on 16.07.22.
//

import UIKit

public protocol SoundCloudPickerDelegate {
  func soundCloudPicker(_ soundCloudPicker: SoundCloudPicker, didSelectTrack track: Track)
  func soundCloudPickerDidCancel(_ soundCloudPicker: SoundCloudPicker)
}

public class SoundCloudPicker: UINavigationController {

  public var pickerDelegate: SoundCloudPickerDelegate?

  private let viewController: SoundCloudPickerViewController

  public init(configuration: SoundCloudPickerConfiguration) {
    viewController = SoundCloudPickerViewController()

    super.init(nibName: nil, bundle: nil)

    Configuration.shared = configuration
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    viewController.delegate = self
    viewControllers = [viewController]
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension SoundCloudPicker: SoundCloudPickerViewControllerDelegate {
  func soundCloudPickerViewController(_ viewController: SoundCloudPickerViewController, didSelectTrack track: Track) {
    pickerDelegate?.soundCloudPicker(self, didSelectTrack: track)
  }

  func soundCloudPickerViewControllerDidCancel(_ viewController: SoundCloudPickerViewController) {
    pickerDelegate?.soundCloudPickerDidCancel(self)
  }
}
