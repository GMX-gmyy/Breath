//
//  BBaseViewController.swift
//  Breath
//
//  Created by 龚梦洋 on 2023/7/31.
//

import Foundation
import UIKit
import SnapKit
import JKCategories

class BBaseViewController: UIViewController {
    
    private lazy var leafImageview: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "leaf"))
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        
        view.addSubview(leafImageview)
        leafImageview.snp.makeConstraints { make in
            make.top.equalTo(kNavigationBarHeight)
            make.left.equalTo(20)
            make.width.height.equalTo(100)
        }
    }
    
    var bgImage: String? {
        didSet {
            if let bgImage = bgImage {
                let image = UIImage(named: bgImage)?.jk_imageCroppedAndScaled(to: CGSize(width: bScreenWidth, height: bScreenHeight), contentMode: .scaleAspectFill, padToFit: true)
                view.backgroundColor = UIColor(patternImage: image ?? UIImage())
            }
        }
    }
}
