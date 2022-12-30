//
//  DataSource.swift
//  SoundCloudPicker
//
//  Created by Aibek Mazhitov on 16.07.22.
//

import Foundation

enum DataSourceError: Error {
  case invalidUrlComponents
  case invalidUrl
  case unauthorized
  case limitReached
  case noResults
  case common(_ error: Error)
}

protocol DataSourceDelegate {
  func dataSource(_ dataSource: DataSource, didSearch items: [DataSourceItem])
  func dataSource(_ dataSource: DataSource, searchDidFailed error: DataSourceError)
  func dataSource(_ dataSource: DataSource, invalidateDidFailed error: DataSourceError)
  func dataSourceDidInvalidateToken(_ dataSource: DataSource)
}

class DataSource {
  var delegate: DataSourceDelegate
  var items: [DataSourceItem] = []

  init(delegate: DataSourceDelegate) {
    self.delegate = delegate
  }

  func searchTracks(query: String) {
    guard var components = URLComponents(string: Configuration.shared.apiURL.appending("/tracks")) else {
      delegate.dataSource(self, searchDidFailed: .invalidUrlComponents)
      return
    }

    components.queryItems = [
      URLQueryItem(name: "q", value: query),
      URLQueryItem(name: "limit", value: "100"),
      URLQueryItem(name: "access", value: "playable"),
      URLQueryItem(name: "linked_partitioning", value: "true"),
    ]

    guard let url = components.url else {
      delegate.dataSource(self, searchDidFailed: .invalidUrl)
      return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.allHTTPHeaderFields = [
      "Accept": "application/json; charset=utf-8",
      "Authorization": "OAuth \(TokenProvider.shared.getToken())",
    ]

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      if let error {
        self.delegate.dataSource(self, searchDidFailed: .common(error))
        return
      }

      if let response = response as? HTTPURLResponse {
        switch response.statusCode {
        case 401:
          self.delegate.dataSource(self, searchDidFailed: .unauthorized)
          return
        case 429:
          self.delegate.dataSource(self, searchDidFailed: .limitReached)
          return
        default: ()
        }
      }

      guard let data else {
        self.delegate.dataSource(self, searchDidFailed: .noResults)
        return
      }

      do {
        let result = try JSONDecoder().decode(DataSourceResult.self, from: data)

        self.items = result.collection
        self.delegate.dataSource(self, didSearch: self.items)
      } catch {
        self.delegate.dataSource(self, searchDidFailed: .common(error))
      }
    }

    task.resume()
  }

  func invalidateToken() {
    guard let url = URL(string: Configuration.shared.apiURL.appending("/oauth2/token")) else {
      delegate.dataSource(self, invalidateDidFailed: .invalidUrl)
      return
    }

    var components = URLComponents()
    components.queryItems = [
      URLQueryItem(name: "grant_type", value: "client_credentials"),
      URLQueryItem(name: "client_id", value: Configuration.shared.clientId),
      URLQueryItem(name: "client_secret", value: Configuration.shared.clientSecret),
    ]

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = components.query?.data(using: .utf8)
    request.allHTTPHeaderFields = [
      "Content-Type": "application/x-www-form-urlencoded",
    ]

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      if let error {
        self.delegate.dataSource(self, invalidateDidFailed: .common(error))
        return
      }

      if let response = response as? HTTPURLResponse {
        switch response.statusCode {
        case 401:
          self.delegate.dataSource(self, invalidateDidFailed: .unauthorized)
          return
        case 429:
          self.delegate.dataSource(self, invalidateDidFailed: .limitReached)
          return
        default: ()
        }
      }

      guard let data else {
        self.delegate.dataSource(self, invalidateDidFailed: .noResults)
        return
      }

      do {
        let result = try JSONDecoder().decode(DataSourceAuth.self, from: data)

        TokenProvider.shared.setToken(result.access_token)
        self.delegate.dataSourceDidInvalidateToken(self)
      } catch {
        self.delegate.dataSource(self, invalidateDidFailed: .common(error))
      }
    }

    task.resume()
  }
}
