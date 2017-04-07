
import Foundation
import UIKit


protocol FlickrAPIRequestDelegate{ 
     func showFlickrPhoto(photo: UIImage)
     func setPhotoTitle(photoTitle: String)
     func showAlert(msg: String)
}


class FlickrAPIRequests{
    
    // Singleton
    private static let _instance = FlickrAPIRequests()
    
    static var Instance: FlickrAPIRequests{
        return _instance
    }
 
    var flickrDelegate: FlickrAPIRequestDelegate? = nil
    
    
    
 
    // Make the Flickr API call
    func flickrAPIRequest(_ params: [String: AnyObject], page: Int){
 
        var parameters = params
        
        if page != 0 {
            parameters[Constants.FlickrParameterKeys.Page] = "\(page)" as AnyObject?
        }
        
        let urlRequest = URLRequest(url: formFlickrUrl(parameters))
        
        // Create data task and deserialize the JSON response
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            if error == nil {
                
                // Check Status code:
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    self.flickrDelegate?.showAlert(msg: "Status code not successful!")
                    return
                }
                
                let deserializedJSONobj: [String: AnyObject]
                
                do{
                    deserializedJSONobj = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as!
                        [String: AnyObject]
                }catch{
                    //print("Could not parse the data as JSON: '\(data)'")
                    return
                    
                }
                
                
                guard let photosObj = deserializedJSONobj[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject]
                    else{
                        self.flickrDelegate?.showAlert(msg: "Error getting photos")
                        return
                }
 
                if page == 0 {
                    guard let totalPages = photosObj[Constants.FlickrParameterKeys.Pages] as? Int else{
                        self.flickrDelegate?.showAlert(msg: "Error getting pages")
                        return
                    }
                    
                    print("PAGES: \(totalPages)")
                    
                    let pageLimit = min(totalPages, 40)
                    let randPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                    
                    // Request the api again with random page number
                    self.flickrAPIRequest(parameters, page: randPage)
                    
                }
                    // we already made a second request with a random page number
                else{
                    guard let photoArr = photosObj[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]]
                        else{
                            self.flickrDelegate?.showAlert(msg: "Error getting photo")
                            
                            return
                    }
                    let randomNum = Int(arc4random_uniform(UInt32(photoArr.count)))
                    let photoDict = photoArr[min(randomNum, photoArr.count)] as Dictionary
                    
                    guard let photoUrlStr = photoDict[Constants.FlickrResponseKeys.MediumURL] as? String,
                        let photoTitle = photoDict[Constants.FlickrResponseKeys.Title] as? String
                        else{
                            self.flickrDelegate?.showAlert(msg: "Error getting photo link")
                            return
                    }
                    
                    let photoUrl = URL(string: photoUrlStr)
                    
                    if let photoData = NSData(contentsOf: photoUrl!){
                        
                        // Perform this code in the main UI
                        DispatchQueue.main.async { [unowned self] in
                            let img = UIImage(data: photoData as Data)
                            self.flickrDelegate?.showFlickrPhoto(photo: img!)
                            self.flickrDelegate?.setPhotoTitle(photoTitle: photoTitle)
                        }
                    }
                    
                }// End else page == 0
            }
            else{
                DispatchQueue.main.async(execute:{
                    self.flickrDelegate?.showAlert(msg: error!.localizedDescription)
                })
                
            }
        }
        task.resume()
    }
    
    
    
    
    
    private func formFlickrUrl(_ params: [String: AnyObject]) -> URL  {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in params{
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(queryItem)
        }
        
        print(components.url!)
        
        return components.url!
        
    }
    
 
    
    
}
