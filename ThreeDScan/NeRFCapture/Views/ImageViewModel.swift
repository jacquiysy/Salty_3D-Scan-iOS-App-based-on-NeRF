//
//  ImageViewModel.swift
//  ThreeDScan
//
//  Created by jacquiy on 8/2/23.
//

import SwiftUI
import Combine


struct StringListResponse: Codable {
    let filenames: [String]
}


class ImageViewModel: ObservableObject {
    @Published var imageModels: [Item] = []
    private var cancellables: Set<AnyCancellable> = []
//    @State var imageURLs: [String] = []
    
    init() {
        
        let urlString = "http://10.0.6.82:8080/list_output_dir"
        fetchStringListFromURL(urlString: urlString) { strings in
            if let strings = strings {
                // Here, you have the list of strings from the JSON response
                print(strings)
                for imageURL in strings {
                    if imageURL.contains(".obj") { continue }
                    let full_url = URL(string:"http://10.0.6.82:8080/download/" + imageURL + ".png")
                    print(full_url?.absoluteString)
                    self.imageModels.append(Item(name: full_url?.lastPathComponent ?? "", url: ((full_url ?? URL(string:"http://10.0.6.82:8080/download/fox.png"))!)))
                }
            } else {
                // Failed to fetch strings from the JSON response
                print("Failed to fetch strings.")
            }
        }
    }
    
    func fetchStringListFromURL(urlString: String, completion: @escaping ([String]?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let data = data else {
                print("Invalid response or no data received.")
                completion(nil)
                return
            }
            print(String(data:data, encoding:.utf8))

            do {
                print(try JSONDecoder().decode(StringListResponse.self, from: data))
                let stringListResponse = try JSONDecoder().decode(StringListResponse.self, from: data)
                completion(stringListResponse.filenames)
            } catch {
                print("Error decoding JSON: \(error)")
                completion(nil)
            }
        }.resume()
    }

    
    
}
