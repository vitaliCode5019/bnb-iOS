//
//  GroupRidesViewController.swift
//  rider
//
//  Created by admin on 12/30/16.
//  Copyright © 2016 BicycleBNB. All rights reserved.
//

import UIKit
import GooglePlaces

class GroupRidesViewController: UIViewController {
    var controllerData: [GroupRideModel]?
    var detailData: GroupRideModel?
    var lastViewedIndex: Int = 0
    var mapViewController: MapViewController?
    
    @IBOutlet var moreButton: UIButton!
    @IBOutlet var constraintHide: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!

    @IBOutlet var containerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        WebService.getGroupRides { (success, result) in
            hud?.hide(true)
            if success, let count = result?.count, count > 0 {
                AppDelegate.appDelegate.groupRides = result
            }
        }
        
        initDataSource()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: GlobalConstants.NOTIFY_GROUP_RIDES_UPDATED), object: nil, queue: nil) {  notification in
            self.initDataSource()
        }
        
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tappedOutside)))
    }
    
    func tappedOutside() {
        showDetails(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mapViewController = segue.destination as? MapViewController {
            mapViewController.mapFor = 0
            mapViewController.pinDelegate = self
            
            self.mapViewController = mapViewController
        }
    }
    
    @IBAction func onSearchLocation(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func onAddNew(_ sender: Any) {
        UIApplication.shared.open(URL(string: GlobalConstants.BNB_ADD_RIDE_URL)!, options: [:], completionHandler: nil)
    }
    @IBAction func onHideDetail(_ sender: Any) {
       showDetails(constraintHide.isActive)
    }
    
    @IBAction func onPrevious(_ sender: Any) {
        guard controllerData != nil else {
            return
        }
        guard lastViewedIndex > 0 else {
            return
        }
        
        lastViewedIndex = lastViewedIndex - 1
        detailData = controllerData![lastViewedIndex];
        tableView.reloadData()
        mapViewController?.onScroll(to: detailData!)
    }
    
    @IBAction func onNext(_ sender: Any) {
        guard controllerData != nil else {
            return
        }
        guard lastViewedIndex < (controllerData!.count - 1) else {
            return
        }
        
        lastViewedIndex = lastViewedIndex + 1
        detailData = controllerData![lastViewedIndex];
        tableView.reloadData()
        mapViewController?.onScroll(to: detailData!)
    }
    
    func showDetails(_ show: Bool) {
        if constraintHide.isActive == !show {
            return
        }
        
        if !show {
            constraintHide.isActive = true
            moreButton.setTitle("Show details", for: .normal)
        } else {
            constraintHide.isActive = false
            moreButton.setTitle("Hide details", for: .normal)
        }
        
        //Manually resize embedded map view (refer apple bug)
        self.view.setNeedsLayout()
        self.view.layoutSubviews()
        if let originalFrame = mapViewController?.view.frame {
            mapViewController?.view.frame = CGRect(origin: originalFrame.origin, size: containerView.frame.size)
        }
    }
    
    func initDataSource() {
        controllerData = AppDelegate.appDelegate.groupRides
        detailData = controllerData?[0]
        tableView.reloadData()
    }
}


extension GroupRidesViewController: CoordComparableModelDelegate {
    func coordComparableModel(_ selectedModel: CoordComparableModel?, didTappedOn viewController: MapViewController) {
        if selectedModel == nil {
            showDetails(false)
        } else if let index = controllerData?.index(of: selectedModel as! GroupRideModel) {
            lastViewedIndex = index
            detailData = controllerData?[index]
            tableView.reloadData()
            showDetails(true)
        }
    }
}


extension GroupRidesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if detailData != nil {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let rowData = getData(from: indexPath)
        let rowData = detailData
        
        if indexPath.row == 8 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellReview", for: indexPath)
            let review = cell.contentView.viewWithTag(100) as? UIButton
            review?.addTarget(self, action: #selector(self.onReview(_:)), for: .touchUpInside)
            
            if(indexPath.row % 2 == 0) {
                cell.contentView.backgroundColor = GlobalConstants.COLOR_TABLE_CELL_EVEN
            } else {
                cell.contentView.backgroundColor = GlobalConstants.COLOR_TABLE_CELL_ODD
            }
            
            cell.selectionStyle = .none
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            if(indexPath.row % 2 == 0) {
                cell.contentView.backgroundColor = GlobalConstants.COLOR_TABLE_CELL_EVEN
            } else {
                cell.contentView.backgroundColor = GlobalConstants.COLOR_TABLE_CELL_ODD
            }
            
            cell.selectionStyle = .none
            
            let title = cell.contentView.viewWithTag(100) as? UILabel
            let content = cell.contentView.viewWithTag(101) as? UILabel
            
            switch indexPath.row {
            case 0:
                title?.text = "NAME:"
                content?.text = rowData?.name
                break
            case 1:
                title?.text = "DAY/TIME:"
                content?.text = rowData?.dayTime
                break
            case 2:
                title?.text = "WEBSITE:"
                //content?.text = controllerData?.url
                content?.text = "Click for website"
                break
            case 3:
                title?.text = "LOCATION:"
                content?.text = rowData?.location
                break
            case 4:
                title?.text = "PROXIMITY:"
                content?.text = rowData?.proximity()
            case 5:
                title?.text = "LENGTH OF RIDE:"
                content?.text = rowData?.lengthOfRide
                break
            case 6:
                title?.text = "DISCIPLINE:"
                content?.text = rowData?.discipline
                break
            case 7:
                title?.text = "NOTES:"
                content?.text = rowData?.notes
                break
            default:
                break
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView.init(frame: CGRect.zero)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init(frame: CGRect.zero)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 2) {
            if let urlString = detailData?.url,
                let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func onReview(_ sender: UIButton?) {
        if let cell = getParentCell(from: sender) {
            if let indexPath = tableView.indexPath(for: cell) {
                if let urlString = controllerData?[indexPath.section].eventUrl,
                    let url = URL(string: urlString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    func getParentCell(from subview: UIView?) -> UITableViewCell? {
        if subview == nil {
            return nil
        } else if let cell = subview as? UITableViewCell {
            return cell
        } else {
            return getParentCell(from: subview?.superview)
        }
    }
}

extension GroupRidesViewController: GMSAutocompleteViewControllerDelegate {
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: nil)
        
        mapViewController?.onCameraTo(place: place)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
