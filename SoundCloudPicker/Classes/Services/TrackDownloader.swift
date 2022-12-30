//
//  TrackDownloader.swift
//  SoundCloudPicker
//
//  Created by Aibek Mazhitov on 16.07.22.
//

import AVFoundation
import Foundation
import UIKit

enum TrackDownloaderError: Error {
  case common(String)
}

protocol TrackDownloaderDelegate {
  func trackDownloader(_ downloader: TrackDownloader, onProgress progress: Float)
  func trackDownloader(_ downloader: TrackDownloader, didFinishAt url: URL)
  func trackDownloader(_ downloader: TrackDownloader, didFailWith error: Error)
  func trackDownloaderDidCancel(_ downloader: TrackDownloader)
  func trackDownloaderWillExport(_ downloader: TrackDownloader)
}

protocol TrackDownloader {
  func download(item: DataSourceItem)
  func cancel()
}

class DefaultTrackDownloader: NSObject, TrackDownloader {
  private lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
  private var task: URLSessionDownloadTask?
  private let cache = FileCache.cache
  private var currentItem: DataSourceItem?
  private var delegate: TrackDownloaderDelegate

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

    if let cachedResponse = cache.cachedResponse(for: request) {
      let location = FileManager.default.temporaryDirectory.appendingPathComponent(item.id.description)
      if FileManager.default.fileExists(atPath: location.path) {
        try? FileManager.default.removeItem(at: location)
      }

      try? cachedResponse.data.write(to: location)

      handleDownloadedFile(forItem: item, atURL: location)
      return
    }

    task = session.downloadTask(with: request)
    task?.resume()

    // store current item
    currentItem = item
  }

  func cancel() {
    task?.cancel()
    delegate.trackDownloaderDidCancel(self)
  }
}

extension DefaultTrackDownloader: URLSessionDownloadDelegate {
  func urlSession(_: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    guard let item = currentItem, let response = downloadTask.response, let request = downloadTask.originalRequest else {
      return
    }

    let cachedResponse = CachedURLResponse(response: response, data: try! Data(contentsOf: location))
    cache.storeCachedResponse(cachedResponse, for: request)

    handleDownloadedFile(forItem: item, atURL: location)

    task = nil
  }

  func urlSession(_: URLSession, downloadTask: URLSessionDownloadTask, didWriteData _: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    if downloadTask == task {
      let calculatedProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
      delegate.trackDownloader(self, onProgress: calculatedProgress)
    }
  }
}

extension DefaultTrackDownloader {
  func handleDownloadedFile(forItem item: DataSourceItem, atURL url: URL) {
    delegate.trackDownloaderWillExport(self)

    do {
      let exportURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(item.id).m4a")
      let audioURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(item.id).mp3")

      // clean up tmp files
      [exportURL, audioURL].forEach {
        if FileManager.default.fileExists(atPath: $0.path) {
          try? FileManager.default.removeItem(at: $0)
        }
      }

      try FileManager.default.moveItem(at: url, to: audioURL)

      let asset = AVAsset(url: audioURL)

      guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
        delegate.trackDownloader(self, didFailWith: TrackDownloaderError.common("can't create export session"))
        return
      }

      exporter.outputURL = exportURL
      exporter.outputFileType = .m4a
      exporter.metadata = item.getMetadata()
      exporter.timeRange = CMTimeRangeMake(start: .zero, duration: asset.duration)
      exporter.exportAsynchronously {
        if exporter.status == .completed {
          self.delegate.trackDownloader(self, didFinishAt: exportURL)

          if FileManager.default.fileExists(atPath: audioURL.path) {
            try? FileManager.default.removeItem(at: audioURL)
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
  }
}
