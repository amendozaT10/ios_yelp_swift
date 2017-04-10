//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Mendoza, Alejandro on 4/6/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController(filtersViewController: FiltersViewController,
                                        didUpdateFilters filters: [String: AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate, ButtonCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: FiltersViewControllerDelegate?
    
    var categories: [[String:String]] = []
    var sortByOptions: [[String:String]] = []
    var switchStates = [Int : [Int:Bool]]()
    var buttonStates = [Int : [Int:Bool]]()
    //var swtichThing = [0:[0:false, 1:true],1:[0:false]]
    var offeringDeal: Bool?
    var distances = [Int]()
    var sections: [(String, [Any])] = []
    
    let SwitchCellIdentifier = "SwitchCell", ButtonCellIdentifier = "ButtonCell", HeaderSectionIdentifier = "SectionHeader"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        offeringDeal = false
        sortByOptions = yelpSortByOtions()
        distances = yelpDistances()
        categories = yelpCats()
        
        sections = yelpSections()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SettingsSectionHeader.self, forHeaderFooterViewReuseIdentifier: HeaderSectionIdentifier)
        
        //checkButtonCell.ad
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onSearchButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        var filters = [String:AnyObject]()
        
        var selectedCategories = [String]()
        
        for (row, isSelected) in switchStates[3]! {
            if isSelected {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories as AnyObject?
        }
        
        delegate?.filtersViewController?(filtersViewController: self, didUpdateFilters: filters)
    }
    
    // MARK: - Table view setup functionality
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].1.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = nil as? UITableViewCell
        
        let cellRow = indexPath.row
        let cellSection = indexPath.section
        
        if (indexPath.section == 0) {
            // do offering cell
            let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCellIdentifier, for: indexPath) as! SwitchCell
            
            cell.switchLabel.text = "Offering Deal?"
            cell.delegate = self
            let rows = switchStates[cellSection]
            cell.onSwitch.isOn = rows?[cellRow] ?? false
            return cell
        } else if (indexPath.section == 1 ) {
            // do sort by cell
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCellIdentifier, for: indexPath) as! ButtonCell
            
            cell.titleLabel.text = sortByOptions[cellRow]["name"]
            cell.delegate = self
            let rows = buttonStates[cellSection]
            cell.isChecked = rows?[cellRow] ?? false
            if (cell.isChecked)! {
                cell.setSelectedImage()
            } else {
                cell.setDeselectedImage()
            }
            buttonStates[cellSection]?[cellRow] = cell.isChecked
            return cell
        } else if (indexPath.section == 2) {
            // do distance cell
            let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCellIdentifier, for: indexPath) as! SwitchCell
            
            cell.switchLabel.text = "\(distances[cellRow]) miles"
            cell.delegate = self
            let rows = switchStates[cellSection]
            cell.onSwitch.isOn = rows?[cellRow] ?? false
            return cell
        } else {
            // do categories cell
            let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCellIdentifier, for: indexPath) as! SwitchCell
            
            cell.switchLabel.text = categories[cellRow]["name"]
            cell.delegate = self
            let rows = switchStates[cellSection]
            cell.onSwitch.isOn = rows?[cellRow] ?? false
            return cell
        }
    }
    
    // MARK: - Protocal for uitable cells
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)
        var rows = switchStates[(indexPath?.section)!]! 
        rows[(indexPath?.row)!] = value
        switchStates[(indexPath?.section)!] = rows
        
        print("filters VC got switch event")
    }
    
    func buttonCell(buttonCell: ButtonCell, didTouchUpInside value: Bool) {
        let indexPath = tableView.indexPath(for: buttonCell)
        //var rows = buttonStates[(indexPath?.section)!]! as? [Int:Bool]
        
        for (row, _) in buttonStates[(indexPath?.section)!]! {
            let checkIndexPath = IndexPath.init(row: row, section: (indexPath?.section)!)
            //if row != indexPath?.row {
                buttonStates[(indexPath?.section)!]![row] = false
                let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCellIdentifier, for: checkIndexPath) as! ButtonCell
                cell.setDeselectedImage()
            //}
        }
        
        buttonStates[(indexPath?.section)!]![(indexPath?.row)!] = true
        buttonCell.setSelectedImage()
        
        print("Printing button states")
        print(buttonStates)
    }
    
//    func buttonCell(buttonCell: ButtonCell, didChangeValue value: Bool) {
//        let indexPath = tableView.indexPath(for: buttonCell)
//        //buttonCell.setSelected(true, animated: true)
//        
//        print("button got selected \(indexPath?.row)")
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func yelpCats() -> [[String:String]] {
        return [["name":"Afghan", "code":"afghani"], ["name":"African", "code":"african"]]
    }
    
    func yelpDistances() -> [Int] {
        return [20,10,5,3,1]
    }
    
    func yelpSortByOtions() -> [[String:String]] {
        return [["name":"Best Match", "code":"best_match"],
                ["name":"Distance", "code":"distance"],
                ["name":"Highest Rated", "code":"highest_rated"]]
    }
    
    func yelpSections() -> [(String, [Any])] {
        buttonStates = [0:[:], 1:[:], 2:[:], 3:[:]]
        switchStates = [0:[:], 1:[:], 2:[:], 3:[:]]
        
        return [("Offering Deal", [false]),
                ("Sort By",  yelpSortByOtions()),
                ("Distance", yelpDistances()),
                ("Categories", yelpCats())]
    }

}
