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
        
        //var sortingOption = ""
        
        for (row, isSelected) in buttonStates[1]! {
            if isSelected {
                //sortingOption = sortByOptions[row]["code"]!
                switch row {
                    case 0:
                        filters["sort"] = YelpSortMode.bestMatched as AnyObject?
                        break
                    case 1:
                        filters["sort"] = YelpSortMode.distance as AnyObject?
                        break
                    case 2:
                        filters["sort"] = YelpSortMode.highestRated as AnyObject?
                        break
                    default:
                        break
                }
            }
        }
        
        for (row, isSelected) in buttonStates[2]! {
            if isSelected {
                //sortingOption = sortByOptions[row]["code"]!
                switch row {
                case 0:
                    filters["distance"] = 20 as AnyObject?
                    break
                case 1:
                    filters["distance"] = 10 as AnyObject?
                    break
                case 2:
                    filters["distance"] = 5 as AnyObject?
                    break
                case 3:
                    filters["distance"] = 3 as AnyObject?
                    break
                case 4:
                    filters["distance"] = 1 as AnyObject?
                    break
                default:
                    break
                }
            }
        }
        
        var offering = false
        
        for (_, isSelected) in switchStates[0]! {
            if isSelected {
                offering  = true
            }
        }
        
        filters["offering"] = offering as AnyObject?

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
            let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCellIdentifier, for: indexPath) as! ButtonCell
            
            cell.titleLabel.text = "\(distances[cellRow]) miles"
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
        tableView.reloadData()
        
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
    
    func yelpCats() -> [[String:String]] {
        return [["name" : "Afghan", "code": "afghani"],
                ["name" : "African", "code": "african"],
                ["name" : "American, New", "code": "newamerican"],
                ["name" : "American, Traditional", "code": "tradamerican"],
                ["name" : "Arabian", "code": "arabian"],
                ["name" : "Argentine", "code": "argentine"],
                ["name" : "Armenian", "code": "armenian"],
                ["name" : "Asian Fusion", "code": "asianfusion"],
                ["name" : "Asturian", "code": "asturian"],
                ["name" : "Australian", "code": "australian"],
                ["name" : "Austrian", "code": "austrian"],
                ["name" : "Baguettes", "code": "baguettes"],
                ["name" : "Bangladeshi", "code": "bangladeshi"],
                ["name" : "Barbeque", "code": "bbq"],
                ["name" : "Basque", "code": "basque"],
                ["name" : "Bavarian", "code": "bavarian"],
                ["name" : "Beer Garden", "code": "beergarden"],
                ["name" : "Beer Hall", "code": "beerhall"],
                ["name" : "Beisl", "code": "beisl"],
                ["name" : "Belgian", "code": "belgian"],
                ["name" : "Bistros", "code": "bistros"],
                ["name" : "Black Sea", "code": "blacksea"],
                ["name" : "Brasseries", "code": "brasseries"],
                ["name" : "Brazilian", "code": "brazilian"],
                ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
                ["name" : "British", "code": "british"],
                ["name" : "Buffets", "code": "buffets"],
                ["name" : "Bulgarian", "code": "bulgarian"],
                ["name" : "Burgers", "code": "burgers"],
                ["name" : "Burmese", "code": "burmese"],
                ["name" : "Cafes", "code": "cafes"],
                ["name" : "Cafeteria", "code": "cafeteria"],
                ["name" : "Cajun/Creole", "code": "cajun"],
                ["name" : "Cambodian", "code": "cambodian"],
                ["name" : "Canadian", "code": "New)"],
                ["name" : "Canteen", "code": "canteen"],
                ["name" : "Caribbean", "code": "caribbean"],
                ["name" : "Catalan", "code": "catalan"],
                ["name" : "Chech", "code": "chech"],
                ["name" : "Cheesesteaks", "code": "cheesesteaks"],
                ["name" : "Chicken Shop", "code": "chickenshop"],
                ["name" : "Chicken Wings", "code": "chicken_wings"],
                ["name" : "Chilean", "code": "chilean"],
                ["name" : "Chinese", "code": "chinese"],
                ["name" : "Comfort Food", "code": "comfortfood"],
                ["name" : "Corsican", "code": "corsican"],
                ["name" : "Creperies", "code": "creperies"],
                ["name" : "Cuban", "code": "cuban"],
                ["name" : "Curry Sausage", "code": "currysausage"],
                ["name" : "Cypriot", "code": "cypriot"],
                ["name" : "Czech", "code": "czech"],
                ["name" : "Czech/Slovakian", "code": "czechslovakian"],
                ["name" : "Danish", "code": "danish"],
                ["name" : "Delis", "code": "delis"],
                ["name" : "Diners", "code": "diners"],
                ["name" : "Dumplings", "code": "dumplings"],
                ["name" : "Eastern European", "code": "eastern_european"],
                ["name" : "Ethiopian", "code": "ethiopian"],
                ["name" : "Fast Food", "code": "hotdogs"],
                ["name" : "Filipino", "code": "filipino"],
                ["name" : "Fish & Chips", "code": "fishnchips"],
                ["name" : "Fondue", "code": "fondue"],
                ["name" : "Food Court", "code": "food_court"],
                ["name" : "Food Stands", "code": "foodstands"],
                ["name" : "French", "code": "french"],
                ["name" : "French Southwest", "code": "sud_ouest"],
                ["name" : "Galician", "code": "galician"],
                ["name" : "Gastropubs", "code": "gastropubs"],
                ["name" : "Georgian", "code": "georgian"],
                ["name" : "German", "code": "german"],
                ["name" : "Giblets", "code": "giblets"],
                ["name" : "Gluten-Free", "code": "gluten_free"],
                ["name" : "Greek", "code": "greek"],
                ["name" : "Halal", "code": "halal"],
                ["name" : "Hawaiian", "code": "hawaiian"],
                ["name" : "Heuriger", "code": "heuriger"],
                ["name" : "Himalayan/Nepalese", "code": "himalayan"],
                ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
                ["name" : "Hot Dogs", "code": "hotdog"],
                ["name" : "Hot Pot", "code": "hotpot"],
                ["name" : "Hungarian", "code": "hungarian"],
                ["name" : "Iberian", "code": "iberian"],
                ["name" : "Indian", "code": "indpak"],
                ["name" : "Indonesian", "code": "indonesian"],
                ["name" : "International", "code": "international"],
                ["name" : "Irish", "code": "irish"],
                ["name" : "Island Pub", "code": "island_pub"],
                ["name" : "Israeli", "code": "israeli"],
                ["name" : "Italian", "code": "italian"],
                ["name" : "Japanese", "code": "japanese"],
                ["name" : "Jewish", "code": "jewish"],
                ["name" : "Kebab", "code": "kebab"],
                ["name" : "Korean", "code": "korean"],
                ["name" : "Kosher", "code": "kosher"],
                ["name" : "Kurdish", "code": "kurdish"],
                ["name" : "Laos", "code": "laos"],
                ["name" : "Laotian", "code": "laotian"],
                ["name" : "Latin American", "code": "latin"],
                ["name" : "Live/Raw Food", "code": "raw_food"],
                ["name" : "Lyonnais", "code": "lyonnais"],
                ["name" : "Malaysian", "code": "malaysian"],
                ["name" : "Meatballs", "code": "meatballs"],
                ["name" : "Mediterranean", "code": "mediterranean"],
                ["name" : "Mexican", "code": "mexican"],
                ["name" : "Middle Eastern", "code": "mideastern"],
                ["name" : "Milk Bars", "code": "milkbars"],
                ["name" : "Modern Australian", "code": "modern_australian"],
                ["name" : "Modern European", "code": "modern_european"],
                ["name" : "Mongolian", "code": "mongolian"],
                ["name" : "Moroccan", "code": "moroccan"],
                ["name" : "New Zealand", "code": "newzealand"],
                ["name" : "Night Food", "code": "nightfood"],
                ["name" : "Norcinerie", "code": "norcinerie"],
                ["name" : "Open Sandwiches", "code": "opensandwiches"],
                ["name" : "Oriental", "code": "oriental"],
                ["name" : "Pakistani", "code": "pakistani"],
                ["name" : "Parent Cafes", "code": "eltern_cafes"],
                ["name" : "Parma", "code": "parma"],
                ["name" : "Persian/Iranian", "code": "persian"],
                ["name" : "Peruvian", "code": "peruvian"],
                ["name" : "Pita", "code": "pita"],
                ["name" : "Pizza", "code": "pizza"],
                ["name" : "Polish", "code": "polish"],
                ["name" : "Portuguese", "code": "portuguese"],
                ["name" : "Potatoes", "code": "potatoes"],
                ["name" : "Poutineries", "code": "poutineries"],
                ["name" : "Pub Food", "code": "pubfood"],
                ["name" : "Rice", "code": "riceshop"],
                ["name" : "Romanian", "code": "romanian"],
                ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
                ["name" : "Rumanian", "code": "rumanian"],
                ["name" : "Russian", "code": "russian"],
                ["name" : "Salad", "code": "salad"],
                ["name" : "Sandwiches", "code": "sandwiches"],
                ["name" : "Scandinavian", "code": "scandinavian"],
                ["name" : "Scottish", "code": "scottish"],
                ["name" : "Seafood", "code": "seafood"],
                ["name" : "Serbo Croatian", "code": "serbocroatian"],
                ["name" : "Signature Cuisine", "code": "signature_cuisine"],
                ["name" : "Singaporean", "code": "singaporean"],
                ["name" : "Slovakian", "code": "slovakian"],
                ["name" : "Soul Food", "code": "soulfood"],
                ["name" : "Soup", "code": "soup"],
                ["name" : "Southern", "code": "southern"],
                ["name" : "Spanish", "code": "spanish"],
                ["name" : "Steakhouses", "code": "steak"],
                ["name" : "Sushi Bars", "code": "sushi"],
                ["name" : "Swabian", "code": "swabian"],
                ["name" : "Swedish", "code": "swedish"],
                ["name" : "Swiss Food", "code": "swissfood"],
                ["name" : "Tabernas", "code": "tabernas"],
                ["name" : "Taiwanese", "code": "taiwanese"],
                ["name" : "Tapas Bars", "code": "tapas"],
                ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
                ["name" : "Tex-Mex", "code": "tex-mex"],
                ["name" : "Thai", "code": "thai"],
                ["name" : "Traditional Norwegian", "code": "norwegian"],
                ["name" : "Traditional Swedish", "code": "traditional_swedish"],
                ["name" : "Trattorie", "code": "trattorie"],
                ["name" : "Turkish", "code": "turkish"],
                ["name" : "Ukrainian", "code": "ukrainian"],
                ["name" : "Uzbek", "code": "uzbek"],
                ["name" : "Vegan", "code": "vegan"],
                ["name" : "Vegetarian", "code": "vegetarian"],
                ["name" : "Venison", "code": "venison"],
                ["name" : "Vietnamese", "code": "vietnamese"],
                ["name" : "Wok", "code": "wok"],
                ["name" : "Wraps", "code": "wraps"],
                ["name" : "Yugoslav", "code": "yugoslav"]]
    }

    
    
}
