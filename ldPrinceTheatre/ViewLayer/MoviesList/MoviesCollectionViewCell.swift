//
//  MoviesCollectionViewCell.swift
//  ldPrinceTheatre
//
//  Created by Spencer Feng on 2/10/21.
//

import UIKit
import SDWebImage

class MoviesCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let reuseIdentifier = String(describing: MoviesCollectionViewCell.self)
    
    private let moviePosterView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let movieTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialisers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(moviePosterView)
        contentView.addSubview(movieTitleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycles
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            moviePosterView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            moviePosterView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            moviePosterView.heightAnchor.constraint(equalTo: moviePosterView.widthAnchor),
            
            movieTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            movieTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            movieTitleLabel.topAnchor.constraint(equalTo: moviePosterView.bottomAnchor, constant: 10)
        ])
    }
    
    // MARK: - Functions
    func configureCell(with movie: ConsolidatedMovie) {
        movieTitleLabel.text = movie.title
        // TODO: get a proper placeholder image
        moviePosterView.sd_setImage(with: URL(string: movie.posterURL), placeholderImage: UIImage())
    }
}
