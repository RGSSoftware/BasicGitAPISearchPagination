# BasicGitAPISearchPagination
Basic example showing how to create a pagination request for github REST repository API.

```swift
class SearchViewController: UITableViewController {

    ...

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

    ...

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
    
    ...

```
