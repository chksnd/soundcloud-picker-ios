//
//  TrackDownloader.swift
//  SoundCloudPicker
//
//  Created by Aibek Mazhitov on 16.07.22.
//

import Foundation

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
  private var id: Int = 0

  init(delegate: TrackDownloaderDelegate) {
    self.delegate = delegate
    super.init()
  }

  func download(id: Int, streamURL: String) {
    guard task == nil else {
      return
    }

    guard let url = URL(string: streamURL) else {
      return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.allHTTPHeaderFields = [
      "Authorization": "OAuth \(TokenProvider.shared.getToken())",
    ]

    task = session.downloadTask(with: request)
    task?.resume()

    self.id = id
  }

  func cancel() {
    task?.cancel()
    delegate.trackDownloaderDidCancel(self)
  }
}

extension TrackDownloader: URLSessionDownloadDelegate {
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    do {
      let documentsDirectory = try FileManager.default.url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
      )

      let tracksDirectory = documentsDirectory.appendingPathComponent("tracks", isDirectory: true)
      try FileManager.default.createDirectory(at: tracksDirectory, withIntermediateDirectories: true, attributes: nil)

      let audioURL = tracksDirectory.appendingPathComponent("\(id).mp3")

      if FileManager.default.fileExists(atPath: audioURL.path) {
        try FileManager.default.removeItem(at: audioURL)
      }

      try FileManager.default.moveItem(at: location, to: audioURL)

      self.delegate.trackDownloader(self, didFinishAt: audioURL)
    } catch {
      self.delegate.trackDownloader(self, didFailWith: error)
    }

    task = nil
  }

  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    if downloadTask == task {
      let calculatedProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
      self.delegate.trackDownloader(self, onProgress: calculatedProgress)
    }
  }
}

