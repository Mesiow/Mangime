//
//  MangimeManager.swift
//  Mangime
//
//  Created by Mesiow on 3/17/23.
//

import Foundation
import UIKit

protocol MangimeManagerDelegate {
    func didUpdateData(_ mangimeManager : MangimeManager, mangimeModels : [MangimeModel], numberOfPages: Int);
    func didFailWithInput(error: Error);
}

struct MangimeManager {
    var getMostPopularAnime = "https://api.jikan.moe/v4/top/anime"
    var getMostPopularManga = "https://api.jikan.moe/v4/top/manga"
    let getAnimeByName = "https://api.jikan.moe/v4/anime?q=";
    let getMangaByName = "https://api.jikan.moe/v4/manga?q=";
    
    
    var delegate : MangimeManagerDelegate?
    
    func fetchAnime(name: String, page: Int = 1){
        let fixedName = removeNameSpaces(name: name);
        
        let url = "\(getAnimeByName)\(fixedName)&page=\(page)";
        
        performRequest(url);
    }
    
    func fetchManga(name : String, page: Int = 1){
        let fixedName = removeNameSpaces(name: name);
        
        let url = "\(getMangaByName)\(fixedName)&page=\(page)";
        
        performRequest(url);
    }
    
    func removeNameSpaces(name: String) -> String{
        let whitespace = NSCharacterSet.whitespaces
        let range = name.rangeOfCharacter(from: whitespace);

        var fixedName : String = name;
        // range will be nil if no whitespace is found
        if range != nil {
            //remove any spaces and add proper space value before setting url
            let rng : Range<String.Index> = fixedName.range(of: " ")!;
            let idx : Int = fixedName.distance(from: fixedName.startIndex, to: rng.lowerBound);
            
            fixedName.insert("+", at: String.Index(utf16Offset: idx, in: fixedName));
            fixedName = fixedName.removeWhitespace();
        }
        return fixedName;
    }
    
    func performRequest(_ urlString: String){
        if let url = URL(string: urlString){
            //create url session
            let session = URLSession(configuration: .default);
            
            //give session a task
            let task = session.dataTask(with: url) {
                (data, response, error) in
                if error != nil {
                    //handle error
                    print("ERROR giving session a task: \(error!)")
                    return;
                }
                
                //Decode and parse our json data
                if let safeData = data {
                    if let decodedData = self.decodeData(safeData){
                        let numOfPages = decodedData.pagination.last_visible_page;
                        if let mangimeModels = self.parseJson(decodedData) {
                            self.delegate?.didUpdateData(self, mangimeModels: mangimeModels, numberOfPages: numOfPages);
                        }
                    }
                }
            };
            
            //start the task
            task.resume();
        }
    }
    
    func decodeData(_ mangimeData: Data) -> MangimeData? {
        let decoder = JSONDecoder();
        do {
            let decodedData = try decoder.decode(MangimeData.self, from: mangimeData);
            return decodedData;
        }catch{
            delegate?.didFailWithInput(error: error);
            return nil;
        }
    }
    
    func parseJson(_ mangimeDecodedData: MangimeData) -> [MangimeModel]?{
        var models : [MangimeModel] = [];
        for data in mangimeDecodedData.data {
            let img_url = data.images.jpg.image_url;
            let img = load(img_url);
                
            var model = MangimeModel(image: img);
            model.trailerId = data.trailer?.youtube_id ?? "";
            model.title = data.title;
            model.type = data.type;
            model.synopsis = data.synopsis ?? "";
            
            if data.aired != nil {
                model.aired = data.aired!.string
            }
            else if data.published != nil {
                model.aired = data.published!.string;
            }
            
            model.score = data.score;
                
            models.append(model);
        }
        return models;
    }
    
    func load(_ urlString : String) -> UIImage? {
        if let url = URL(string: urlString){
            if let data = try? Data(contentsOf: url) {
                if let img = UIImage(data: data) {
                    return img;
                }
            }
        }
        return nil;
    }
}

extension String {
   func replace(string:String, replacement:String) -> String {
       return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
   }

   func removeWhitespace() -> String {
       return self.replace(string: " ", replacement: "")
   }
 }
