//
//  SoundCloudPickerViewController.swift
//  SoundCloudPicker
//
//  Created by Aibek Mazhitov on 16.07.22.
//

import UIKit

protocol SoundCloudPickerViewControllerDelegate {
  func soundCloudPickerViewController(_ viewController: SoundCloudPickerViewController, didSelectTrack track: Track)
  func soundCloudPickerViewControllerDidCancel(_ viewController: SoundCloudPickerViewController)
}

public class SoundCloudPickerViewController: UIViewController {

  // MARK: - View attributes

  private lazy var cancelBarButtonItem: UIBarButtonItem = {
    return UIBarButtonItem(
      barButtonSystemItem: .cancel,
      target: self,
      action: #selector(handleTapBarButtonItemCancel)
    )
  }()

  private lazy var searchController: SoundCloudPickerSearchController = {
    let controller = SoundCloudPickerSearchController(searchResultsController: nil)
    controller.delegate = self
    controller.obscuresBackgroundDuringPresentation = false
    controller.hidesNavigationBarDuringPresentation = false
    controller.searchBar.delegate = self
    controller.searchBar.placeholder = "search.placeholder".localized()
    controller.searchBar.autocapitalizationType = .none
    return controller
  }()

  private lazy var tableView: UITableView = {
    let view = UITableView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.dataSource = self
    view.delegate = self
    view.register(TableCell.self, forCellReuseIdentifier: TableCell.reuseIdentifier)
    return view
  }()

  private let spinner: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .medium)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.hidesWhenStopped = true
    return view
  }()

  private lazy var emptyView: EmptyView = {
    let view = EmptyView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  lazy var downloadDialog: UIAlertController = {
    let controller = UIAlertController(title: "download.title".localized(), message: "0%", preferredStyle: .alert)
    controller.addAction(UIAlertAction(title: "download.cancel".localized(), style: .cancel) { _ in
      self.trackDownloader.cancel()
    })
    return controller
  }()

  lazy var downloadProgress: UIProgressView = {
    let view = UIProgressView(progressViewStyle: .bar)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.progress = 0.0
    return view
  }()

  // MARK: - Logic attributes

  var delegate: SoundCloudPickerViewControllerDelegate?

  lazy var dataSource = DataSource(delegate: self)
  lazy var trackDownloader = TrackDownloader(delegate: self)

  var selectedIndex: Int = -1 {
    didSet {
      if selectedIndex < 0 {
        return
      }

      let item = dataSource.items[selectedIndex]

      DispatchQueue.global().async {
        self.trackDownloader.download(id: item.id, streamURL: item.stream_url)
      }

      present(downloadDialog, animated: true)
    }
  }

  private var searchText: String? {
    didSet {
      refresh()
      scrollToTop()
      hideEmptyView()
    }
  }

  // MARK: - View Life Cycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    setupNotifications()
    setupView()
    setupNavigationBar()
    setupSearchController()
    setupTableView()
    setupSpinner()
    setupDownloadingProgress()
  }

  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    searchController.dismiss(animated: true)
  }

  // MARK: - Setup

  private func setupNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }

  private func setupView() {
    view.backgroundColor = .systemBackground
  }

  private func setupNavigationBar() {
    title = "search.title".localized()
    navigationItem.leftBarButtonItem = cancelBarButtonItem
  }

  private func setupSearchController() {
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    definesPresentationContext = true
    extendedLayoutIncludesOpaqueBars = true
  }

  private func setupTableView() {
    view.addSubview(tableView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
    ])
  }

  private func setupSpinner() {
    view.addSubview(spinner)

    NSLayoutConstraint.activate([
      spinner.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
      spinner.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
    ])
  }

  private func setupDownloadingProgress() {
    if let view = downloadDialog.view {
      view.addSubview(downloadProgress)

      NSLayoutConstraint.activate([
        downloadProgress.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -45),
        downloadProgress.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        downloadProgress.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      ])
    }
  }

  private func showEmptyView(with state: EmptyViewState) {
    guard emptyView.superview == nil else {
      return
    }

    spinner.stopAnimating()

    emptyView.state = state
    view.addSubview(emptyView)

    NSLayoutConstraint.activate([
      emptyView.topAnchor.constraint(equalTo: view.topAnchor),
      emptyView.leftAnchor.constraint(equalTo: view.leftAnchor),
      emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      emptyView.rightAnchor.constraint(equalTo: view.rightAnchor)
    ])
  }

  private func hideEmptyView() {
    emptyView.removeFromSuperview()
  }

  // MARK: - Actions

  @objc private func handleTapBarButtonItemCancel(_ sender: Any) {
    searchController.searchBar.resignFirstResponder()
    delegate?.soundCloudPickerViewControllerDidCancel(self)
  }

  private func scrollToTop() {
    let contentOffset = CGPoint(x: 0, y: -tableView.safeAreaInsets.top)
    tableView.setContentOffset(contentOffset, animated: false)
  }

  // MARK: - Data

  private func setSearchText(_ text: String?) {
    searchText = text
  }

  @objc func refresh() {
    guard let query = searchText else {
      return
    }

    spinner.startAnimating()

    DispatchQueue.global().async {
      self.dataSource.searchTracks(query: query)
    }
  }

  func reloadData() {
    tableView.reloadData()
  }

  // MARK: - Notifications

  @objc func keyboardWillShowNotification(_ notification: Notification) {
    guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.size,
          let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
          }

    let bottomInset = keyboardSize.height - view.safeAreaInsets.bottom
    let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: bottomInset, right: 0.0)

    UIView.animate(withDuration: duration) { [weak self] in
      self?.tableView.contentInset = contentInsets
      self?.tableView.scrollIndicatorInsets = contentInsets
    }
  }

  @objc func keyboardWillHideNotification(_ notification: Notification) {
    guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }

    UIView.animate(withDuration: duration) { [weak self] in
      self?.tableView.contentInset = .zero
      self?.tableView.scrollIndicatorInsets = .zero
    }
  }
}

// MARK: - UISearchBarDelegate

extension SoundCloudPickerViewController: UISearchBarDelegate {
  public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    setSearchText(searchBar.text)
  }
}

// MARK: - UISearchControllerDelegate

extension SoundCloudPickerViewController: UISearchControllerDelegate {}

// MARK: - DataSourceDelegate

extension SoundCloudPickerViewController: DataSourceDelegate {
  func dataSource(_ dataSource: DataSource, didSearch items: [DataSourceItem]) {
    #if DEBUG
    print("dataSource.didSearch")
    #endif

    DispatchQueue.main.async {
      self.spinner.stopAnimating()
      self.reloadData()

      if items.isEmpty {
        self.showEmptyView(with: .noResults)
      }
    }
  }

  func dataSource(_ dataSource: DataSource, searchDidFailed error: DataSourceError) {
    #if DEBUG
    print("dataSource.searchDidFailed: \(error)")
    #endif

    DispatchQueue.main.async {
      self.spinner.stopAnimating()

      switch error {
      case .unauthorized:
        self.spinner.startAnimating()

        DispatchQueue.global().async {
          self.dataSource.invalidateToken()
        }
      case .limitReached: self.showEmptyView(with: .limitReached)
      case .noResults: self.showEmptyView(with: .noResults)
      default: self.showEmptyView(with: .serverError)
      }
    }
  }

  func dataSource(_ dataSource: DataSource, invalidateDidFailed error: DataSourceError) {
    #if DEBUG
    print("dataSource.invalidateDidFailed: \(error)")
    #endif

    DispatchQueue.main.async {
      self.spinner.stopAnimating()

      switch error {
      case .limitReached: self.showEmptyView(with: .limitReached)
      default: self.showEmptyView(with: .serverError)
      }
    }
  }

  func dataSourceDidInvalidateToken(_ dataSource: DataSource) {
    #if DEBUG
    print("dataSource.didInvalidateToken")
    #endif

    DispatchQueue.main.async {
      self.spinner.stopAnimating()
      self.refresh()
    }
  }
}

extension SoundCloudPickerViewController: TrackDownloaderDelegate {
  func trackDownloader(_ trackDownloader: TrackDownloader, didFailWith error: Error) {
    #if DEBUG
    print("trackDownloader.didFailWith: \(error)")
    #endif
    DispatchQueue.main.async {
      self.downloadDialog.dismiss(animated: true)
    }
  }

  func trackDownloader(_ trackDownloader: TrackDownloader, didFinishAt audioURL: URL) {
    #if DEBUG
    print("trackDownloader.didFinishAt: \(audioURL)")
    #endif
    DispatchQueue.main.async {
      self.downloadDialog.dismiss(animated: true) {
        let item = self.dataSource.items[self.selectedIndex]

        var artworkURL: URL?
        if let url = item.artwork_url {
          artworkURL = URL(string: url)
        }

        self.delegate?.soundCloudPickerViewController(self, didSelectTrack: Track(
          artist: item.user.username,
          title: item.title,
          audioURL: audioURL,
          artworkURL: artworkURL
        ))

        self.selectedIndex = -1
      }
    }
  }

  func trackDownloader(_ trackDownloader: TrackDownloader, onProgress progress: Float) {
    DispatchQueue.main.async {
      self.downloadProgress.progress = progress
      self.downloadDialog.message = String.init(format: "%0.0f", progress * 100).appending("%")
    }
  }

  func trackDownloaderDidCancel(_ trackDownloader: TrackDownloader) {
    #if DEBUG
    print("trackDownloader.didCancel")
    #endif
  }
}
