import UIKit

struct App {
    static func show(in window: UIWindow) {
        let viewController = ViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.prefersLargeTitles = true
        viewController.title = "ReactiveTimelane"
        navigationController.title = "ReactiveTimelane"
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
