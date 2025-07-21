//
//  SceneDelegate.swift
//  CareerLog
//
//  Created by Lee Jinhee on 5/25/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        window?.tintColor = .accent
        showMainSplitView()
        window?.makeKeyAndVisible()
    }
    
    private func showMainSplitView() {
        let splitVC = makeMainSplitViewController()
        window?.rootViewController = splitVC
    }
    
    func showLoginView() {
        let loginVC = LoginViewController()
        loginVC.delegate = self
        let nav = UINavigationController(rootViewController: loginVC)
        window?.rootViewController = nav
    }
    
    private func makeMainSplitViewController() -> UISplitViewController {
        let splitVC = UISplitViewController(style: .tripleColumn)
        splitVC.preferredDisplayMode = .oneBesideSecondary
        splitVC.preferredSplitBehavior = .automatic
        
        let sidebarVC = UINavigationController(rootViewController: SidebarViewController())
        let mainVC = CoverLetterListViewController()
        let presenter = CoverLetterListPresenter(view: mainVC, service: CoverLetterService())
        mainVC.presenter = presenter

        let detailVC = DetailViewController()
        
        if let sidebar = sidebarVC.viewControllers.first as? SidebarViewController {
            sidebar.delegate = mainVC
            let selectedFilter = (sidebar.sidebarFilters.first ?? nil) ?? .all
            mainVC.didSelectFilter(selectedFilter)
        }
        
        detailVC.delegate = mainVC
        mainVC.tableVC.selectionDelegate = detailVC
        
        splitVC.setViewController(sidebarVC, for: .primary)
        splitVC.setViewController(mainVC, for: .supplementary)
        splitVC.setViewController(detailVC, for: .secondary)
        
        splitVC.minimumSupplementaryColumnWidth = 400
        splitVC.maximumSupplementaryColumnWidth = 700
        
        return splitVC
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}

extension SceneDelegate: LoginViewControllerDelegate {
    func loginDidSucceed() {
        showMainSplitView()
    }
}
