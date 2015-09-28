//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Jose Montes de Oca on 9/25/15.
//  Copyright © 2015 JoseOnline. All rights reserved.
//

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
    UISearchBarDelegate, FiltersViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var businesses: [Business]!
    var yelpOffset = 0
    var yelpSearchTerm = "Restaurants"
    var yelpFilters = [String : AnyObject]()
    var totalBusinesses = 0
    var loading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create the search bar programatically since you won't be able to drag one onto 
        // the navigation bar
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.placeholder = "Restaurants"
        
        navigationItem.titleView = searchBar
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        loadBusinesses(yelpSearchTerm, offset: yelpOffset, filters: yelpFilters)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->
        UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if businesses != nil && !loading {
            let currentOffset = scrollView.contentOffset.y
            let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
            
            if (maximumOffset - currentOffset) <= 40 {
                if businesses.count < totalBusinesses {
                    loadBusinesses(yelpSearchTerm, offset: (yelpOffset + 1), filters: yelpFilters)
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        loadBusinesses(searchBar.text!, offset: 0, filters: yelpFilters)
        searchBar.endEditing(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let navigationController = segue.destinationViewController as! UINavigationController
        
        // FiltersViewController is the top view controller of the naviagtion controller
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        
        filtersViewController.delegate = self
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        loadBusinesses(yelpSearchTerm, offset: 0, filters: filters)
    }
    
    func loadBusinesses(searchTerm: String, offset: Int, filters: [String : AnyObject]?) {
        yelpSearchTerm = searchTerm
        yelpOffset = offset
        
        setLoadingState(true)
        
        if filters != nil {
            yelpFilters = filters!
        }
        
        let deals = yelpFilters["deals"] as? Bool
        let sort = yelpFilters["sort"] as? Int
        let radius = yelpFilters["radius"] as? Int
        let categories = yelpFilters["categories"] as? [String]
        
        var yelpSort: YelpSortMode?
        
        if sort != nil {
            yelpSort = YelpSortMode(rawValue: sort!)!
        }
        
        Business.searchWithTerm(searchTerm, sort: yelpSort, categories: categories, deals: deals, radius: radius, offset: offset) {
            (businesses: [Business]!, total: Int!, error: NSError!) -> Void in
            
            self.totalBusinesses = total
            
            if offset == 0 {
                self.businesses = businesses
            } else {
                self.businesses.appendContentsOf(businesses)
            }
            
            self.tableView.reloadData()
            
            if offset == 0 {
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
            }
            
            // Remove loading state
            self.setLoadingState(false)
        }
    }
    
    func setLoadingState(loading: Bool) {
        self.loading = loading
        
        // Display a loading state
        if yelpOffset > 0 {
            if loading {
                // Set footer loading spinner
                let spinner: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                spinner.startAnimating()
                spinner.color = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 176.0/255.0, alpha: 1.0) // Spinner Colour
                spinner.frame = CGRectMake(0, 0, 320, 44)
                tableView.tableFooterView = spinner
            } else {
                tableView.tableFooterView = nil
            }
        } else {
            if loading {
                MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            } else {
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            }
            
        }
    }
    
}

