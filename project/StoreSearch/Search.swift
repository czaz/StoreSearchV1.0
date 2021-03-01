//
//  Search.swift
//  StoreSearch
//
//  Created by Wm. Zazeckie on 2/28/21.
//


import Foundation
import UIKit



typealias SearchComplete = (Bool) -> Void // declaring a type for our clouser, named SearchComplete. This closure returns no value since its void and takes one parameter, a Bool.  We use the name SearchComplete to refer to a closure that takes a Bool parameter and returns no value.

class Search {
    
    
    enum Category: Int {
      case all = 0
      case music = 1
      case software = 2
      case ebooks = 3
        
        var type: String {
        switch self {
        case .all: return ""
        case .music: return "musicTrack"
        case .software: return "software"
        case .ebooks: return "ebook"
        }
        }
    }
    
    
 
    enum State {
        case notSearchedYet
        case loading
        case noResults
        case results([SearchResult]) // asssociated value, an array of SearchResult objects
    }
    
 private(set) var state: State = .notSearchedYet // keeps track of Search's current state.
  private var dataTask: URLSessionDataTask? = nil
    
    // taken from SearchViewController
    func performSearch(for text: String, category: Category, completion: @escaping SearchComplete) {
      if !text.isEmpty {
        dataTask?.cancel()
        state = .loading
        let url = iTunesURL(searchText: text, category: category)
        let session = URLSession.shared
        dataTask = session.dataTask(with: url, completionHandler: {data, response, error in
          var newState = State.notSearchedYet
          var success = false
          // Was the search cancelled?
          if let error = error as NSError?, error.code == -999 {
            return
          }
          
          if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data {
            var searchResults = self.parse(data: data)
            if searchResults.isEmpty {
              newState = .noResults
            } else {
              searchResults.sort(by: <)
              newState = .results(searchResults)
            }
            success = true
          }
          DispatchQueue.main.async {
            self.state = newState
            completion(success)
          }
        })
        dataTask?.resume()
      }
    }

// builds a URL string via placing the search text behind the "term=" parameter, then turning this string into a URL object
private func iTunesURL(searchText: String, category: Category) -> URL {
   
    let locale = Locale.autoupdatingCurrent
    let language = locale.identifier
    let countryCode = locale.regionCode ?? "US"
    
    let kind = category.type
    
    
    
    let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! // using add percent encoding method to create a string where all special characters are escaped, allowing the user to now type into the search bar multiple words. We also set a limit of 200 to the URL
    let urlString = "https://itunes.apple.com/search?" + // inserting encodedText and kind into the string interpolation, into a urlString
        "term=\(encodedText)&limit=200&entity=\(kind)" + "&lang=\(language)&country=\(countryCode)" // inserted the &land and &country parameters
        
    let url = URL(string: urlString)
    
    print("URL: \(url!)") // we'll see what exactly the URL will be
    
    return url!
}




private func parse(data: Data) -> [SearchResult] {
    do{
        let decoder = JSONDecoder()
        let result = try decoder.decode(ResultArray.self, from:data) // using a JSONDecoder object to convert response data from the server to a temporary ResultArray object which the results property is extracted
        return result.results
    }
    catch {
        print("JSON Error: \(error)")
        return []
    }
    
    
    
    
 
}
    
}


