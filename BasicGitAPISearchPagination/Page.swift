import Foundation

struct Page <Element>{
    var page: Int
    let nextPage: Int?
    let elements: [Element]
    
}
