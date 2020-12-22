//
//  TrackDetailView.swift
//  iMusic
//
//  Created by Arkasha Zuev on 08.12.2020.
//

import UIKit
import AVKit
import SDWebImage

protocol TrackMovingDelegate {
    func moveBackForPreviousTrack() -> SearchViewModel.Cell?
    func moveForwardForPreviousTrack() -> SearchViewModel.Cell?
}

class TrackDetailView: UIView {
    
    @IBOutlet weak var miniTrackImageView: UIImageView!
    @IBOutlet weak var miniTrackTitleLable: UILabel!
    @IBOutlet weak var miniTrackView: UIView!
    @IBOutlet weak var miniPlayPauseButton: UIButton!
    @IBOutlet weak var miniGoForwardButton: UIButton!
    
    @IBOutlet weak var maximizedStackView: UIStackView!
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var currentTimeLable: UILabel!
    @IBOutlet weak var durationLable: UILabel!
    @IBOutlet weak var trackTitleLable: UILabel!
    @IBOutlet weak var authorTitleLable: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    
    var delegate: TrackMovingDelegate?
    weak var tabBarDelegate: MainTabBarControllerDelegate?
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    // MARK: - awakeFromNib
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let scale: CGFloat = 0.8
        trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        trackImageView.layer.cornerRadius = 5
        miniPlayPauseButton.imageEdgeInsets = .init(top: 11, left: 11, bottom: 11, right: 11)
        
        setupGesture()
    }
    
    // MARK: - Setup
    
    func set(viewModel: SearchViewModel.Cell) {
        
        monitorStartTime()
        playTrack(previewUrl: viewModel.previewUrl)
        
        observePlayerCurrentTime()
        
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        
        miniTrackTitleLable.text = viewModel.trackName
        trackTitleLable.text = viewModel.trackName
        authorTitleLable.text = viewModel.artistName
        
        let string600 = viewModel.iconUrlString?.replacingOccurrences(of: "100x100", with: "600x600")
        
        guard let url = URL(string: string600 ?? "") else { return }
        miniTrackImageView.sd_setImage(with: url, completed: nil)
        trackImageView.sd_setImage(with: url, completed: nil)
        
    }
    
    private func setupGesture() {
        miniTrackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handelTapMaximized)))
        miniTrackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handelPan)))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handelDismissaPan)))
    }
    
    private func playTrack(previewUrl: String?) {
        
        guard let url = URL(string: previewUrl ?? "") else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        
    }
    
    // MARK: - Maximizing and minimizing gestures
    
    @objc private func handelTapMaximized() {
        self.tabBarDelegate?.maximizeTrackDetailController(viewModel: nil)
    }
    
    @objc private func handelPan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            handlePanChanged(gesture: gesture)
        case .ended:
            handelPanEnded(gesture: gesture)
        @unknown default:
            print("unknown default case")
        }
    }
    
    @objc private func handelDismissaPan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: self.superview)
            maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        case .ended:
            let translation = gesture.translation(in: self.superview)
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 1,
                           options: .curveEaseOut,
                               animations: {
                                self.maximizedStackView.transform = .identity
                                if translation.y > 50 {
                                    self.tabBarDelegate?.minimizeTrackDetailController()
                                }
                               },
                           completion: nil)
        @unknown default:
            print("unknown default case")
        }
    }
    
    private func handlePanChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        let newAlpha = 1 + translation.y / 200
        self.miniTrackView.alpha = newAlpha < 0 ? 0 : newAlpha
        self.maximizedStackView.alpha = -translation.y / 200
    }
    
    private func handelPanEnded(gesture: UIPanGestureRecognizer) {
        let transletion = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                           animations: {
                            self.transform = .identity
                            if transletion.y < -200 || velocity.y < -500 {
                                self.tabBarDelegate?.maximizeTrackDetailController(viewModel: nil)
                            } else {
                                self.miniTrackView.alpha = 1
                                self.maximizedStackView.alpha = 0
                            }
                           },
                       completion: nil)
    }
    
    // MARK: - Time setup

    private func monitorStartTime() {
        
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeTrackImageView()
        }
        
    }
    
    private func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            self?.currentTimeLable.text = time.toDisplayString()
            let durationTime = self?.player.currentItem?.duration
            let currentDurationText = ((durationTime ?? CMTimeMake(value: 1, timescale: 1)) - time).toDisplayString()
            self?.durationLable.text = "-\(currentDurationText)"
            self?.updateCurrentTimeSlider()
        }
    }
    
    private func updateCurrentTimeSlider() {
        
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let precentage = currentTimeSeconds / durationSeconds
        self.currentTimeSlider.value = Float(precentage)
        
    }
    
    // MARK: - Animations
    
    private func enlargeTrackImageView() {
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                           animations: {
                                self.trackImageView.transform = .identity
                           },
                       completion: nil)
    }
    
    private func reduceTrackImageView() {
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                           animations: {
                                let scale: CGFloat = 0.8
                                self.trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
                           },
                       completion: nil)
    }
    
    // MARK: - @IBActions
 
    @IBAction func dragDownButtonTapped(_ sender: Any) {
        
        tabBarDelegate?.minimizeTrackDetailController()
        //self.removeFromSuperview()
    }
    
    @IBAction func handelCurrentTimeSlider(_ sender: Any) {
        
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeUnSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeUnSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
        
    }
    
    @IBAction func handelVoluemSlider(_ sender: Any) {
        
        player.volume = volumeSlider.value
        
    }
    
    @IBAction func previousTrack(_ sender: Any) {
        let cellViewModel = delegate?.moveBackForPreviousTrack()
        guard let cellInfo = cellViewModel else { return }
        self.set(viewModel: cellInfo)
    }
    
    @IBAction func nextTrack(_ sender: Any) {
        let cellViewModel = delegate?.moveForwardForPreviousTrack()
        guard let cellInfo = cellViewModel else { return }
        self.set(viewModel: cellInfo)
    }
    
    @IBAction func playPauseAction(_ sender: Any) {
        
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeTrackImageView()
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            reduceTrackImageView()
        }
        
    }
    
}
