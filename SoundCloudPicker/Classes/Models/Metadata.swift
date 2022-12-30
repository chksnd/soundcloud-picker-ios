//
//  Metadata.swift
//  SoundCloudPicker
//
//  Created by Aibek Mazhitov (aimazhdev@gmail.com) on 30.12.22.
//  Copyright © 2022. All rights reserved.

import AVFoundation
import Foundation

extension DataSourceItem {
  func getMetadata() -> [AVMetadataItem] {
    let item = self

    var map: [NSString: NSObject] = [
      AVMetadataKey.commonKeyAlbumName as NSString: item.title as NSString,
      AVMetadataKey.commonKeyTitle as NSString: item.title as NSString,
      AVMetadataKey.commonKeyArtist as NSString: item.user.username as NSString,
    ]

    if let artworkURL = URL(string: item.artwork_url!) {
      map[AVMetadataKey.commonKeyArtwork as NSString] = try? Data(contentsOf: artworkURL) as NSData
    }

    var metadata: [AVMetadataItem] = []

    for (key, value) in map {
      let item = AVMutableMetadataItem()
      item.keySpace = .common
      item.key = key

      if key == AVMetadataKey.commonKeyArtwork as NSString {
        item.value = value as! NSData
      } else {
        item.value = value as! NSString
      }

      metadata.append(item)
    }

    return metadata
  }
}
