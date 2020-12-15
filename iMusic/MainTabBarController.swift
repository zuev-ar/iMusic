//
//  MainTabBarController.swift
//  iMusic
//
//  Created by Arkasha Zuev on 21.10.2020.
//

import UIKit

protocol MainTabBarControllerDelegate: class {
    func minimizedTrackDetailController()
}

class MainTabBarController: UITabBarController {
    
    private var minimizedTopAnchorConstraint: NSLayoutConstraint!
    private var maximizedTopAnchorConstraint: NSLayoutConstraint!
    private var bottomAnchorConstraint: NSLayoutConstraint!
    
    let searchVC: SearchViewController = SearchViewController.loadFromStoryboard()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupTrackDetailView()
        
        view.backgroundColor = .white
        
        tabBar.tintColor = #colorLiteral(red: 1, green: 0, blue: 0.3764705882, alpha: 1)
        
        viewControllers = [
            generateViewController(rootViewController: searchVC, image: #imageLiteral(resourceName: "search"), title: "Search"),
            generateViewController(rootViewController: ViewController(), image: #imageLiteral(resourceName: "library"), title: "Library")
        ]
        
    }
    
    private func generateViewController(rootViewController: UIViewController, image: UIImage, title: String) -> UIViewController {
        
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        
        navigationVC.tabBarItem.image = image
        navigationVC.tabBarItem.title = title
        navigationVC.navigationBar.prefersLargeTitles = true
        
        rootViewController.navigationItem.title = title
        
        return navigationVC
        
    }
    
    private func setupTrackDetailView() {
        
        let trackDetailView: TrackDetailView = TrackDetailView.loadFromNib()
        
        trackDetailView.tabBarDelegate = self
        trackDetailView.delegate = searchVC
        
        view.insertSubview(trackDetailView, belowSubview: tabBar)
        
        trackDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        maximizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: view.topAnchor)
        minimizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        bottomAnchorConstraint = trackDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        bottomAnchorConstraint.isActive = true
        
        maximizedTopAnchorConstraint.isActive = true
        
//        trackDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        trackDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        trackDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
    }
    
}

extension MainTabBarController: MainTabBarControllerDelegate {
    
    func minimizedTrackDetailController() {
        maximizedTopAnchorConstraint.isActive = false
        minimizedTopAnchorConstraint.isActive = true
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
                        self.view.layoutIfNeeded()
                       },
                       completion: nil)
    }
    
}
