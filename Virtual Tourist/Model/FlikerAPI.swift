//
//  FlickrAPI.swift
//  Virtual Tourist
//
//  Created by Renad nasser on 13/08/2020.
//  Copyright © 2020 Renad nasser. All rights reserved.
//

import Foundation
import UIKit

class FlickrAPI{
    
    static var baseURL = "https://api.flickr.com/services/rest?"
    static var APIKay = "5a7be80a1414933be4387aa16a6db969"
    
    
    //End Points
    static func endPoint(lat:Double, long:Double) -> URL{
        let stringUrl = baseURL+"api_key=\(APIKay)&method=flickr.photos.search&format=json&lat=\(lat)&lon=\(long)&per_page=20&accuracy=11&nojsoncallback=1&page=\(getPageNum())&extras=url_m"
        
        let url = URL(string: stringUrl)!
        return url
    }
    
    
    //MARK: - Request URL Images
    class func requestURLImages(lat:Double, long:Double, completion: @escaping ([String], Error?)->()){
        
        let url = endPoint(lat: lat, long: long)
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data else{
                DispatchQueue.main.async {
                    completion([],error)
                }
                return
            }
            
            do {
                let responseObject = try JSONDecoder().decode(Response.self, from: data)
                let photosArrey = responseObject.photos.photo
                var photosURL:[String] = []
                
                for photo in photosArrey{
                    photosURL.append(photo.urlM)
                }
                
                DispatchQueue.main.async {
                    completion(photosURL, nil)
                }
            } catch {
                
                DispatchQueue.main.async {
                    completion([], error)
                }
                
            }
        }
        
        task.resume()
    }
    
    // Helper
    class func getPageNum() -> String {
        // TODO: min and max
        let number = (1...10).randomElement()!
        return String(number)
    }
    
    //MARK: - Download Image
    class func downloadImage(Stringurl:String, completion: @escaping (Data? , Error?) -> Void){
        
        let url = URL(string: Stringurl)!
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data else{
                DispatchQueue.main.async {
                    completion(nil,error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(data, nil)
            }
            
            
        }
        
        task.resume()
        
    }
    
    
}
