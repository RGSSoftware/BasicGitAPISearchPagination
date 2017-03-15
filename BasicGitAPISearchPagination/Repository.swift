import Foundation
import SwiftyJSON

struct Repository {
    let id: Int
    let fullName: String
    let stargazersCount: Int
}

extension Repository: JSONAbleType {
    static func fromJSON(_ json: [String : Any]) -> Repository {
        let json = JSON(json)
        
        let id = json["id"].intValue
        let fullName = json["full_name"].stringValue
        let stargazersCount = json["stargazers_count"].intValue
        
        return Repository(id: id, fullName: fullName, stargazersCount: stargazersCount)
    }
}
