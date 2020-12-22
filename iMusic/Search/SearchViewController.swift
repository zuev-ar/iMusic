//
//  SearchViewController.swift
//  iMusic
//
//  Created by Arkasha Zuev on 22.10.2020.
//  Copyright (c) 2020 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol SearchDisplayLogic: class {
    func displayData(viewModel: Search.Model.ViewModel.ViewModelData)
}

class SearchViewController: UIViewController, SearchDisplayLogic {
    
    var interactor: SearchBusinessLogic?
    var router: (NSObjectProtocol & SearchRoutingLogic)?
    
    let searchController = UISearchController(searchResultsController: nil)
    
    weak var tabBarDelegate: MainTabBarControllerDelegate?
    
    private lazy var footerView = FooterView()
    
    private var searchViewModel = SearchViewModel.init(cells: [])
    private var timer: Timer?
    
    @IBOutlet weak var table: UITableView!
    
    // MARK: Setup
    
    private func setup() {
        let viewController        = self
        let interactor            = SearchInteractor()
        let presenter             = SearchPresenter()
        let router                = SearchRouter()
        viewController.interactor = interactor
        viewController.router     = router
        interactor.presenter      = presenter
        presenter.viewController  = viewController
        router.viewController     = viewController
    }
    
    // MARK: Routing
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupTableView()
        setupSearchingBar()
        searchBar(searchController.searchBar, textDidChange: "Eminem")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let keyWindow = UIApplication.shared.connectedScenes.filter({
            $0.activationState == .foregroundActive
        }).map({
            $0 as? UIWindowScene
        }).compactMap ({ $0 }).first?.windows.filter({ $0.isKeyWindow }).first
        
        let tabBarVC = keyWindow?.rootViewController as? MainTabBarController
        tabBarVC?.trackDetailView.delegate = self
        
    }
    
    private func setupSearchingBar() {
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        
    }
    
    private func setupTableView() {
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        let nib = UINib(nibName: "TrackCell", bundle: nil)
        table.register(nib, forCellReuseIdentifier: TrackCell.reuseId)
        table.tableFooterView = footerView
    }
    
    func displayData(viewModel: Search.Model.ViewModel.ViewModelData) {
        
        switch viewModel {
        case .displayTracks(let searchViewModel):
            self.searchViewModel = searchViewModel
            table.reloadData()
            footerView.hideLoader()
        case .displayFooterView:
            footerView.showLoader()
        }
        
    }
    
}

// MARK - UITableViewDelegate, UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModel.cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: TrackCell.reuseId, for: indexPath) as! TrackCell
        let cellViewModel = searchViewModel.cells[indexPath.row]
        cell.set(viewModel: cellViewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellViewModel = searchViewModel.cells[indexPath.row]
        self.tabBarDelegate?.maximizeTrackDetailController(viewModel: cellViewModel)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let lable = UILabel()
        lable.text = "Please enter search term above..."
        lable.textAlignment = .center
        lable.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return lable
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return searchViewModel.cells.count > 0 ? 0 : 250
    }
    
}
// MARK - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            self.interactor?.makeRequest(request: Search.Model.Request.RequestType.getTracks(searchTerm: searchText))
        })
    }
    
}

extension SearchViewController: TrackMovingDelegate {
    
    private func getTrack(isForwardTrack: Bool) -> SearchViewModel.Cell? {
        
        guard let indexPath = table.indexPathForSelectedRow else { return nil }
        
        table.deselectRow(at: indexPath, animated: true)
        
        var nextIndexPath: IndexPath!
        
        if isForwardTrack {
            nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            if nextIndexPath.row == searchViewModel.cells.count {
                nextIndexPath.row = 0
            }
        } else {
            nextIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            if nextIndexPath.row == -1 {
                nextIndexPath.row = searchViewModel.cells.count - 1
            }
        }
        
        table.selectRow(at: nextIndexPath, animated: true, scrollPosition: .none)
        let cellViewModel = searchViewModel.cells[nextIndexPath.row]
        
        return cellViewModel
        
    }
    
    func moveBackForPreviousTrack() -> SearchViewModel.Cell? {
        return getTrack(isForwardTrack: false)
    }
    
    func moveForwardForPreviousTrack() -> SearchViewModel.Cell? {
        return getTrack(isForwardTrack: true)
    }
    
}
