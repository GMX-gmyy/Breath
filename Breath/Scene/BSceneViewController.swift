//
//  BSceneViewController.swift
//  Breath
//
//  Created by 龚梦洋 on 2023/7/30.
//

import Foundation
import UIKit

enum SceneType {
    case base
    case rain
    case forest
    case wave
    case road
    case aurora
    case city
    case desert
    
    var imageString: String {
        switch self {
        case .base:
            return "breathBg"
        case .rain:
            return "rain"
        case .forest:
            return "forest"
        case .wave:
            return "wave"
        case .road:
            return "road"
        case .aurora:
            return "aurora"
        case .city:
            return "city"
        case .desert:
            return "desert"
        }
    }
}

class BSceneViewController: BBaseViewController {
    
    private let dataSource: [SceneType] = [.base, .aurora, .city, .desert, .forest, .rain, .road, .wave]
    
    private lazy var sceneCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = bScreenWidth / 4
        layout.itemSize = CGSize(width: width, height: (5 * width) / 4)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 50
        layout.minimumInteritemSpacing = 12
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView .register(SceneCell.self, forCellWithReuseIdentifier: "SceneCell")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        
        view.addSubview(sceneCollectionView)
        sceneCollectionView.snp.makeConstraints { make in
            make.bottom.equalTo(-kTabbarHeight)
            make.left.right.equalToSuperview()
            make.top.equalTo(kNavigationBarHeight + 100)
        }
        
    }
}

extension BSceneViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SceneCell", for: indexPath) as? SceneCell
        cell?.sceneType = dataSource[indexPath.item]
        return cell ?? SceneCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tabVc = navigationController?.tabBarController as? BBaseTabBarController
        let type = dataSource[indexPath.item]
        tabVc?.sceneType = type
        tabVc?.selectedIndex = 0
    }
}

class SceneCell: UICollectionViewCell {
    
    private lazy var bgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        contentView.backgroundColor = .red
        contentView.addSubview(bgImageView)
        bgImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    var sceneType: SceneType? {
        didSet {
            if let sceneType = sceneType {
                bgImageView.image = UIImage(named: sceneType.imageString)
            }
        }
    }
}
