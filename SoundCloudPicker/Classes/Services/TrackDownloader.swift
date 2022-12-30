//
//  TrackDownloader.swift
//  SoundCloudPicker
//
//  Created by Aibek Mazhitov on 16.07.22.
//

import AVFoundation
import Foundation

enum TrackDownloaderError: Error {
  case common(String)
}

protocol TrackDownloaderDelegate {
  func trackDownloader(_ trackDownloader: TrackDownloader, onProgress progress: Float)
  func trackDownloader(_ trackDownloader: TrackDownloader, didFinishAt audioURL: URL)
  func trackDownloader(_ trackDownloader: TrackDownloader, didFailWith error: Error)
  func trackDownloaderDidCancel(_ trackDownloader: TrackDownloader)
}

class TrackDownloader: NSObject {
  private lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

  private var delegate: TrackDownloaderDelegate
  private var task: URLSessionDownloadTask?
  private var item: DataSourceItem?

  init(delegate: TrackDownloaderDelegate) {
    self.delegate = delegate
    super.init()
  }

  func download(item: DataSourceItem) {
    guard task == nil else {
      return
    }

    guard let url = URL(string: item.stream_url) else {
      return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.allHTTPHeaderFields = [
      "Authorization": "OAuth \(TokenProvider.shared.getToken())",
    ]

    task = session.downloadTask(with: request)
    task?.resume()

    self.item = item
  }

  func cancel() {
    task?.cancel()
    delegate.trackDownloaderDidCancel(self)
  }
}

extension TrackDownloader: URLSessionDownloadDelegate {
  func urlSession(_: URLSession, downloadTask _: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    do {
      let documentsDirectory = try FileManager.default.url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
      )

      let tracksDirectory = documentsDirectory.appendingPathComponent("sc", isDirectory: true)
      try FileManager.default.createDirectory(at: tracksDirectory, withIntermediateDirectories: true, attributes: nil)

      let audioURL = tracksDirectory.appendingPathComponent("\(item!.id).mp3")
      let exportURL = tracksDirectory.appendingPathComponent("\(item!.id).m4a")

      if FileManager.default.fileExists(atPath: audioURL.path) {
        try FileManager.default.removeItem(at: audioURL)
      }

      if FileManager.default.fileExists(atPath: exportURL.path) {
        try FileManager.default.removeItem(at: exportURL)
      }

      try FileManager.default.moveItem(at: location, to: audioURL)

      let asset = AVAsset(url: audioURL)

      guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
        delegate.trackDownloader(self, didFailWith: TrackDownloaderError.common("can't create export session"))
        return
      }

      exporter.outputURL = exportURL
      exporter.outputFileType = .m4a
      exporter.metadata = createMetadata(forItem: item!)
      exporter.timeRange = CMTimeRangeMake(start: .zero, duration: asset.duration)
      exporter.exportAsynchronously {
        if exporter.status == .completed {
          self.delegate.trackDownloader(self, didFinishAt: exportURL)

          do {
            try FileManager.default.removeItem(at: audioURL)
          } catch {
            //
          }
          return
        }

        if exporter.status == .cancelled {
          self.delegate.trackDownloaderDidCancel(self)
          return
        }

        self.delegate.trackDownloader(self, didFailWith: TrackDownloaderError.common("export failed with: \(exporter.error!)"))
      }
    } catch {
      delegate.trackDownloader(self, didFailWith: error)
    }

    task = nil
  }

  func urlSession(_: URLSession, downloadTask: URLSessionDownloadTask, didWriteData _: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    if downloadTask == task {
      let calculatedProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
      delegate.trackDownloader(self, onProgress: calculatedProgress)
    }
  }

  private func createMetadata(forItem item: DataSourceItem) -> [AVMetadataItem] {
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
