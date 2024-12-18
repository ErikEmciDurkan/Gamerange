//
//  GenresViewModel.swift
//  Gamester
//
//  Created by Nino on 16.02.2024..
//

import UIKit

class GenresViewModel {
    
    // MARK: - Variables
    internal let apiService: APIServiceProtocol
    internal let userDefaultsService: LocalStorageServiceProtocol
        
    private(set) var allGenres: [Genre] = [] {
        didSet {
            self.onGenreUpdated?()
        }
    }
    
    var selectedGenres: [Genre] = [] {
        didSet {
            self.onGenreUpdated?()
        }
    }
    
    private(set) var filteredGenres: [Genre] = []
    let cellHeight: CGFloat = 130.0
    
    // MARK: - Callbacks
    var onGenreUpdated: (()->Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Initializer
    init(userDefaultsService: LocalStorageServiceProtocol, apiService: APIServiceProtocol) {
        self.apiService = apiService
        self.userDefaultsService = userDefaultsService
        self.fetchGenresFromAPI()
    }
    
    public func fetchGenresFromAPI() {
        apiService.fetchData(from: .genres, responseType: GenresResponse.self) { result in
            switch result {
            case .success(let genres):
                self.allGenres = genres.results
                
                let getResult: Result<[Genre], LocalStorageError> = self.userDefaultsService.get(forKey: .selectedGenres)
                switch getResult {
                case .success(let genres):
                    print("Retrieved genres: \(genres)")
                    self.selectedGenres = genres
                case .failure(let error):
                    print("Failed to retrieve genres: \(error)")
                    self.selectedGenres = []
                }
                
            case .failure(let error):
                self.onError?("Error fetching game details: \(error.localizedDescription)")
            }
        }
    }

}

// MARK: - Search
extension GenresViewModel {
    
    public func inSearchMode(_ searchController: UISearchController) -> Bool {
        let isActive = searchController.isActive
        let searchText = searchController.searchBar.text ?? ""
        return isActive && !searchText.isEmpty
    }
    
    public func updateSearchController(searchBarText: String?) {
        self.filteredGenres = allGenres
        if let searchText = searchBarText?.lowercased() {
            guard !searchText.isEmpty else { self.onGenreUpdated?(); return }
            
            self.filteredGenres = self.filteredGenres.filter({ $0.name.lowercased().contains(searchText) })
        }
        self.onGenreUpdated?()
    }
}

