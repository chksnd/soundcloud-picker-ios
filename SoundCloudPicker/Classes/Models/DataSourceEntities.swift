//
//  DataSourceEntities.swift
//  SoundCloudPicker
//
//  Created by Aibek Mazhitov on 16.07.22.
//

import Foundation

struct DataSourceItemUser: Decodable {
  var username: String
}

struct DataSourceItem: Decodable {
  var id: Int
  var streamable: Bool
  var stream_url: String
  var artwork_url: String?
  var title: String
  var user: DataSourceItemUser
  var duration: Int
}

struct DataSourceResult: Decodable {
  var collection: [DataSourceItem]
}

struct DataSourceAuth: Decodable {
  var access_token: String
  var refresh_token: String
  var expires_in: Int
  var token_type: String
  var scope: String
}
