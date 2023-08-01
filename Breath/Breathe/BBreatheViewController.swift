//
//  BBreatheViewController.swift
//  Breath
//
//  Created by 龚梦洋 on 2023/7/30.
//

import Foundation
import UIKit
import AVKit

enum SelectTimeType {
    case one
    case three
    case five
    case ten
    case fifteen
    
    var timeString:String {
        switch self {
        case .one:
            return "1"
        case .three:
            return "3"
        case .five:
            return "5"
        case .ten:
            return "10"
        case .fifteen:
            return "15"
        }
    }
    
    var time: Int {
        switch self {
        case .one:
            return 1
        case .three:
            return 3
        case .five:
            return 5
        case .ten:
            return 10
        case .fifteen:
            return 15
        }
    }
}

class BBreatheViewController: BBaseViewController {
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserval: Any?
    private var timer: Timer?
    private var timeCount: Int = 0
    
    private let dataSource: [SelectTimeType] = [.one, .three, .five, .ten, .fifteen]
    private var timeIndex: Int = 0
    private var isStop: Bool = true
    
    private lazy var aniLayerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        view.layer.cornerRadius = 75
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var breathTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    private lazy var topLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var selectTime: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = 80
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: width, height: 50)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SelectTimeCell.self, forCellWithReuseIdentifier: "SelectTimeCell")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    private lazy var underLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var unitLabel: UILabel = {
        let label = UILabel()
        label.text = "min"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    private lazy var startBreatheButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Start", for: .normal)
        button.setTitle("Stop", for: .selected)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.black, for: .selected)
        button.layer.cornerRadius = 20
        button.backgroundColor = .white
        button.layer.shadowColor = kColor(r: 0, g: 0, b: 0, 0.1).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 4
        button.addTarget(self, action: #selector(starBreatheEvent(sender:)), for: .touchUpInside)
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tabVc = navigationController?.tabBarController as? BBaseTabBarController
        let type = tabVc?.sceneType ?? .base
        bgImage = type.imageString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        createAvPlayer()
        timeCount = dataSource.first!.time * 60
        NotificationCenter.default.addObserver(self, selector: #selector(enterBack), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(aniLayerView)
        aniLayerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-kTabbarHeight / 2.0)
            make.width.height.equalTo(150)
        }
        
        aniLayerView.addSubview(breathTimeLabel)
        breathTimeLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(startBreatheButton)
        startBreatheButton.snp.makeConstraints { make in
            make.bottom.equalTo(-(kTabbarHeight + 80))
            make.width.equalTo(150)
            make.height.equalTo(38)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(selectTime)
        selectTime.snp.makeConstraints { make in
            make.bottom.equalTo(startBreatheButton.snp.top).offset(-50)
            make.width.equalTo(80)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(unitLabel)
        unitLabel.snp.makeConstraints { make in
            make.centerY.equalTo(selectTime.snp.centerY)
            make.width.equalTo(50)
            make.height.equalTo(30)
            make.left.equalTo(selectTime.snp.right)
        }
        
        view.addSubview(topLine)
        topLine.snp.makeConstraints { make in
            make.bottom.equalTo(selectTime.snp.top).offset(-4)
            make.centerX.equalTo(selectTime.snp.centerX)
            make.width.equalTo(60)
            make.height.equalTo(2)
        }
        
        view.addSubview(underLine)
        underLine.snp.makeConstraints { make in
            make.top.equalTo(selectTime.snp.bottom).offset(4)
            make.centerX.equalTo(selectTime.snp.centerX)
            make.width.equalTo(60)
            make.height.equalTo(2)
        }
        
        view.bringSubviewToFront(aniLayerView)
    }
    
    @objc func starBreatheEvent(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        isStop = !sender.isSelected
        if (sender.isSelected) {
            UIView.animate(withDuration: 0.4) {
                self.selectTime.alpha = 0
                self.topLine.alpha = 0
                self.underLine.alpha = 0
                self.unitLabel.alpha = 0
                self.breathTimeLabel.alpha = 1.0
            }
            breathAni()
            setupTimer()
            play()
        } else {
            stopBreath()
        }
    }
    
    private func breathAni() {
        if (isStop) {
            return
        }
        UIView.animate(withDuration: 1.6) {
            self.aniLayerView.transform = CGAffineTransformMakeScale(1.1, 1.1)
        } completion: { result in
            UIView.animate(withDuration: 2.0) {
                self.aniLayerView.transform = CGAffineTransformMakeScale(0.9, 0.9)
            } completion: { finish in
                self.breathAni()
            }
        }
    }
    
    private func removeBerathAni() {
        self.aniLayerView.transform = .identity
    }
    
    private func createAvPlayer() {
        playerItem = AVPlayerItem(url: URL(fileURLWithPath: Bundle.main.path(forResource: "breath", ofType: "mp3")!))
        player = AVPlayer(playerItem: playerItem)
        timeObserval = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: DispatchQueue.main, using: { [weak self] cmTime in
            let progress = Float(CMTimeGetSeconds(cmTime)) / Float(CMTimeGetSeconds((self?.playerItem!.duration)!))
            print("progress ====== \(progress)")
            if (progress >= 0.99) {
                self?.player?.seek(to: .zero)
                self?.play()
            }
        })
    }
    
    private func play() {
        if (player == nil) {
            return
        }
        player?.play()
    }
    
    private func pause() {
        if (player == nil) {
            return
        }
        player?.pause()
    }
    
    private func removePlayerObserval() {
        if (player == nil || timeObserval == nil) {
            return
        }
        player?.removeTimeObserver(self.timeObserval as Any)
        timeObserval = nil
    }
    
    private func setupTimer() {
        if (timer != nil) {
            releaseTimer()
        }
        timer = Timer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func releaseTimer() {
        if (timer == nil) {
            return
        }
        timer?.invalidate()
        timer = nil
    }
    
    @objc func timerAction() {
        timeCount -= 1
        let minute = timeCount / 60
        let seconds = timeCount % 60
        print("timeCount ==== \(timeCount), minute ==== \(minute), seconds ==== \(seconds)")
        breathTimeLabel.text = String(format: "%02d:%02d", minute, seconds)
        if (timeCount == 0) {
            stopBreath()
        }
    }
    
    private func stopBreath() {
        isStop = true
        startBreatheButton.isSelected = false
        releaseTimer()
        pause()
        player?.seek(to: .zero)
        UIView.animate(withDuration: 0.4) {
            self.selectTime.alpha = 1.0
            self.topLine.alpha = 1.0
            self.underLine.alpha = 1.0
            self.unitLabel.alpha = 1.0
            self.breathTimeLabel.alpha = 0
        }
        removeBerathAni()
        timeCount = dataSource[timeIndex].time * 60
    }
    
    @objc func enterBack() {
        stopBreath()
    }
}

extension BBreatheViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectTimeCell", for: indexPath) as? SelectTimeCell
        cell?.timeString = dataSource[indexPath.item]
        return cell ?? SelectTimeCell()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.y / 50.0)
        timeIndex = index
        let time = dataSource[index].time
        timeCount = time * 60
        breathTimeLabel.text = String(format: "%02d:00", time)
    }
}

class SelectTimeCell: UICollectionViewCell {
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 28, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        contentView.backgroundColor = .clear
        
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(50)
            make.center.equalToSuperview()
        }
    }
    
    var timeString: SelectTimeType? {
        didSet {
            if let timeString = timeString {
                timeLabel.text = timeString.timeString
            }
        }
    }
}
