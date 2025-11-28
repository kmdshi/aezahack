import Foundation

class MesService {
    
    static let shared = MesService()
    
    private init() {}
    
    private let urlString = AppConfig.link
    
    func fetchNotificationData(completion: @escaping (Result<(String, String), Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Bad", code: -1)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                debugPrint("Request error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoDat", code: -1)))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: String],
                   let title = json["title"],
                   let body = json["body"] {
                    completion(.success((title, body)))
                } else {
                    completion(.failure(NSError(domain: "Invalid", code: -1)))
                }
            } catch {
                debugPrint("Request error : \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
}
