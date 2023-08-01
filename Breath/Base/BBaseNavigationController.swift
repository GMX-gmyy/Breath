//
//  BBaseNavigationController.swift
//  Breath
//
//  Created by 龚梦洋 on 2023/7/30.
//

import Foundation
import UIKit

class BBaseNavigationController: UINavigationController, UIGestureRecognizerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interactivePopGestureRecognizer?.delegate = self
    }
}
