//
//  MoviesListViewController.swift
//  ldPrinceTheatre
//
//  Created by Spencer Feng on 2/10/21.
//

import Foundation
import UIKit
import Combine

class MoviesListViewController: UIViewController {
    
    // MARK: - Properties
    private let moviesListViewModel: MoviesListViewModel
    
    private var subscriptions = Set<AnyCancellable>()
    
    private lazy var moviesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(MoviesCollectionViewCell.self, forCellWithReuseIdentifier: MoviesCollectionViewCell.reuseIdentifier)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    private var fullScreenLoadingView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.isHidden = true
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicator
    }()
    
    // MARK: - Initialisers
    init(moviesListViewModel: MoviesListViewModel) {
        self.moviesListViewModel = moviesListViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Prince's Theatre"
        view.backgroundColor = .systemBackground
        
        layoutUI()
        bindUI()
        
        moviesListViewModel.getMovies()
    }
    
    // MARK: - Functions
    private func layoutUI() {
        view.addSubview(moviesCollectionView)
        view.addSubview(fullScreenLoadingView)
        
        NSLayoutConstraint.activate([
            fullScreenLoadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fullScreenLoadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            moviesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            moviesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            moviesCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            moviesCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func bindUI() {
        moviesListViewModel
            .$moviesList
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                self.moviesCollectionView.reloadData()
            })
            .store(in: &subscriptions)
        
        moviesListViewModel
            .$viewState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    self?.fullScreenLoadingView.isHidden = false
                    self?.fullScreenLoadingView.startAnimating()
                case .success:
                    self?.fullScreenLoadingView.isHidden = true
                    self?.fullScreenLoadingView.stopAnimating()
                case .loadingFailed:
                    self?.fullScreenLoadingView.isHidden = true
                    self?.fullScreenLoadingView.stopAnimating()
                    
                    let alertController = UIAlertController(title: "Failed to fetch movies list", message: nil, preferredStyle: .alert)
                    let retryAction = UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
                        self?.moviesListViewModel.getMovies()
                    }
                    alertController.addAction(retryAction)
                    self?.present(alertController, animated: true)
                }
            })
            .store(in: &subscriptions)
    }
}

// MARK: - UICollectionViewDataSource
extension MoviesListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moviesListViewModel.moviesList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoviesCollectionViewCell.reuseIdentifier, for: indexPath) as? MoviesCollectionViewCell else {
            fatalError("MovieCollectionViewCell cannot be found")
        }
        
        let movie = moviesListViewModel.moviesList[indexPath.row]
        cell.configureCell(with: movie)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MoviesListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = moviesCollectionView.bounds.width / CGFloat(2)
        let height = 1.5 * width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = moviesListViewModel.moviesList[indexPath.row]
        let movieDetailsViewModel = moviesListViewModel.buildMovieDetailsViewModel(movie: movie)
        let movieDetailsViewController = MovieDetailsViewController(movieDetailsViewModel: movieDetailsViewModel)
        
        navigationController?.pushViewController(movieDetailsViewController, animated: true)
    }
}
