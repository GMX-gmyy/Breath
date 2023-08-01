//
//  BBaseTabBarController.swift
//  Breath
//
//  Created by 龚梦洋 on 2023/7/30.
//

import Foundation
import UIKit

class BBaseTabBarController: UITabBarController {
    
    public var sceneType: SceneType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        creatChildViewControllers()
    }
    
    private func creatChildViewControllers() {
        
        let vc1 = BBreatheViewController()
        vc1.tabBarItem.image = UIImage(named: "breathe")?.withRenderingMode(.alwaysOriginal)
        vc1.tabBarItem.selectedImage = UIImage(named: "breathed")?.withRenderingMode(.alwaysOriginal)
        vc1.tabBarItem.title = "Breathe"
        vc1.tabBarItem.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 12)], for: .normal)
        vc1.tabBarItem.setTitleTextAttributes([.foregroundColor: UIColor.green, .font: UIFont.systemFont(ofSize: 12)], for: .selected)
        let navi1 = BBaseNavigationController(rootViewController: vc1)
        
        let vc2 = BSceneViewController()
        vc2.tabBarItem.image = UIImage(named: "scene")?.withRenderingMode(.alwaysOriginal)
        vc2.tabBarItem.selectedImage = UIImage(named: "scened")?.withRenderingMode(.alwaysOriginal)
        vc2.tabBarItem.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 12)], for: .normal)
        vc2.tabBarItem.title = "Scene"
        vc2.tabBarItem.setTitleTextAttributes([.foregroundColor: UIColor.green, .font: UIFont.systemFont(ofSize: 12)], for: .selected)
        let navi2 = BBaseNavigationController(rootViewController: vc2)
        viewControllers = [navi1, navi2]
    }
}
