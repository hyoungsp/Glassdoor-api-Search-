// MPCS 51043; Swift Programming
// Final Project
// Hyoungsun (Stanley Park)
// hyoungsun@uchicago.edu


import Foundation

/// URL session, accessing api information, and decoding the JSON information
func getCompany(url glassdoorURL: String, completion: @escaping (GlassdoorCompany) -> Void) {
    
    // Convert the String into a URL
    guard let url = URL(string: glassdoorURL) else {
        fatalError("Unable to create NSURL from string")
    }
    // Create a default url session
    let session = URLSession.shared
    
    // Create a data task
    let task = session.dataTask(with: url as URL, completionHandler: { (data, response, error) -> Void in
        
        // Ensure there were no errors returned from the request
        guard error == nil else {
            fatalError("Error: \(error!.localizedDescription)")
        }
        
        // Ensure there is data and unwrap it
        guard let data = data else {
            fatalError("Data Error: \(error!.localizedDescription)")
        }
        let dataDecoder = JSONDecoder()
        do {
            let information = try dataDecoder.decode(GlassdoorCompany.self, from: data)
            completion(information)
            
        } catch {
            print("error serializing JSON: \(error)")
        }
    })
    task.resume()
    
}


