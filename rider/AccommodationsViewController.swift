//
//  AccommodationsViewController.swift
//  rider
//
//  Created by admin on 12/30/16.
//  Copyright © 2016 BicycleBNB. All rights reserved.
//

import UIKit
import GooglePlaces

class AccommodationsViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    var dataSource: [AccommodationModel]?
    var detailData: AccommodationModel?
    var lastViewedIndex: Int = 0
    var mapViewController: MapViewController?
    @IBOutlet var constraintHide: NSLayoutConstraint!
    
    @IBOutlet var moreButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        WebService.getProperties(completion: { (success, result) in
            hud?.hide(true)
            if success, let count = result?.count, count > 0 {
                AppDelegate.appDelegate.accommodations = result
            }
        })
        
        initDataSource()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: GlobalConstants.NOTIFY_ACCOMMODATIONS_UPDATED), object: nil, queue: nil) { notification in
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
            mapViewController.mapFor = 2
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
        UIApplication.shared.open(URL(string: GlobalConstants.BNB_ADD_PROPERTY_URL)!, options: [:], completionHandler: nil)
    }
    @IBAction func onHideDetail(_ sender: Any) {
        showDetails(constraintHide.isActive)
    }
    @IBAction func onPrevious(_ sender: Any) {
        guard dataSource != nil else {
            return
        }
        guard lastViewedIndex > 0 else {
            return
        }
        
        lastViewedIndex = lastViewedIndex - 1
        detailData = dataSource?[lastViewedIndex]
        tableView.reloadData()
        mapViewController?.onScroll(to: detailData!)
    }
    @IBAction func onNext(_ sender: Any) {
        guard dataSource != nil else {
            return
        }
        guard lastViewedIndex < (dataSource!.count - 1) else {
            return
        }
        
        lastViewedIndex = lastViewedIndex + 1
        detailData = dataSource?[lastViewedIndex]
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
    }
    
    func initDataSource() {
        dataSource = AppDelegate.appDelegate.accommodations
        detailData = dataSource?[0]
        tableView.reloadData()
    }
}

extension AccommodationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if detailData != nil {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellAccommodation", for: indexPath)
        
        if let data = detailData,
            let accommoCell = cell as? AccommodationTableViewCell {
            accommoCell.data = data
            accommoCell.delegate = self;
        }
        return cell
    }
}

extension AccommodationsViewController: CoordComparableModelDelegate {
    func coordComparableModel(_ selectedModel: CoordComparableModel?, didTappedOn viewController: MapViewController) {
        if selectedModel == nil {
            showDetails(false)
        } else if let index = dataSource?.index(of: selectedModel as! AccommodationModel) {
            lastViewedIndex = index
            detailData = dataSource?[index]
            tableView.reloadData()
            showDetails(true)
        }
    }
}

extension AccommodationsViewController: AccommodationTableViewCellDelegate {
    func accommodationTableViewCell(_: AccommodationTableViewCell, didBookButtonClicked cellData: AccommodationModel?) {
        if let urlString = cellData?.url,
            let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}


extension AccommodationsViewController: GMSAutocompleteViewControllerDelegate {
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
