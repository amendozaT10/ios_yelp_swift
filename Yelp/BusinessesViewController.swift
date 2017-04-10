//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FiltersViewControllerDelegate {
    
    var businesses: [Business]!
    var filteredBusinesses: [Business]?
    var searchBar: UISearchBar?
    var showSearchResults = false
    
    let CellIdentifier = "BusinessCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showSearchResults = false
        
        createSearchBar()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        Business.searchWithTerm(term: "Thai", completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.tableView.reloadData()
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                }
            }
            
            }
        )
        
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
    }
    
    func createSearchBar() {
        searchBar = UISearchBar()
        searchBar?.placeholder = "Search Restaurants"
        searchBar?.delegate = self
        navigationItem.titleView = searchBar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table View functionality
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            if showSearchResults
            {
                return (filteredBusinesses?.count)!
            }
            else {
                return businesses.count
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as! BusinessCell
        
        if showSearchResults {
            cell.business = filteredBusinesses?[indexPath.row]
        } else {
            cell.business = businesses[indexPath.row]
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated:false)
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        
        filtersViewController.delegate = self
     }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        let categories = filters["categories"] as! [String]
        print(categories)
        
        Business.searchWithTerm(term: "Restaurants", sort: nil, categories: categories, deals: nil, completion: { (businesses: [Business]?, error: Error?) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        }
        )
    }
    
    // MARK: -SERACH BAR FUBCTIONALITY BELOW
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("text was edited")
        
        self.filteredBusinesses = self.businesses?.filter({ (business: Business) -> Bool in
            
            let businessName = business.name
            return businessName!.lowercased().range(of: searchText, options: .caseInsensitive) != nil
        })
        
        if (searchText != "")
        {
            showSearchResults = true
            self.tableView.reloadData()
        }
        else
        {
            showSearchResults = false
            self.tableView.reloadData()
        }
        
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        showSearchResults = true
        searchBar.endEditing(true)
        self.tableView.reloadData()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar?.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar?.endEditing(true)
    }
    
    func onTap(_ sender: Any) {
        searchBar?.endEditing(true)
    }

    
}
