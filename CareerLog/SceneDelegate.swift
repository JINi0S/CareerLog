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
        let splitVC = UISplitViewController(style: .tripleColumn)
        splitVC.preferredDisplayMode = .oneBesideSecondary
        splitVC.preferredSplitBehavior = .automatic

        // 1. Primary (사이드바)
        let sidebarVC = UINavigationController(rootViewController: SidebarViewController())

        // 2. Supplementary (중앙 뷰)
        let mainVC = ViewController()
        if let sidebar = sidebarVC.viewControllers.first as? SidebarViewController {
            sidebar.delegate = mainVC
            
            // 수동으로 초기 상태 전달
            let selectedState = sidebar.states.first ?? nil
            mainVC.didSelectState(selectedState)
        }

        // 3. Secondary (오른쪽 디테일 뷰)
        let detailVC = DetailViewController()
        detailVC.delegate = mainVC
        if let delegate = detailVC as? CoverLetterSelectionDelegate {
            mainVC.tableVC.delegate = delegate
        } else {
            assertionFailure("DetailViewController가 CoverLetterSelectionDelegate를 채택하지 않음")
        }
        
        // 각 열에 뷰컨트롤러 할당
        splitVC.setViewController(sidebarVC, for: .primary)
        splitVC.setViewController(mainVC, for: .supplementary)
        splitVC.setViewController(detailVC, for: .secondary)
        splitVC.minimumSupplementaryColumnWidth = 400
        splitVC.maximumSupplementaryColumnWidth = 700
        splitVC.preferredDisplayMode = .automatic
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            splitVC.hide(.secondary)
        }
        splitVC.show(.primary)
        splitVC.hide(.secondary)
        
        // 윈도우 설정
        window = UIWindow(windowScene: scene as! UIWindowScene)
        window?.rootViewController = splitVC
        window?.tintColor = .accent
        window?.makeKeyAndVisible()
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
