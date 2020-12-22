//
//  TrackCell.swift
//  iMusic
//
//  Created by Arkasha Zuev on 06.12.2020.
//

import UIKit
import SDWebImage

protocol TrackCellViewModell {
    var iconUrlString: String? { get }
    var trackName: String { get }
    var artistName: String { get }
    var collectionName: String { get }
}

class TrackCell: UITableViewCell {
    
    static let reuseId = "TrackCell"
    
    var cell: SearchViewModel.Cell?
    
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var trackNameLable: UILabel!
    @IBOutlet weak var artistNameLable: UILabel!
    @IBOutlet weak var collectionNameLable: UILabel!
    @IBOutlet weak var addTrackOutlet: UIButton!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackImageView.image = nil
    }
    
    func set(viewModel: SearchViewModel.Cell) {
        
        self.cell = viewModel
        
        let savedTracks = UserDefaults.standard.savedTracks()
        let hasFavourite = savedTracks.firstIndex (where: {
            $0.trackName == self.cell?.trackName && $0.artistName == self.cell?.artistName
        }) != nil
        
        if hasFavourite {
            addTrackOutlet.isHidden = true
        } else {
            addTrackOutlet.isHidden = false
        }
        
        trackNameLable.text = viewModel.trackName
        artistNameLable.text = viewModel.artistName
        collectionNameLable.text = viewModel.collectionName
        
        guard let url = URL(string: viewModel.iconUrlString ?? "") else { return }
        
        trackImageView.sd_setImage(with: url, completed: nil)
        
    }
    
    @IBAction func addTrackAction(_ sender: Any) {
        
        guard let cell = cell else { return }
        
        addTrackOutlet.isHidden = true
        
        let defaults = UserDefaults.standard
        var listOfTracks = defaults.savedTracks()
        
        listOfTracks.append(cell)
        
        if let savedDate = try? NSKeyedArchiver.archivedData(withRootObject: listOfTracks, requiringSecureCoding: false) {
            defaults.set(savedDate, forKey: UserDefaults.favouriteTrackKey)
        }
        
    }
    
}
