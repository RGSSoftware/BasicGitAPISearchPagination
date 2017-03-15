import UIKit
import Alamofire
import WebLinking

class SearchViewController: UITableViewController {
    
    let q = "Swift"
    var baseURL: URL {
        return URL(string: "https://api.github.com/search/repositories")!
    }
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!

    var pages: [Page<Repository>] = []
    
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchGithubWtih(q: q, page: 1)
    }
    
    func searchGithubWtih(q: String, page: Int) {
        
        indicatorView.startAnimating()
        self.isLoading = true
        
        let par: Parameters = ["q": q, "page": page]
        
        Alamofire.request(baseURL, parameters: par).responseJSON { [weak self] response in
            
            self?.indicatorView.stopAnimating()
            self?.isLoading = false
            
            if let error = response.error {
                print(error)
                return
            }
            
            let value = response.value as? [String: Any]
            guard let items = value?["items"] as? [[String: Any]] else {
                print("No items")
                return
            }
            
            let elements = items.map{Repository.fromJSON($0)}
            
            let nextURI = response.response?.findLink(relation: "next")?.uri
            let queryItems = nextURI.flatMap(URLComponents.init)?.queryItems
            let nextPage = queryItems?
                .filter { $0.name == "page" }
                .flatMap { $0.value }
                .flatMap { Int($0) }
                .first
            
            self?.pages.append(Page<Repository>(page: page, nextPage: nextPage, elements: elements))
            self?.tableView.reloadData()
            
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pages.flatMap{$0.elements}.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryCell", for: indexPath) as! RepositoryCell
        cell.bind(pages.flatMap{$0.elements}[indexPath.row])
        return cell
    }
    
    func loadNextPage() {
        if !isLoading{
            if let nextPage = pages.last?.nextPage {
                searchGithubWtih(q: q, page: nextPage)
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let  height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            loadNextPage()
        }
    }
}

