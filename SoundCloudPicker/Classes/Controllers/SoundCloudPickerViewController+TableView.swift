//
//  SoundCloudPickerViewController+TableView.swift
//  SoundCloudPicker
//
//  Created by Aibek Mazhitov on 16.07.22.
//

import UIKit

extension SoundCloudPickerViewController: UITableViewDataSource {
  public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    dataSource.items.count
  }

  public func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let item = dataSource.items[indexPath.row]

    let cell = TableCell(style: .subtitle, reuseIdentifier: TableCell.reuseIdentifier)
    cell.textLabel?.text = item.title
    cell.detailTextLabel?.text = item.user.username

    return cell
  }
}

extension SoundCloudPickerViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    selectedIndex = indexPath.row
  }
}
