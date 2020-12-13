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
    
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var trackNameLable: UILabel!
    @IBOutlet weak var artistNameLable: UILabel!
    @IBOutlet weak var collectionNameLable: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackImageView.image = nil
    }
    
    func set(viewModel: TrackCellViewModell) {
        
        trackNameLable.text = viewModel.trackName
        artistNameLable.text = viewModel.artistName
        collectionNameLable.text = viewModel.collectionName
        
        guard let url = URL(string: viewModel.iconUrlString ?? "") else { return }
        
        trackImageView.sd_setImage(with: url, completed: nil)
        
    }
    
}
