//
//  HeroeManager.swift
//  SuperTeams
//
//  Created by evpes on 15.11.2021.
//

import Foundation

protocol HeroeManagerDelegate {
    func updateHeroeName(heroe: HeroeData)
    func updateHeroeImage(imageData: Data)
    func failWithError(error: Error)
}

struct HeroeManager {
    let heroeURL = "https://www.breakingbadapi.com/api/character/random"
    
    var delegate: HeroeManagerDelegate?
    
    func performRequest() {
        if let url = URL(string: heroeURL) {
            let queue = DispatchQueue.global(qos: .userInitiated)
            queue.async {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, resp, err in
                if err != nil {
                    self.delegate?.failWithError(error: err!)
                    return
                }
                
                if let safeData = data {
                    if let heroe = parseJSON(safeData) {
                        self.delegate?.updateHeroeName(heroe: heroe)
                        fetchImage(with: heroe.img)
                    }
                }
            }
            task.resume()
            }
        }
    }
    
    func parseJSON(_ heroeData: Data) -> HeroeData? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode([HeroeData].self, from: heroeData)
            return decodedData[0]
        } catch {
            self.delegate?.failWithError(error: error)
            return nil
        }
    }
    
    func fetchImage(with url: String) {
        guard let imageURL = URL(string: url) else { return }
        
            guard let imageData = try? Data(contentsOf: imageURL) else { return }
            self.delegate?.updateHeroeImage(imageData: imageData)
        
    }
}
