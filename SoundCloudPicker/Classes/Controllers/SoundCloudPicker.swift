//
//  SoundCloudPicker.swift
//  SoundCloudPicker
//
//  Created by Aibek Mazhitov on 16.07.22.
//

import UIKit

public protocol SoundCloudPickerDelegate {
  func soundCloudPicker(_ soundCloudPicker: SoundCloudPicker, didSelectTrack url: URL)
  func soundCloudPickerDidCancel(_ soundCloudPicker: SoundCloudPicker)
  func soundCloudPickerLimitReached(_ soundCloudPicker: SoundCloudPicker)
}

public class SoundCloudPicker: UINavigationController {
  public var pickerDelegate: SoundCloudPickerDelegate?

  private let viewController: SoundCloudPickerViewController

  public init(configuration: SoundCloudPickerConfiguration) {
    viewController = SoundCloudPickerViewController()

    super.init(nibName: nil, bundle: nil)

    Configuration.shared = configuration
  }

  override public func viewDidLoad() {
    super.viewDidLoad()

    viewController.delegate = self
    viewControllers = [viewController]
  }

  @available(*, unavailable)
  public required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension SoundCloudPicker: SoundCloudPickerViewControllerDelegate {
  func soundCloudPickerViewController(_: SoundCloudPickerViewController, didSelectTrack url: URL) {
    pickerDelegate?.soundCloudPicker(self, didSelectTrack: url)
  }

  func soundCloudPickerViewControllerDidCancel(_: SoundCloudPickerViewController) {
    pickerDelegate?.soundCloudPickerDidCancel(self)
  }

  func soundCloudPickerViewControllerLimitReached(_: SoundCloudPickerViewController) {
    pickerDelegate?.soundCloudPickerLimitReached(self)
  }
}
