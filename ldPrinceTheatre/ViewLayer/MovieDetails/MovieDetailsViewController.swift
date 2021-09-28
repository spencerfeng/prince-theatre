//
//  MovieDetailsViewController.swift
//  ldPrinceTheatre
//
//  Created by Spencer Feng on 3/10/21.
//

import Foundation
import UIKit
import Combine

class MovieDetailsViewController: UIViewController {
    
    // MARK: - Properties
    private let movieDetailsViewModel: MovieDetailsViewModel
    
    private var subscriptions = Set<AnyCancellable>()
    
    private let moviePosterView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private let movieTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let highPriceProviderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let lowPriceProviderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let highPriceAmountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let lowPriceAmountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var lowPriceView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [lowPriceProviderLabel, lowPriceAmountLabel])
        return stackView
    }()
    
    private lazy var highPriceView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [highPriceProviderLabel, highPriceAmountLabel])
        return stackView
    }()
    
    private lazy var pricesView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [lowPriceView, highPriceView])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 16
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private let pricesLoadingIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.isHidden = true
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicator
    }()
    
    // MARK: - Initialisers
    init(movieDetailsViewModel: MovieDetailsViewModel) {
        self.movieDetailsViewModel = movieDetailsViewModel
        self.moviePosterView.sd_setImage(with: URL(string: movieDetailsViewModel.getMoviePosterURL()), placeholderImage: UIImage())
        self.movieTitleLabel.text = movieDetailsViewModel.getMovieTitle()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        layoutUI()
        bindUI()
        
        movieDetailsViewModel.getMovieDetails()
    }
    
    // MARK: - Functions
    private func layoutUI() {
        view.addSubview(moviePosterView)
        view.addSubview(movieTitleLabel)
        view.addSubview(pricesView)
        view.addSubview(pricesLoadingIndicator)
        
        NSLayoutConstraint.activate([
            moviePosterView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            moviePosterView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            moviePosterView.widthAnchor.constraint(equalToConstant: 200),
            moviePosterView.heightAnchor.constraint(equalTo: moviePosterView.widthAnchor),
            
            movieTitleLabel.topAnchor.constraint(equalTo: moviePosterView.bottomAnchor, constant: 20),
            movieTitleLabel.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            movieTitleLabel.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            
            pricesView.topAnchor.constraint(equalTo: movieTitleLabel.bottomAnchor, constant: 40),
            pricesView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            pricesView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            
            lowPriceProviderLabel.widthAnchor.constraint(equalToConstant: 100),
            highPriceProviderLabel.widthAnchor.constraint(equalTo: lowPriceProviderLabel.widthAnchor),
            
            pricesLoadingIndicator.topAnchor.constraint(equalTo: movieTitleLabel.bottomAnchor, constant: 40),
            pricesLoadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func bindUI() {
        movieDetailsViewModel
            .$lowPriceProvider
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                self?.lowPriceProviderLabel.text = value
            })
            .store(in: &subscriptions)
        
        movieDetailsViewModel
            .$lowPriceAmount
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                self?.lowPriceAmountLabel.text = value
            })
            .store(in: &subscriptions)
        
        movieDetailsViewModel
            .$highPriceProvider
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                self?.highPriceProviderLabel.text = value
            })
            .store(in: &subscriptions)
        
        movieDetailsViewModel
            .$highPriceAmount
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                self?.highPriceAmountLabel.text = value
            })
            .store(in: &subscriptions)
        
        movieDetailsViewModel
            .$loadingPricesState
            .receive(on:DispatchQueue.main)
            .sink(receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    self?.pricesLoadingIndicator.isHidden = false
                    self?.pricesLoadingIndicator.startAnimating()
                case .success:
                    self?.pricesLoadingIndicator.isHidden = true
                    self?.pricesLoadingIndicator.stopAnimating()
                case .loadingFailed:
                    self?.pricesLoadingIndicator.isHidden = true
                    self?.pricesLoadingIndicator.stopAnimating()
                    
                    let alertController = UIAlertController(title: "Failed to fetch movie prices", message: nil, preferredStyle: .alert)
                    let retryAction = UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
                        self?.movieDetailsViewModel.getMovieDetails()
                    }
                    alertController.addAction(retryAction)
                    self?.present(alertController, animated: true)
                }
            })
            .store(in: &subscriptions)
    }
}
