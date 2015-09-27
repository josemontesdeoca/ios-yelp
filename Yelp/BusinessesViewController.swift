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
        
        loadBusinesses("Restaurants")
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
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let searchText = searchBar.text!
        
        loadBusinesses(searchText)
        
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
        loadBusinessesWithFilters(filters)
    }
    
    func loadBusinesses(searchTerm: String) {
        // Display a loading state
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        Business.searchWithTerm(searchTerm, sort: .Distance, categories: nil, deals: nil, radius: 0) {
            (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            
            // Remove loading state
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
    }
    
    func loadBusinessesWithFilters(filters: [String : AnyObject]) {
        let deals = filters["deals"] as! Bool
        let sort = filters["sort"] as? Int
        let radius = filters["radius"] as? Int
        let categories = filters["categories"] as? [String]
        
        var yelpSort: YelpSortMode?
        
        if sort != nil {
            yelpSort = YelpSortMode(rawValue: sort!)!
        }
        
        // Display a loading state
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        Business.searchWithTerm("Restaurants", sort: yelpSort, categories: categories, deals: deals, radius: radius) {
            (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            
            // Remove loading state
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
        
    }
    
}

