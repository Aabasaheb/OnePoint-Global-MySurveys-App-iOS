//
//  HomeViewController.swift
//  MySurveys2.0
//
//  Created by Chinthan on 10/06/16.
//  Copyright © 2016 Chinthan. All rights reserved.
//

import UIKit
import MapKit
import UserNotifications
import CoreLocation


let dispatchQueue = DispatchQueue(label: "com.dispatchQueue.barrier")

class MyPointAnnotation : MKPointAnnotation {
    var identifier: String?
}

class HomeViewController: RootViewController, CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource,OPGGeoFenceSurveyDelegate {
    let isDownload = "isDownloaded"
    let queue = OperationQueue()
    // MARK: - IBOutlets for view
    @IBOutlet weak var shimmeringView: FBShimmeringView?
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var bgImage: UIImageView?
    @IBOutlet weak var global: UILabel?
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var constraintShimmeringTop: NSLayoutConstraint!
    @IBOutlet weak var constraintGeotableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintMapViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintGeoFenceTop: NSLayoutConstraint!
    @IBOutlet weak var geoFencedView: UIView?
    @IBOutlet weak var tableViewGeoFenced: UITableView?
    @IBOutlet weak var lblNoSurveys: UILabel?
    
    
    // MARK: - Properties for viewcontroller
    let regionRadius: CLLocationDistance = 1500
    var locationManager = CLLocationManager()
    var myLocation: CLLocationCoordinate2D?
    var geofencedArrays: Array<Any> = []
    var geoFencedArrayFiltered: Array<Any> = []
    var surveyList:Array<Any> = []
    var surveyFilteredList: Array<Any> = []
    var surveyGeoAvailable: Array<Any> = []
    var surveyListGeoArray: Array<Any> = []
    var surveyReference: NSString?
    var surveyStatus: NSString?
    var surveySelected: OPGSurvey?
    var isOfflineDownloaded: [Int] = []
    
    var bannerView: OPGNotificationView?
    var noGeoFenceView: UIView?
    var isAppKilled: Bool = false
    var OfflineDownloadList: Array<Any> = []
    var notificationsArray: [NSDictionary]?
    var alertsArray: Array<Any> = []
    var selectedOfflineSurveyIndex: IndexPath?
    var bannerTitle: NSString?             //class var to show during orientation transition

    // MARK: - ViewController LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        geoFence?.fencingDelegate = self

        queue.maxConcurrentOperationCount = 1
        self.geoFencedView?.isHidden = true
        self.mapView.showsUserLocation = true;
        shimmeringView?.isShimmering = true
        self.isAppKilled = true
        shimmeringView?.contentView = self.tableView

        //Optional ShimmeringView protocal values
        //All values show are the defaults
        shimmeringView?.shimmeringPauseDuration = 0.4
        shimmeringView?.shimmeringAnimationOpacity = 0.5
        shimmeringView?.shimmeringOpacity = 1.0
        shimmeringView?.shimmeringSpeed = 230
        shimmeringView?.shimmeringHighlightLength = 1.0
        shimmeringView?.shimmeringDirection = FBShimmerDirection.right

        shimmeringView?.shimmeringBeginFadeDuration = 0.1
        shimmeringView?.shimmeringEndFadeDuration = 0.3
        segmentedControl.subviews.last?.tintColor =  AppTheme.appBackgroundColor()
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.setThemeBGImage()
        self.showBanner(progressTitle: NSLocalizedString("Sync in progress. Please wait!", comment: ""))//
        self.segmentedControl.setTitle(NSLocalizedString("By List", comment: ""), forSegmentAt: 0)
        self.segmentedControl.setTitle(NSLocalizedString("By Location", comment: ""), forSegmentAt: 1)
        NotificationCenter.default.addObserver(self, selector: #selector(self.uploadSurveyResults(_:)), name: NSNotification.Name(rawValue: "NotificationIdentifier"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.assignGeofencedArrays(_:)), name: NSNotification.Name(rawValue: "OPGGeofencedArraysObtained"), object: nil)

        let isOperating: Int? = UserDefaults.standard.value(forKey: "isOperating") as? Int
        if (isOperating == 3) {
            self.performAPIOperations()
        }
        let isAlreadyDownload: Int? = UserDefaults.standard.value(forKey: isDownload) as? Int
        if (isAlreadyDownload == 1 || isOperating == 3) {         //calls when you kill the app(or during refresh) and come back
            let panelID: String? = UserDefaults.standard.value(forKey: selectedPanelID) as? String
            let themeTempID: String? = UserDefaults.standard.value(forKey: "selectedThemeTemplateID") as? String
            let dict = CollabrateDB.sharedInstance().getThemesForPanelID(panelID, themeTemplateID: themeTempID)            //set theme after login if there is any available
            AppTheme.setCurrentTheme(theme: dict!)
            self.setThemeForViews()
        }

        // For testing purposes only
        //self.fireLocalNotification()
    }

    func fireLocalNotification() {
        let notification = UILocalNotification()
        if #available(iOS 8.2, *) {
            notification.alertTitle = NSLocalizedString("MySurveys", comment: "")
        } else {
            // Fallback on earlier versions
        }
        notification.alertBody = NSLocalizedString("Welcome to", comment: "") + " BTM Layout " + NSLocalizedString("You have a survey available at this location", comment: "")
        notification.fireDate = NSDate(timeIntervalSinceNow:0.3) as Date
        UIApplication.shared.cancelAllLocalNotifications()
        UIApplication.shared.scheduledLocalNotifications = [notification]
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tableView?.setContentOffset(CGPoint.zero, animated: true)
        let defaults = UserDefaults.standard
        let name: String? = defaults.value(forKey: "appName") as? String
        if name != nil {
            global?.text = name
        }
        self.rightBarButtonItemSetUp()
        // Perform Login/Update operations, save to dB and update SurveyList
        self.shimmeringView?.isShimmering = true
        self.hideGeoFencePopUp()
        self.setUpSegmentController()
        let isAlreadyDownloaded: Int?  = UserDefaults.standard.value(forKey: isDownload) as? Int
        if (isAlreadyDownloaded != 1 ) {
            self.startSpinning()
        }
        else{
            self.stopSpinning()
        }
        
        let isOperating: Int? = UserDefaults.standard.value(forKey: "isOperating") as? Int     // FirstTime == 1; Refreshing == 3; indicates that opeartions can be take from dB == 2;
        /**************         Perform Operations based on the flag        **********************/
        if (isOperating == 1) {
            self.createDummySurveyList()
            self.performAPIOperations()
        } else if (isOperating == 2)  {
            self.performAPIOperations()
        } else if (isOperating == 3){
            // refresh leave as it is
        }
        let documentsPath: String? = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0]
        print(documentsPath!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.isAppKilled = false
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let isOperating: Int? = UserDefaults.standard.value(forKey: "isOperating") as? Int
        if (isOperating == 1 || isOperating == 3)
        {
            self.hideBanner()
        }

        coordinator.animate(alongsideTransition: nil, completion: { _ in
            if ((isOperating == 1 || isOperating == 3) && (self.bannerTitle != nil)) {
                self.showBanner(progressTitle: self.bannerTitle as! String)
            }
            let geoFenceValue: String? = UserDefaults.standard.value(forKey: "isGeoFenced") as? String
            if UIDevice.current.userInterfaceIdiom == .pad {
                if(self.geoFencedView?.isHidden == false) {
                    if (geoFenceValue == nil) ||  (geoFenceValue == "0") {
                        self.setUpGeoFeningView(false)              //show only map view with no surveys
                    }
                    else {
                        self.setUpGeoFeningView(true)
                    }
                }
            }
        })
    }
    
    // MARK: - Generic private methods
    func assignGeofencedArrays(_ notification: NSNotification) {
        if notification.userInfo != nil {
            self.geofencedArrays = notification.userInfo!["geoArray"] as! Array<Any>
        }
    }

    func setThemeForViews(){
        self.tabBarController?.tabBar.tintColor = AppTheme.appBackgroundColor()
        self.segmentedControl.tintColor = AppTheme.appBackgroundColor()
        self.segmentedControl.subviews[0].tintColor = AppTheme.appBackgroundColor()
        self.segmentedControl.subviews[1].tintColor = AppTheme.appBackgroundColor()
        self.navigationController?.navigationBar.barTintColor = AppTheme.appBackgroundColor()
    }


    //This method uploads the offline survey results and shows the progress of upload.
    func uploadSurveyResults(_ notification: NSNotification) {
        print("methodOfReceivedNotification\(notification.userInfo)")
        guard let userInfo = notification.userInfo,
            let percentage  = userInfo["percentage"] as? Float,
            let surveyID  = userInfo["surveyReference"] as? Int,
            let index  = userInfo["index"] as? IndexPath,
            let numberOfFilesPending = userInfo["numberOfFilesPending"] as? Int else {
                print("No userInfo found in notification")
                return
        }
        
        DispatchQueue.main.async {
                print("progress Delegate Called")
                let indexPath = IndexPath(item: index.row , section: 0)
                let tableViewCell: SurveyTableViewCell?
                if index.section == 0 {
                   tableViewCell = self.tableView?.cellForRow(at: indexPath) as? SurveyTableViewCell
                }
                else {
                    tableViewCell = self.tableViewGeoFenced?.cellForRow(at: indexPath) as? SurveyTableViewCell

                }
                if (tableViewCell != nil) {
                    tableViewCell?.progressBar?.progress = percentage
                    tableViewCell?.progressBar?.progressTintColor = AppTheme.appBackgroundColor()        //theme for profgress bar
                    if percentage == 1.0 {
                        tableViewCell?.offlineFileCountButton.isHidden = true
                        tableViewCell?.progressBar?.progress = 0.0
                        tableViewCell?.btnSurveyDesc.isUserInteractionEnabled = false
                        tableViewCell?.btnSurveyDesc.isEnabled = false
                        tableViewCell?.btnSurveyDesc.setTitleColor(UIColor.lightGray, for: .normal)
                        tableViewCell?.btnSurveyDesc.setTitle(NSLocalizedString("Completed", comment: ""),for: .normal)
                        dispatchQueue.async(flags: .barrier) {
                            CollabrateDB.sharedInstance().updateSurvey(NSNumber(value: surveyID), withStatus: "Completed", withDownloadStatus: 2)
                        }

                        UIView.animate(withDuration: 0.5, animations: {
                            tableViewCell?.constarintCounterBtnSpace.constant = 15          //reset constarint after upload is done
                        })
                        tableViewCell?.setNeedsDisplay()
                    }
                    else {
                        tableViewCell?.offlineFileCountButton.isHidden = false
                        tableViewCell?.offlineFileCountButton.setTitle(String(numberOfFilesPending), for: UIControlState.normal)
                        tableViewCell?.btnSurveyDesc.setTitle(NSLocalizedString("Uploading", comment: ""),for: .normal)
                        tableViewCell?.setNeedsDisplay()
                    }
                }
        }
    }
    
    func setUpSegmentController(){
        self.geoFencedView?.isHidden = true
        self.shimmeringView!.isHidden = false
        hideGeoFencePopUp()
        self.segmentedControl.backgroundColor = UIColor.white
        self.segmentedControl.tintColor = AppTheme.appBackgroundColor()
        self.segmentedControl.selectedSegmentIndex = 0
        self.segmentedControl.subviews[0].tintColor = AppTheme.appBackgroundColor()
        self.segmentedControl.subviews[1].tintColor = AppTheme.appBackgroundColor()

    }
    
    func createDummySurveyList() {
        self.surveyFilteredList.removeAll()
        let survey = OPGSurvey()
        for i in 1...10 {
            survey.surveyName = "                         ";
            survey.lastUpdatedDate = ""
            survey.isOffline = 0
            survey.isGeoFencing = 0
            survey.surveyReference = ""
            survey.estimatedTime = 0
            survey.deadline = ""
            survey.surveyDescription = "xyz"
            survey.surveyID = i as NSNumber!
            self.surveyFilteredList.append(survey)
        }
    }
    
    func performAPIOperations() {
        print("Called APIOpr")
        let blockOperationPanles = BlockOperation {
            print("blockOperationPanles")
            self.getPanellistPanels()
        }
        queue.addOperation(blockOperationPanles)
        
        let blockOperationSurveys = BlockOperation {
            print("blockOperationSurveys")
            self.getSurveys()
        }
        queue.addOperation(blockOperationSurveys)
        blockOperationSurveys.addDependency(blockOperationPanles)
        
        let blockOperationProfile = BlockOperation {
            print("blockOperationProfile")
            self.getPanellistProfile()
        }
        queue.addOperation(blockOperationProfile)
        blockOperationProfile.addDependency(blockOperationSurveys)
        
        let blockOperationPanlesfromDB = BlockOperation {
            print("blockOperationPanlesfromDB")
            self.getPanelsfromDB()
        }
        queue.addOperation(blockOperationPanlesfromDB)
        blockOperationPanlesfromDB.addDependency(blockOperationProfile)
        
        let blockOperationSurveysFromDB = BlockOperation {
            print("blockOperationSurveysFromDB")
            self.getSurveysFromDB()
        }
        queue.addOperation(blockOperationSurveysFromDB)
        blockOperationSurveysFromDB.addDependency(blockOperationPanlesfromDB)
        
    }
    

    func checkforAvailableSurveys() {
        print("checkforAvailableSurveys \(self.surveyFilteredList.count)")
        if self.surveyFilteredList.count > 0 {
            self.lblNoSurveys?.isHidden = true
        } else {
            self.lblNoSurveys?.isHidden = false
            self.lblNoSurveys?.text = NSLocalizedString("No surveys available for the selected panel.", comment: "")
        }
    }
    
    func setUpSegmentedController() {
        let isAvailable: Bool? = UserDefaults.standard.value(forKey: "isGeoFencingAvailable") as? Bool
        if isAvailable == true {
            self.segmentedControl.isHidden = false
            self.view.layoutIfNeeded()

            UIView.animate(withDuration: 0.5, animations: {
                self.constraintShimmeringTop.constant = 45.0
                self.constraintGeoFenceTop.constant = 45.0
                self.view.layoutIfNeeded()
            })
        } else {
            self.segmentedControl.isHidden = true
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.5, animations: {
                self.constraintShimmeringTop.constant = 0
                self.constraintGeoFenceTop.constant = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func addGradientBackgroundLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.frame
        
        let colorTop: AnyObject = UIColor(red: 255.0/255.0, green: 145.0/255.0, blue: 43.0/255.0, alpha: 1.0).cgColor
        let colorBottom: AnyObject = UIColor(red: 255.0/255.0, green: 92.0/255.0, blue: 63.0/255.0, alpha: 1.0).cgColor
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func getSurveys() {
        let isAlreadyDownload: Int? = UserDefaults.standard.value(forKey: isDownload) as? Int
        if isAlreadyDownload != 1 {
            print("Downloading Surveys")
            let sdk = OPGSDK()
            do {
                if super.isOnline() {
                    let surveyList: Array<OPGSurvey> = try sdk.getUserSurveyList() as! Array
                    if surveyList.count > 0 {
                        for (index,element) in surveyList.enumerated() {
                            print("getSurveys\(index)")
                            isOfflineDownloaded.append(0)
                            CollabrateDB.sharedInstance().saveSurveys(element, with: true)
                        }
                    }
                } else {
                    UserDefaults.standard.set(0, forKey: isDownload)
                    super.showNoInternetConnectionAlert()
                }
            } catch let err as NSError {
                print("Error: \(err)")
                UserDefaults.standard.set(0, forKey: isDownload)
            }
        }
    }
    
    func getPanellistProfile() {
        let isAlreadyDownload: Int? = UserDefaults.standard.value(forKey: isDownload) as? Int
        if isAlreadyDownload != 1 {
            print("Downloading Panellist Profile")
            let sdk = OPGSDK()
            do {
                if super.isOnline() {
                    let panelist:OPGPanellistProfile = try sdk.getPanellistProfile() as OPGPanellistProfile
                    if (panelist.countryName != nil && panelist.std != nil) {
                        print(panelist)
                        CollabrateDB.sharedInstance().save(panelist)
                        CollabrateDB.sharedInstance().saveCountry(panelist.countryName, withStd: panelist.std)
                        UserDefaults.standard.set(1, forKey: isDownload)
                    }
                }
                else {
                    UserDefaults.standard.set(0, forKey: isDownload)
                    super.showNoInternetConnectionAlert()
                }
            }
            catch let err as NSError {
                print("Error: \(err)")
                UserDefaults.standard.set(0, forKey: isDownload)
            }
        }
    }
    
    func setThemeBGImage() {
        let headerLogoBGImagePath: String = AppTheme.getHeaderLogoImagePath()
        if (headerLogoBGImagePath.isEmpty) {
            let logoText: String = AppTheme.getLogoText()
            if logoText.isEmpty {
                // set default logo Image
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
                imageView.contentMode = .scaleAspectFit
                let image = UIImage(named: "applogo.png")
                imageView.image = image
                self.tabBarController?.navigationItem.titleView = imageView
            }
            else {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
                label.numberOfLines = 1
                label.textAlignment = .center
                label.adjustsFontSizeToFitWidth = true
                label.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
                label.text = logoText
                label.textColor = UIColor.white
                self.tabBarController?.navigationItem.titleView = label
            }
        }
        else {
            let fileExists = FileManager().fileExists(atPath: headerLogoBGImagePath)
            if fileExists {
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
                imageView.contentMode = .scaleAspectFit
                imageView.image = UIImage(contentsOfFile:headerLogoBGImagePath)           //set theme logo  image
                imageView.backgroundColor = UIColor.clear
                self.tabBarController?.navigationItem.titleView = imageView
            }
        }
    }
    
    func stringFromDate(_ date: NSDate) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let customLocale = Locale(identifier: "en_US")
        dateFormat.locale = customLocale
        let dateString: String = (dateFormat.string(from: date as Date)).replacingOccurrences(of: "+0000", with: "")
        return dateString
    }
    
    func getSurveysFromDB() {
        print("getSurveysFromDB")
        let panelid: String? = UserDefaults.standard.value(forKey: selectedPanelID) as? String

        if let panelID = panelid {
            let surveyPanelFactory: SurveyPanelFactory = SurveyPanelFactory()
            let surveyFactory: SurveyFactory = SurveyFactory()
            let myInteger = Int(panelID)
            let myNumber = NSNumber(value:myInteger!)
//            dispatchQueue.async(flags: .barrier) {
//            }
            let array: Array<SurveyPanel> = surveyPanelFactory.find(byPanelID:myNumber) as! Array<SurveyPanel>
            var dummyList:Array<Any> = []
            self.surveyList = []

            let blockTakeFromDB = BlockOperation {
                for item in array {
                    let surveysArray: Array<Survey> = surveyFactory.find(bySurveyID:item.surveyID) as! Array<Survey>
                    for survey in surveysArray {
                        let opgSurvey: OPGSurvey =  OPGSurvey()
                        opgSurvey.surveyName = survey.name
                        opgSurvey.surveyDescription = survey.status;
                        opgSurvey.surveyReference = survey.description;
                        opgSurvey.lastUpdatedDate = self.stringFromDate(survey.lastUpdatedDate as NSDate)
                        if (survey.createdDate == nil) {
                            opgSurvey.createdDate = ""
                            opgSurvey.startDate = ""
                        } else {
                            opgSurvey.createdDate = self.stringFromDate(survey.createdDate as NSDate)
                            opgSurvey.startDate = self.stringFromDate(survey.createdDate as NSDate)   // check once why its used the same again
                        }
                        if (survey.deadLine == nil) {
                            opgSurvey.endDate = ""
                            opgSurvey.deadline = ""
                        } else {
                            opgSurvey.endDate = self.stringFromDate(survey.deadLine as NSDate)
                            opgSurvey.deadline = self.stringFromDate(survey.deadLine as NSDate)
                        }
                        opgSurvey.isOffline = NSNumber(value:Int(survey.isOffline))
                        opgSurvey.isGeoFencing = NSNumber(value:Int(survey.isGeofencing))
                        opgSurvey.surveyID = survey.surveyID;
                        opgSurvey.estimatedTime = survey.estimatedTime;
                        opgSurvey.isOfflineDownloaded = NSNumber(value:Int(survey.occurences))
                        dummyList.append(opgSurvey)
                    }
                }

                OperationQueue.main.addOperation({
                    print("In OperationQueue Main thread")
                    UserDefaults.standard.set(2, forKey: "isOperating")
                    let userLoggedIn: String? = UserDefaults.standard.object(forKey: "isUserLoggedIN") as? String

                    if userLoggedIn == "0" {
                        UserDefaults.standard.set("1", forKey: "isUserLoggedIN")
                    }
                    else{
                        self.isAppKilled = false
                    }

                    self.surveyList = dummyList.reversed()
                    self.filterSurveyList()
                    self.OfflineDownloadList.removeAll()
                    self.downloadSurveys()
                    self.checkForGeoFencing()
                    self.shimmeringView?.isShimmering = false
                    self.tableView?.isUserInteractionEnabled = true     //Enable table after refresh/shimmer
                    self.tableView?.layoutIfNeeded()
                    self.tableView!.reloadData()
                    self.checkforAvailableSurveys()
                    self.setUpSegmentedController()
                    if self.bannerView != nil
                    {
                        self.hideBanner()
                    }
                    self.stopSpinning()
                })
            }
            queue.addOperation(blockTakeFromDB)
        }
        else{
         // Need to implement
        }
    }
    
    func filterSurveyList() {
        self.surveyFilteredList.removeAll()
        self.surveyGeoAvailable.removeAll()
        if self.surveyList.count > 0 {
            for item in self.surveyList {
                let survey: OPGSurvey = item as! OPGSurvey
                if survey.isGeoFencing == 0 {
                    self.surveyFilteredList.append(survey)
                } else {
                    self.surveyGeoAvailable.append(survey)
                }
            }
        }
    }
    
    func checkForGeoFencing() {
        for i in 0 ..< surveyList.count {
            let survey: OPGSurvey = surveyList[i] as! OPGSurvey
            print(survey.isGeoFencing);
            if survey.isGeoFencing == 1 {
                UserDefaults.standard.set(true, forKey: "isGeoFencingAvailable")
                return
            }
        }
        UserDefaults.standard.set(false, forKey: "isGeoFencingAvailable")
        
    }

    func checkIfPanelExists(panelsArray: Array<OPGPanel>, panelID: String?) -> OPGPanel? {
        if panelID != nil {
            if panelsArray.count > 0 {
                for panel in panelsArray {
                    if let pID = panel.panelID {
                        if panelID == String(describing: pID) {
                            return panel
                        }
                    }
                }
                return nil
            }
        }
        return nil
    }
    
    func getPanelsfromDB()  {
        print("getPanelsfromDB")
        let panelName : String? = UserDefaults.standard.value(forKey: selectedPanelName) as? String
        let panelID : String? = UserDefaults.standard.value(forKey: selectedPanelID) as? String
        var themeTempID : String? = UserDefaults.standard.value(forKey: "selectedThemeTemplateID") as? String

        if themeTempID == nil {
            let panelsArray : Array<OPGPanel> = (CollabrateDB.sharedInstance().getPanels() as? Array<OPGPanel>)!
            if panelsArray.count > 0 {
                var currentPanel: OPGPanel?
                if let panel = self.checkIfPanelExists(panelsArray: panelsArray, panelID: panelID) {
                    currentPanel = panel
                }
                else {
                    currentPanel = panelsArray.first
                }
                if let panelID = currentPanel?.panelID {
                    UserDefaults.standard.set(String(describing: panelID), forKey: selectedPanelID)                  //set panelID again
                }
                if let themeTemplateID = currentPanel?.themeTemplateID {
                    UserDefaults.standard.set(String(describing: themeTemplateID), forKey: "selectedThemeTemplateID")
                }
                if let panelName = currentPanel?.panelName {
                    UserDefaults.standard.set(panelName, forKey: selectedPanelName)
                }
                UserDefaults.standard.synchronize()
                let panelIDStr : String? = UserDefaults.standard.value(forKey: selectedPanelID) as? String              //fetch the updated panelID again
                themeTempID = UserDefaults.standard.value(forKey: "selectedThemeTemplateID") as? String
                if panelIDStr != nil && themeTempID != nil {
                    let dict = CollabrateDB.sharedInstance().getThemesForPanelID(panelIDStr, themeTemplateID: themeTempID)            //set theme after login if there is any available
                    if ((dict?.count)! > 0) {
                        AppTheme.setCurrentTheme(theme: dict!)
                        DispatchQueue.main.async {
                            self.setThemeForViews()
                        }
                    }
                    print("SelectedPanelID is \(panelID)")
                }
            }
        }
    }

    func getPanellistPanels()  {
        let isAlreadyDownloaded: Int?  = UserDefaults.standard.value(forKey: isDownload) as? Int
        if isAlreadyDownloaded != 1 {
            let sdk  =  OPGSDK()
            do {
                if super.isOnline() {
                    print("Fetching Panellist Panels from API")
                    let panellistPanels: OPGPanellistPanel? =  try sdk.getPanellistPanel() as OPGPanellistPanel
                    if panellistPanels?.isSuccess == 1 {
                        if ((panellistPanels?.surveyPanelArray.count)! > 0) || (panellistPanels?.surveyPanelArray != nil) {
                            let surveyPanelArray: Array<OPGSurveyPanel> = panellistPanels?.surveyPanelArray as! Array
                            for (index,element) in surveyPanelArray.enumerated() {
                                CollabrateDB.sharedInstance().saveSurveyPanels(element)
                            }
                        }
                        if ((panellistPanels?.panelPanelistArray.count)! > 0) || (panellistPanels?.surveyPanelArray != nil) {
                            let panelPanellistArray: Array<OPGPanelPanellist> = panellistPanels?.panelPanelistArray as! Array
                            for (index, element) in panelPanellistArray.enumerated() {
                                UserDefaults.standard.set(element.panellistID.stringValue, forKey: "PanelListID")
                                CollabrateDB.sharedInstance().save(element)
                            }
                        }
                        if (panellistPanels?.themesArray != nil) {
                            let themeArray: Array<OPGTheme> = panellistPanels?.themesArray as! Array
                            for (index,element) in themeArray.enumerated() {
                                CollabrateDB.sharedInstance().saveThemes(element)
                            }
                        }
                        if ((panellistPanels?.panelsArray.count)! > 0 || (panellistPanels?.panelsArray != nil)) {
                            let panelsArray: Array<OPGPanel> = panellistPanels?.panelsArray as! Array
                            for (index, element) in panelsArray.enumerated() {
                                CollabrateDB.sharedInstance().savePanels(element)
                            }
                        }
                    }
                    else {
                        UserDefaults.standard.set(0, forKey: isDownload)
                        if(panellistPanels?.statusMessage != nil) {
                            super.showAlert(alertTitle: NSLocalizedString("MySurveys", comment: ""), alertMessage: (panellistPanels?.statusMessage)!, alertAction: NSLocalizedString("OK", comment: "OK"))
                        }
                    }
                } else {
                    UserDefaults.standard.set(0, forKey: isDownload)
                    super.showNoInternetConnectionAlert()
                }
                
            } catch let err as NSError {
                print("Error at loading PanellistPanels: \(err.description)")
                UserDefaults.standard.set(0, forKey: isDownload)
            }
        }
        
    }
    
    func stopDownloadSurveys(){
        if self.OfflineDownloadList.count > 0{
            for (index, items) in self.surveyList.enumerated() {
                if ((self.surveyList[index] as! OPGSurvey).isOffline == 1) {
                    if (self.surveyList[index] as! OPGSurvey).isOfflineDownloaded == 1 {
                        (self.OfflineDownloadList[index] as? OfflineDownload)?.stopDownloadingSurvey()
                        
                    }
                }
                
            }
        }
        self.OfflineDownloadList.removeAll()
        
    }
    
    func findIndexOfSurey(_ survey:OPGSurvey) -> Int {
        for (index, item) in self.surveyFilteredList.enumerated() {
            if survey.surveyID == (item as! OPGSurvey).surveyID {
                return index
            }
        }
        return -1
    }
    
    func reDownloadOfflineSurvey(sender:UIButton!) {
        self.downloadSurveys()
    }
    
    func downloadSurveys() {
        for (index, items) in surveyList.enumerated() {
            let dataObject = OfflineDownload()
            dataObject.surveyObj = (items as! OPGSurvey)
            
            
            if ((self.surveyList[index] as! OPGSurvey).isOffline == 1) {
                if (self.surveyList[index] as! OPGSurvey).isOfflineDownloaded == 0  || self.isAppKilled == true {
                    if super.isOnline() {
                        
                        var array: Array<Any>? = UserDefaults.standard.value(forKey: "downloadSurveysArray") as? Array<Any>
                        array?.append((self.surveyList[index] as! OPGSurvey).surveyID)
                        UserDefaults.standard.set(array, forKey: "downloadSurveysArray")
                        dispatchQueue.async(flags: .barrier) {
                            CollabrateDB.sharedInstance().updateSurvey(((items as! OPGSurvey).surveyID), withStatus: "Downloading...", withDownloadStatus: 1)
                        }

                        //  let sur:OPGSurvey = CollabrateDB.sharedInstance().getSurvey((items as! OPGSurvey).surveyID)
                        let survey:OPGSurvey? = self.surveyList[index] as? OPGSurvey
                        survey?.surveyDescription = "Downloading..."
                        survey?.isOfflineDownloaded = 1
                        self.surveyList[index] = survey // reassign to array instead of dB call
                        
                        if survey?.isGeoFencing != 1 {
                            let indexForSurvey = self.findIndexOfSurey(survey!)
                            if indexForSurvey != -1 {
                                print("changing cell for non geofence survey \(survey?.surveyName)")
                                let indexPath = IndexPath(item: indexForSurvey, section: 0)
                                let tableViewCell: SurveyTableViewCell? = self.tableView?.cellForRow(at: indexPath) as? SurveyTableViewCell
                                tableViewCell?.btnSurveyDesc.setTitle(NSLocalizedString("Downloading...", comment: ""),for: .normal)
                                tableViewCell?.setNeedsDisplay()
                            }
                        }
                        
                        dispatchQueue.async(flags: .barrier) {
                            dataObject.downloadOfflineSurvey(self.surveyList[index] as! OPGSurvey) { [weak self] progress, survey, error in
                                
                                if error != nil {
                                    let isOperating: Int? = UserDefaults.standard.value(forKey: "isOperating") as? Int
                                    print("Error in download operations \(error?.localizedDescription)")
                                    dispatchQueue.async(flags: .barrier) {
                                        CollabrateDB.sharedInstance().updateSurvey(survey?.surveyID, withStatus: "Download", withDownloadStatus: 0)
                                    }
                                    let array: Array<Any>? = UserDefaults.standard.value(forKey: "downloadSurveysArray") as? Array<Any>
                                    if array == nil {
                                        return
                                    }
                                    if (array?.count)! > 0 {
                                        let filteredArray: Array<Any> = (array?.filter { ($0 as? NSNumber) != survey?.surveyID })!
                                        UserDefaults.standard.set(filteredArray, forKey: "downloadSurveysArray")
                                    } else {
                                        self?.isAppKilled = false
                                    }
                                    
                                    if isOperating == 2 {
                                        let currentSurvey:OPGSurvey? = self?.surveyList[index] as? OPGSurvey
                                        if currentSurvey != nil {
                                            if (currentSurvey?.surveyName == survey?.surveyName){
                                                currentSurvey?.surveyDescription = NSLocalizedString("Download", comment: "")
                                                currentSurvey?.isOfflineDownloaded = 0
                                                self?.surveyList[index] = currentSurvey
                                                if survey?.isGeoFencing != 1 {
                                                    let indexForSurvey = self?.findIndexOfSurey(survey!)
                                                    if indexForSurvey != -1 {
                                                        let indexPath = IndexPath(item: indexForSurvey!, section: 0)
                                                        let tableViewCell: SurveyTableViewCell? = self?.tableView?.cellForRow(at: indexPath) as? SurveyTableViewCell
                                                        if (tableViewCell != nil){
                                                            tableViewCell?.progressBar?.progress = 0.0
                                                            tableViewCell?.btnSurveyDesc.setTitleColor(AppTheme.appBackgroundColor(), for: .normal)
                                                            tableViewCell?.btnSurveyDesc.setTitle(NSLocalizedString("Download", comment: ""),for: .normal)
                                                            tableViewCell?.btnSurveyDesc.isUserInteractionEnabled = true
                                                            tableViewCell?.btnSurveyDesc.isEnabled = true
                                                            tableViewCell?.btnSurveyDesc.addTarget(self, action: #selector(self?.reDownloadOfflineSurvey(sender:)), for: .touchUpInside)
                                                            tableViewCell?.setNeedsDisplay()
                                                        }
                                                    }
                                                } else {
                                                    print("Download failed for a geofencing survey \(survey?.surveyName)")
                                                }
                                            }
                                        }
                                    }
                                    
                                } else {
                                    
                                    if progress == 1.0{
                                        let array: Array<Any>? = UserDefaults.standard.value(forKey: "downloadSurveysArray") as? Array<Any>
                                        if array == nil {
                                            return
                                        }
                                        if (array?.count)! > 0 {
                                            let surveyID: NSNumber? = survey?.surveyID
                                            let filteredArray: Array<Any> = (array?.filter { ($0 as? NSNumber) != surveyID })!
                                            UserDefaults.standard.set(filteredArray, forKey: "downloadSurveysArray")
                                        }
                                        dispatchQueue.async(flags: .barrier) {
                                            CollabrateDB.sharedInstance().updateSurvey(survey?.surveyID, withStatus: "New", withDownloadStatus: 2)
                                        }
                                    }
                                    
                                    let isIndexValid = self?.surveyList.indices.contains(index)
                                    if ( isIndexValid )!{
                                        
                                        let currentSurvey:OPGSurvey? = self?.surveyList[index] as? OPGSurvey
                                        if (currentSurvey != nil){
                                            if (currentSurvey?.surveyReference == survey?.surveyReference){
                                                if progress == 1.0{
                                                    currentSurvey?.surveyDescription = NSLocalizedString("New", comment: "")
                                                    currentSurvey?.isOfflineDownloaded = 2
                                                    self?.surveyList[index] = currentSurvey
                                                }
                                                if survey?.isGeoFencing != 1 {
                                                    let indexForSurvey = self?.findIndexOfSurey(survey!)
                                                    if indexForSurvey != -1 {
                                                        let indexPath = IndexPath(item: indexForSurvey!, section: 0)
                                                        let tableViewCell: SurveyTableViewCell? = self?.tableView?.cellForRow(at: indexPath) as? SurveyTableViewCell
                                                        if (tableViewCell != nil){
                                                            tableViewCell?.progressBar?.progressTintColor = AppTheme.appBackgroundColor()        //theme for profgress bar
                                                            tableViewCell?.progressBar?.progress = Float(progress!)
                                                            if progress == 1.0{
                                                                tableViewCell?.progressBar?.progress = 0.0
                                                                tableViewCell?.btnSurveyDesc.setTitleColor(UIColor.lightGray, for: .normal)
                                                                tableViewCell?.btnSurveyDesc.setTitle(NSLocalizedString("New", comment: ""),for: .normal)
                                                                tableViewCell?.btnSurveyDesc.isUserInteractionEnabled = true
                                                                tableViewCell?.btnSurveyDesc.isEnabled = true
                                                                tableViewCell?.btnSurveyDesc.removeTarget(self, action: nil, for: .touchUpInside)
                                                                print("progressCompleted:\(progress)")
                                                                tableViewCell?.setNeedsDisplay()
                                                            }
                                                            else{
                                                                tableViewCell?.setNeedsDisplay()
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    print("Downloaded a geofencing survey \(survey?.surveyName)")
                                                }
                                                
                                            }
                                        }
                                    }
                                    
                                    
                                }
                                self?.OfflineDownloadList.append(dataObject)
                            }
                        }
                    } else {
                        super.showNoInternetConnectionAlert()
                        
                    }
                }
            }
        }
        
    }
    
    func rightBarButtonItemSetUp() {
        // self.refreshButton = UIButton()
        let refreshButtonItem = UIBarButtonItem()
        var refreshButton = UIButton()
        refreshButton.setImage(UIImage(named: "refresh"), for: .normal)
        refreshButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        refreshButton.addTarget(self, action: #selector(refreshButtonAction), for: .touchUpInside)
        refreshButtonItem.customView = refreshButton
        self.tabBarController?.navigationItem.setRightBarButton(refreshButtonItem, animated: true)
    }
    
    func toDeleteorSaveNotification(_ toDelete: Bool) {
        if toDelete {
            let notificationArr: [NSDictionary]? = CollabrateDB.sharedInstance().loadNotifications() as? [NSDictionary]
            if (notificationArr?.count)! > 0 {
                for dict in notificationArr! {
                    let newDict = NSDictionary()
                    newDict.setValue(dict.value(forKey: "Title"), forKey: "title")
                    newDict.setValue(dict.value(forKey: "Body"), forKey: "body")
                    newDict.setValue(dict.value(forKey: "LastUpdated"), forKey: "LastUpdated")
                    newDict.setValue(dict.value(forKey: "IsRead"), forKey: "IsRead")
                    self.notificationsArray?.append(newDict)
                }
            }
        } else {
            if self.notificationsArray != nil {
                if (self.notificationsArray?.count)! > 0 {
                    for item in self.notificationsArray! {
                        let dict: [String:Any] = item as! [String: Any]
                        CollabrateDB.sharedInstance().saveLocalNotifications(dict)
                    }
                }
            }
        }
    }

    // Called only during refresh action
    func getGeofencedSurveys() {
        let locationManager = CLLocationManager()
        self.myLocation = locationManager.location?.coordinate
        if self.myLocation != nil {
            var arrayLocations: NSArray = []
            dispatchQueue.async(flags: .barrier) {
                let sdk = OPGSDK()
                do {
                    arrayLocations = try sdk.getGeofenceSurveys(Float((self.myLocation?.latitude)!), longitude: Float((self.myLocation?.longitude)!)) as NSArray
                    DispatchQueue.main.async {
                        if arrayLocations.count > 0 {
                            self.saveGeofenceSurveysToDB(arrayLocations as! [OPGGeofenceSurvey])
                        }
                        else {
                            print("No geofenced survey locations to monitor")
                        }
                    }
                }
                catch let err as NSError {
                    DispatchQueue.main.async {
                        print("Error: \(err)")
                        super.showAlert(alertTitle: NSLocalizedString("MySurveys", comment: ""), alertMessage: NSLocalizedString("Oops! Unknown error. Please try again.", comment: ""), alertAction: NSLocalizedString("OK", comment: "OK"))
                    }
                }
            }
        }
        
    }

    func saveGeofenceSurveysToDB(_ locations: [OPGGeofenceSurvey]!) {
        let array: Array<OPGGeofenceSurvey> = (locations)!
        if (array.count) > 0 {
            dispatchQueue.async(flags: .barrier) {
                for survey in array {
                    CollabrateDB.sharedInstance().saveGeoFenceSurveys(survey)
                }
                DispatchQueue.main.async {
                    var error: NSError?
                    self.geofencedArrays = locations //CollabrateDB.sharedInstance().getAllGeoFenceSurveys()
                    if self.geofencedArrays.count > 0 {
                        geoFence?.startMonitor(forGeoFencing: self.geofencedArrays as! [OPGGeofenceSurvey], error: &error)
                        if error != nil {
                            print(error.debugDescription)
                            super.showAlert(alertTitle: NSLocalizedString("MySurveys", comment: ""), alertMessage: NSLocalizedString("Oops! Unknown error. Please try again.", comment: ""), alertAction: NSLocalizedString("OK", comment: "OK"))
                        }
                    }
                }
            }
        }
    }
    

    
    func uploadResultsToServer(_ surveysArray: Array<Any>, completionHandler: @escaping (String?) -> Void ){
        if (surveysArray.count > 0) {
            let panellistID: String? = UserDefaults.standard.value(forKey: "PanelListID") as? String
            for survey in surveysArray {
                let surveyObj = survey as! OPGSurvey
                let isSuccess: Bool = self.uploadOfflineSurveys(surveyID: surveyObj.surveyID, panellistID: panellistID)
                if isSuccess == false {
                    completionHandler("Failure")
                    return
                }
            }
            completionHandler("Success")
        }
    }
    
    func getOfflineSurveysToUpload() -> Array<Any> {
        var surveysToUpload: Array<Any> = []
        let sdk = OPGSDK()
        for survey in self.surveyList {
            let surveyObj = survey as! OPGSurvey
            if (surveyObj.isOffline == 1) {
                let count = sdk.getOfflineSurveyCount(surveyObj.surveyID)
                if (count?.intValue)! > 0 {
                    surveysToUpload.append(surveyObj)
                }
            }
        }
        return surveysToUpload
    }
    
    func uploadOfflineSurveys(surveyID: NSNumber, panellistID:String?) -> Bool {
        let sdk = OPGSDK()
        let panellistID: String? = UserDefaults.standard.value(forKey: "PanelListID") as? String
        do {
            let result: OPGUploadResult = try sdk.uploadResults(surveyID.stringValue, panelistId:panellistID)                            //Updating the offline results
            if (result.isSuccess == 0){
                super.showAlert(alertTitle: NSLocalizedString("MySurveys", comment: ""), alertMessage: NSLocalizedString("Unable to upload results. Please try again!", comment: ""), alertAction: NSLocalizedString("OK", comment: ""))
                return false
            }
        }
        catch let err as NSError {
            print("Error: \(err)")
        }
        return true
    }

    func startSpinning(){
        let transform1 = CGAffineTransform(rotationAngle: CGFloat(-M_PI ))
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.repeat,.curveLinear],
                       animations: {
                        
                        self.tabBarController?.navigationItem.rightBarButtonItem?.customView!.transform = transform1
                        self.tabBarController?.navigationItem.rightBarButtonItem?.customView?.isUserInteractionEnabled = false
                        self.view.layoutIfNeeded()
        },
                       completion: nil
        )
        
    }
    
    func showBanner(progressTitle: String) {
        self.bannerTitle = progressTitle as NSString?
        self.bannerView = OPGNotificationView()
        self.bannerView?.initialisewithNavigation(title: progressTitle, referenceView: self.view, notificationType: .upload)
        self.view.addSubview(self.bannerView!)
        self.bannerView?.applyDynamics()
        
    }
    
    func hideBanner() {
        self.bannerView?.hideNotification()
        self.bannerView = nil
        //self.bannerTitle = nil
    }
    
    func stopSpinning(){
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.curveLinear],
                       animations: {
                        
                        self.tabBarController?.navigationItem.rightBarButtonItem?.customView?.transform = CGAffineTransform.identity
                        self.tabBarController?.navigationItem.rightBarButtonItem?.customView?.isUserInteractionEnabled = true
                        self.view.layoutIfNeeded()
                        
        },
                       completion: nil
        )
    }
    
    func deleteTempDBFolders() {
        if super.isOnline() {
            let filemanager = FileManager.default
            let documentsPath: String? = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0]
            let panelImagePath = documentsPath?.appending("/PanelImages")
            
            if filemanager.fileExists(atPath: panelImagePath!) {
                do {
                    try filemanager.removeItem(atPath: panelImagePath!)
                } catch let err as NSError {
                    print("Error occured while copying and the error is \(err.description)")
                }
                
            }
            OPGDB.deleteOldDatabase()
            OPGDB.initialize(withDBVersion: OPGConstants.sdk.DatabaseVersion)
        } else {
            super.showNoInternetConnectionAlert()
        }
    }

    // MARK: - IBOutlet Action methods
    @IBAction func segmentedControlAction(_ sender:UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            self.geoFencedView?.isHidden = true
            self.shimmeringView?.isHidden = false
            hideGeoFencePopUp()
            sender.subviews.last?.tintColor =  AppTheme.appBackgroundColor()
        case 1:
            self.geoFencedView?.isHidden = false
            self.shimmeringView?.isHidden = true
            self.startGeoFencingView()
            sender.subviews.first?.tintColor = AppTheme.appBackgroundColor()
        default:
            break;
        }
        
    }


    func refreshButtonAction() {
        let array: Array<Any>? = UserDefaults.standard.value(forKey: "downloadSurveysArray") as? Array<Any>
        if (array?.count)! > 0 {
            super.showAlert(alertTitle: NSLocalizedString("MySurveys", comment: ""), alertMessage: NSLocalizedString("Downloading surveys. Please wait!", comment: ""), alertAction: NSLocalizedString("OK", comment: "OK"))
            return
        }
        if super.isOnline() {
            UserDefaults.standard.set(3, forKey: "isOperating")                 //indicates refresh started
            self.isAppKilled = false
            self.startSpinning()
            self.tableView?.isUserInteractionEnabled = false                    //Disable table interaction during refresh/shimmer
            if self.surveyList.count == 0 {
                self.lblNoSurveys?.isHidden = true
            }
            self.stopDownloadSurveys()
            let downloadArray: Array<Any> = []
            UserDefaults.standard.set(downloadArray, forKey: "downloadSurveysArray")        // resetting download to get fresh update
            let surveysToUpload = self.getOfflineSurveysToUpload()
            if (surveysToUpload.count > 0) {
                /*************** Uploading Offline Results to Server and then Upload ***********/
                self.showBanner(progressTitle: NSLocalizedString("Uploading Offline Survey results", comment: ""))
                DispatchQueue.global(qos: .default).async {
                    self.uploadResultsToServer(surveysToUpload, completionHandler: { status in
                        if status == "Success" {
                            DispatchQueue.main.async {
                                self.hideBanner()
                                UserDefaults.standard.set(0, forKey: self.isDownload)
                                self.shimmeringView?.isShimmering = true
                                self.showBanner(progressTitle:NSLocalizedString("Sync in progress. Please wait!", comment: ""))
                                self.createDummySurveyList()
                                self.tableView?.reloadData()
                                //   self.toDeleteorSaveNotification(true)
                                self.deleteTempDBFolders()
                                self.performAPIOperations()
                                if UserDefaults.standard.value(forKey: "isGeoFenced") as? String == "1" {
                                    geoFence?.stopMonitorForGeoFencing()        // stop and then start monitoring otherwise invalid state
                                    self.getGeofencedSurveys()
                               }
                            }
                            
                        } else if status == "Failure" {
                            DispatchQueue.main.async {
                                self.hideBanner()
                                self.showBanner(progressTitle:NSLocalizedString("Error while uploading. Please Refresh again!", comment: ""))
                            }
                        }
                    })
                }
                /*******************************************************/
            } else {
                UserDefaults.standard.set(0, forKey: isDownload)
                self.shimmeringView?.isShimmering = true
                self.showBanner(progressTitle:NSLocalizedString("Sync in progress. Please wait!", comment: ""))
                self.createDummySurveyList()
                self.tableView?.reloadData()
                //    self.toDeleteorSaveNotification(true)
                self.deleteTempDBFolders()
                self.performAPIOperations()
                if UserDefaults.standard.value(forKey: "isGeoFenced") as? String == "1" {
                    geoFence?.stopMonitorForGeoFencing()            // stop and then start monitoring otherwise invalid state
                    self.getGeofencedSurveys()
                }
            }
        } else {
            super.showNoInternetConnectionAlert()
        }
    }

    // MARK: - Filtering Methods for geo-fencing
    func runThroughAddresses(address: String, surveyReference:String, isEntered: Bool) {
        print("runThroughAddresses")

        if geofencedArrays.count > 0 {
            if isEntered == true {
                for i in 0 ..< geofencedArrays.count {
                    let addresses = (geofencedArrays[i] as! OPGGeofenceSurvey).address
                    let surveyRef: String = (geofencedArrays[i] as! OPGGeofenceSurvey).surveyReference as String
                    if address.contains(addresses!) &&  surveyReference == surveyRef {
                        (geofencedArrays[i] as! OPGGeofenceSurvey).isDeleted = 2
                        print("Entered \(String(describing: addresses)) \(String(describing: surveyReference)) ")
                         let concurrentQueue = DispatchQueue(label: "updateGeoFenceSurvey2")
                            concurrentQueue.sync() {
                            CollabrateDB.sharedInstance().updateGeoFenceSurvey((self.geofencedArrays[i] as! OPGGeofenceSurvey).addressID, withSurveyReference: surveyRef, withStatus: 2)   //2 = entered
                        }
                        print("updateGeoFenceSurvey2Completed")

                    }
                }
            } else {
                for i in 0 ..< geofencedArrays.count {
                    let addresses = (geofencedArrays[i] as! OPGGeofenceSurvey).address
                    let surveyRef: String = (geofencedArrays[i] as! OPGGeofenceSurvey).surveyReference as String
                    if address.contains(addresses!) &&  surveyReference == surveyRef {
                        (geofencedArrays[i] as! OPGGeofenceSurvey).isDeleted = 1
                        let concurrentQueue = DispatchQueue(label: "updateGeoFenceSurvey1")
                        concurrentQueue.sync() {
                            CollabrateDB.sharedInstance().updateGeoFenceSurvey((self.geofencedArrays[i] as! OPGGeofenceSurvey).addressID, withSurveyReference: surveyRef, withStatus: 1)       //1 = exited
                        }
                        print("updateGeoFenceSurvey1Completed")

                    }
                }

            }
        }
        else {
            print("No geofenced surveys to run through address")
        }
    }

    func runThroughSurveyName(surveyName: String, isEntered: Bool) {
                    print("runThroughSurveyName")

        if geoFencedArrayFiltered.count > 0 {
            if isEntered == true {
                for i in 0 ..< geoFencedArrayFiltered.count {
                    let name = (geoFencedArrayFiltered[i] as! OPGGeofenceSurvey).surveyName
                    if surveyName.contains(name!) {
                        (geoFencedArrayFiltered[i] as! OPGGeofenceSurvey).isDeleted = 2              // isDeleted is used for Enter/Exit operations
                    }
                }

            } else {
                for i in 0 ..< geoFencedArrayFiltered.count {
                    let name = (geoFencedArrayFiltered[i] as! OPGGeofenceSurvey).surveyName
                    if !surveyName.contains(name!) {
                        (geoFencedArrayFiltered[i] as! OPGGeofenceSurvey).isDeleted = 1              // isDeleted is used for Enter/Exit operations
                    }
                }
            }
            let concurrentQueue = DispatchQueue(label: "getAllSurveys")
             concurrentQueue.sync() {
                self.geofencedArrays = CollabrateDB.sharedInstance().getAllGeoFenceSurveys()
             }
            print("getAllSurveysCompleted")

        }

    }
    
    func runThroughSurveyRef(_ surveyRef:String) -> OPGSurvey {
        let surv = OPGSurvey()
        if self.surveyList.count > 0 {
            for sur in self.surveyList {
                if (sur as! OPGSurvey).surveyReference == surveyRef {
                    return sur as! OPGSurvey
                }
            }
        }
        return surv
    }

    func runThroughAddressAnnontationGeoFenceSurvey(_ address: String,_ surveyReference: String) -> OPGGeofenceSurvey? {
        if (self.geofencedArrays.count > 0) && (self.surveyGeoAvailable.count > 0) {
            for sur in self.geofencedArrays {
                if (sur as! OPGGeofenceSurvey).address == address && (sur as! OPGGeofenceSurvey).surveyReference == surveyReference{                                          // compare address u got from annotataion with the list u got from dB
                    return sur as! OPGGeofenceSurvey
                }
            }
        }
        return nil
    }

//    func runThroughAddressAnnontationGeoFenceSurvey(_ address: String) -> OPGGeofenceSurvey {
//        let surv = OPGGeofenceSurvey()
//        if (self.geofencedArrays.count > 0) && (self.surveyGeoAvailable.count > 0) {
//            for sur in self.geofencedArrays {
//                if (sur as! OPGGeofenceSurvey).address == address {                                          // compare address u got from annotataion with the list u got from dB
//                    for geoAvailable in self.surveyGeoAvailable {
//                        if (geoAvailable as! OPGSurvey).surveyID == (sur as! OPGGeofenceSurvey).surveyID {     // compare and get the surveyID for the particular address entered
//                            return sur as! OPGGeofenceSurvey
//                        } else {
//                            //return sur as! OPGGeofenceSurvey
//                        }
//                    }
//                }
//            }
//        }
//        return surv
//    }

    func runThroAddressForAnnotationSelection(_ surveyReference:String) -> OPGSurvey{
        let surv = OPGSurvey()
        if self.surveyGeoAvailable.count > 0 {
            for geoSurvey in self.surveyGeoAvailable {
                if (geoSurvey as! OPGSurvey).surveyReference == surveyReference {
                    return geoSurvey as! OPGSurvey
                }
            }
        }
        return surv
    }
    
    
    func updateOfflineCounter(survey:OPGSurvey, indexPath: IndexPath, tableview: UITableView ) {
        print(indexPath)
        dispatchQueue.async(flags: .barrier) {
            let sdk = OPGSDK()
            do {
                let count: NSNumber = sdk.getOfflineSurveyCount(survey.surveyID)
                DispatchQueue.main.async {
                    if (count.intValue) > 0 {
                        let cell: SurveyTableViewCell? = tableview.cellForRow(at: indexPath) as? SurveyTableViewCell
                        cell?.offlineFileCountButton.isHidden = false                //show counter if there is any survey to be uploaded
                        cell?.offlineFileCountButton.setTitle(count.stringValue, for: UIControlState.normal)
                        cell?.setNeedsDisplay()
                    }
                }
            }
        }
    }

    func uploadResults(sender: UIButton!) {
        let indexPath = IndexPath(item: sender.tag, section: 0)
        let tableViewCell: SurveyTableViewCell? = self.tableView?.cellForRow(at: indexPath) as? SurveyTableViewCell
        tableViewCell?.btnSurveyDesc.isUserInteractionEnabled = false
        let survey = self.surveyFilteredList[sender.tag] as! OPGSurvey
        if survey.surveyID == nil {
            return
        }
        dispatchQueue.async(flags: .barrier) {
            let upload = UploadSurvey.sharedInstance
            let panellistID: String? = UserDefaults.standard.value(forKey: "PanelListID") as? String
            CollabrateDB.sharedInstance().updateSurvey(survey.surveyID, withStatus: "Uploading", withDownloadStatus: 99)
            upload.uploadOfflineSurvey(survey.surveyID, panelistID:panellistID!, index:indexPath)       // check with chinthan for optional(thamarai)
        }
    }
    
    func uploadGeoFenceOfflineResults(sender: UIButton!) {
        let indexPath = IndexPath(item: sender.tag, section: 1)
        let tableViewCell: SurveyTableViewCell? = self.tableViewGeoFenced?.cellForRow(at: indexPath) as? SurveyTableViewCell
        tableViewCell?.btnSurveyDesc.isUserInteractionEnabled = false
        let survey = self.geoFencedArrayFiltered[sender.tag] as! OPGGeofenceSurvey
        if survey.surveyID == nil {
            return
        }
        dispatchQueue.async(flags: .barrier) {
            let upload = UploadSurvey.sharedInstance
            let panellistID: String? = UserDefaults.standard.value(forKey: "PanelListID") as? String
            CollabrateDB.sharedInstance().updateSurvey(survey.surveyID, withStatus: "Uploading", withDownloadStatus: 99)
            upload.uploadOfflineSurvey(survey.surveyID, panelistID:panellistID!, index:indexPath)
        }
    }

    // MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.tableView){
            return self.surveyFilteredList.count;
        } else {
            return self.geoFencedArrayFiltered.count;
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         if UIDevice.current.userInterfaceIdiom == .pad {
            return 105.0
        } else {
            return 90.0
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewCell: SurveyTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Surveys") as! SurveyTableViewCell
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            tableViewCell.selectButton.setImage(UIImage(named: "survey_nav_iPad.png"), for: .normal)
            if tableViewCell.selectButton.bounds.size.width < 61.0 {
                // Apply default iPad width and height - TEMP FIX for app kill and come back to home page
                tableViewCell.selectButton.layer.cornerRadius = 0.5 * 61.0
                tableViewCell.offlineFileCountButton.layer.cornerRadius = 0.5 * 61.0
            }
            else {
                tableViewCell.selectButton.layer.cornerRadius = 0.5 * tableViewCell.selectButton.bounds.size.width
                tableViewCell.offlineFileCountButton.layer.cornerRadius = 0.5 * tableViewCell.offlineFileCountButton.bounds.size.width
            }
        }
        else {
            tableViewCell.selectButton.setImage(UIImage(named: "survey_nav.png"), for: .normal)
            if tableViewCell.selectButton.bounds.size.width > 45.0 {
                tableViewCell.selectButton.layer.cornerRadius = 0.5 * 45.0
                tableViewCell.offlineFileCountButton.layer.cornerRadius = 0.5 * 45.0
            }
            else {
                tableViewCell.selectButton.layer.cornerRadius = 0.5 * tableViewCell.selectButton.bounds.size.width
                tableViewCell.offlineFileCountButton.layer.cornerRadius = 0.5 * tableViewCell.offlineFileCountButton.bounds.size.width
            }
        }
        
        if(tableView == self.tableView) {
            let survey: OPGSurvey = self.surveyFilteredList[indexPath.row] as! OPGSurvey
            tableViewCell.fillCell(survey)
            tableViewCell.btnSurveyDesc.tag = indexPath.row
            tableViewCell.offlineFileCountButton.setTitle("", for: .normal)
            tableViewCell.offlineFileCountButton.isHidden=true
            if survey.isOffline == 1 && survey.surveyDescription == "Upload Results" {
                tableViewCell.btnSurveyDesc.isUserInteractionEnabled = true
                tableViewCell.btnSurveyDesc.isEnabled = true
                tableViewCell.btnSurveyDesc.addTarget(self, action: #selector(self.uploadResults(sender:)), for: .touchUpInside)
                self.updateOfflineCounter(survey: survey, indexPath: indexPath, tableview: self.tableView!)                 // get count only for surveys with upload results status.
                tableViewCell.constarintCounterBtnSpace.constant = (tableViewCell.offlineFileCountButton.frame.width+20)    // reduce surveyName field size to accomodate counter
            }
            else {
                tableViewCell.constarintCounterBtnSpace.constant = 15          // default constarint after refresh/reload
            }
            if survey.isOffline == 1 {
                if survey.isOfflineDownloaded != 1 {
                    if survey.surveyReference != nil || survey.surveyReference != "" {
                        print("indexPathCell: \(indexPath.row)")
                    }
                }
            }
        }
        
        if tableView == self.tableViewGeoFenced {
            let survey: OPGGeofenceSurvey = self.geoFencedArrayFiltered[indexPath.row] as! OPGGeofenceSurvey
            //tableViewCell.selectButton.backgroundColor = UIColor.lightGray
            tableViewCell.btnSurveyDesc.tag = indexPath.row
            tableViewCell.offlineFileCountButton.setTitle("", for: .normal)
            tableViewCell.offlineFileCountButton.isHidden = true
            for item in self.surveyGeoAvailable {
                let normalSurvey: OPGSurvey = item as! OPGSurvey
                if survey.surveyID == normalSurvey.surveyID {
                    tableViewCell.fillCell(normalSurvey)

                    survey.createdDate = normalSurvey.surveyDescription
                    if normalSurvey.isOffline == 1 && normalSurvey.surveyDescription == "Upload Results" {
                        tableViewCell.btnSurveyDesc.isUserInteractionEnabled = true
                        tableViewCell.btnSurveyDesc.isEnabled = true
                        tableViewCell.btnSurveyDesc.addTarget(self, action: #selector(self.uploadGeoFenceOfflineResults(sender:)), for: .touchUpInside)
                        self.updateOfflineCounter(survey: normalSurvey, indexPath: indexPath, tableview: self.tableViewGeoFenced!)                 // get count only for surveys with upload results status.
                        tableViewCell.constarintCounterBtnSpace.constant = (tableViewCell.offlineFileCountButton.frame.width+20)    // reduce surveyName field size to accomodate counter
                    }
                    
                }
                else {
                    tableViewCell.constarintCounterBtnSpace.constant = 15          // default constarint after refresh/reload
                }
            }
           tableViewCell.fillCellGeoFenced(survey)             //for color enable and disable
        }
        tableViewCell.selectionStyle = UITableViewCellSelectionStyle.none
        return tableViewCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            let tableViewCell: SurveyTableViewCell = tableView.cellForRow(at: indexPath) as! SurveyTableViewCell
            let survey: OPGSurvey = self.surveyFilteredList[indexPath.row] as! OPGSurvey
            self.surveySelected = survey
            self.surveyStatus = tableViewCell.btnSurveyDesc.titleLabel?.text as NSString?
            if (survey.isOffline.boolValue == false ) {
                self.performSegue(withIdentifier: "embedSurveyDetails", sender: self)
                
            } else
            {
                let index = IndexPath(item: indexPath.row , section: 0) // section 0 is normal tableview
                self.selectedOfflineSurveyIndex = index
                self.performSegue(withIdentifier: "embedOfflineSurveyDetails", sender: self)
            }
        } else {
            let survey: OPGGeofenceSurvey? = self.geoFencedArrayFiltered[indexPath.row] as? OPGGeofenceSurvey
            if survey != nil {
                if survey?.isDeleted == 2 {                     // if survey entered
                    // goto survey details screen based on selection
                    let index = IndexPath(item: indexPath.row , section: 1) // section 1 is Geofenced tableview
                    self.selectedOfflineSurveyIndex = index
                    self.performGeoFencingPush(survey?.surveyReference)
                } else {
                    super.showAlert(alertTitle: NSLocalizedString("MySurveys", comment: ""), alertMessage: NSLocalizedString("You are not in this location to take the survey!", comment: ""), alertAction: NSLocalizedString("OK", comment: ""))
                }
            }
        }
    }

    /*
     MARK: - Navigation
     
     In a storyboard-based application, you will often want to do a little preparation before navigation
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.isAppKilled = false
        if(segue.identifier == "embedSurveyDetails")
        {
            let viewController: SurveyDetailsViewController = segue.destination as! SurveyDetailsViewController
            viewController.surveyID = self.surveySelected?.surveyID
            viewController.surveySelected = self.surveySelected
        } else if(segue.identifier == "embedOfflineSurveyDetails")
        {
            let viewController: OfflineSurveyViewController = segue.destination as! OfflineSurveyViewController
            viewController.surveyID = self.surveySelected?.surveyID
            viewController.surveySelected = self.surveySelected
            viewController.selectedSurveyIndex = self.selectedOfflineSurveyIndex
        }
    }

    func didEnterSurveyRegion(_ regionEntered: OPGGeofenceSurvey!) {
                    print("didEnterSurveyRegion")

        dispatchQueue.async(flags: .barrier) {
            if (regionEntered != nil) {
                self.runThroughAddresses(address: regionEntered.address, surveyReference: regionEntered.surveyReference, isEntered: true)
                self.runThroughSurveyName(surveyName: regionEntered.surveyName, isEntered: true)
                let appState = UIApplication.shared.applicationState
                let dict: [String:Any] = ["LastUpdated": "2017-01-03T12:35:06",
                                               "Type": 0,
                                               "AppNotificationID": 1,
                                               "title": regionEntered.surveyName,
                                               "body": NSLocalizedString("Welcome to", comment: "") + " \(regionEntered.address!)! " + NSLocalizedString("You have a survey available at this location", comment: ""),
                                               "IsRead": "0"]
                    print("dict created \(dict)")

                if appState == UIApplicationState.active {
                    let concurrentQueue = DispatchQueue(label: "getAllSurveys")
                    concurrentQueue.sync() {
                        CollabrateDB.sharedInstance().saveLocalNotifications(dict)
                    }
                }
                DispatchQueue.main.async {
                    print("Dispach main")

                    self.tableViewGeoFenced?.reloadData()       //enable surveys with orange color
                    if appState == UIApplicationState.active {
                        self.showGeoAlerts(regionEntered)
                    }
                    else {
                        //if app is inactive, send notifications
                        if #available(iOS 10.0, *) {
                            let content = UNMutableNotificationContent()

                            content.title = NSLocalizedString("MySurveys", comment: "")
                            content.body = NSLocalizedString("Welcome to", comment: "") + " \(regionEntered.address!)! " + NSLocalizedString("You have a survey available at this location", comment: "")
                            content.userInfo = dict
                            let trigger = UNTimeIntervalNotificationTrigger(
                                timeInterval: 0.3,
                                repeats: false)

                            let request = UNNotificationRequest(
                                identifier: regionEntered.address,
                                content: content,
                                trigger: trigger
                            )
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            UNUserNotificationCenter.current().add(
                                request, withCompletionHandler: nil)
                        } // TODO: write code for iOS9.0 and below
                        else {
                            let notification = UILocalNotification()
                            if #available(iOS 8.2, *) {
                                notification.alertTitle = NSLocalizedString("MySurveys", comment: "")
                            } else {
                                // Fallback on earlier versions
                            }
                            notification.alertBody = NSLocalizedString("Welcome to", comment: "") + " \(regionEntered.address!)! " + NSLocalizedString("You have a survey available at this location", comment: "")
                            notification.fireDate = NSDate(timeIntervalSinceNow:0.3) as Date
                            UIApplication.shared.cancelAllLocalNotifications()
                            UIApplication.shared.scheduledLocalNotifications = [notification]
                        }
                    }
                }
            }
        }
    }

    func didExitSurveyRegion(_ regionExited: OPGGeofenceSurvey) {
        print("region exited is \(regionExited.address)")
        dispatchQueue.async(flags: .barrier) {
            self.runThroughSurveyName(surveyName: regionExited.surveyName, isEntered: false)
            DispatchQueue.main.async {
                self.tableViewGeoFenced?.reloadData()               //disnable surveys with gray color
            }
        }
    }

    func showGeoAlerts(_ regions: OPGGeofenceSurvey) {
        let alert = UIAlertController.init(title: NSLocalizedString("MySurveys", comment: ""), message: ("Welcome to \(regions.address!)!. You have a survey available!"), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Take Survey", comment: ""), style: UIAlertActionStyle.default, handler: {
            action in
            self.alertsArray.removeFirst()
            self.performGeoFencingPush(regions.surveyReference)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: {
            action in
            self.alertsArray.removeFirst()
            if self.alertsArray.count > 0 {
                self.present(self.alertsArray.first as! UIAlertController, animated: true, completion: nil)
            }
        }))
        alertsArray.append(alert)
        self.present(alert, animated: true, completion: nil)
    }
    
    func performGeoFencingPush(_ surveyReference: String?) {
        self.surveySelected = self.runThroughSurveyRef(surveyReference!)
        if (surveyReference != nil) && (self.surveySelected?.surveyReference == nil) {
            super.showAlert(alertTitle: NSLocalizedString("MySurveys", comment: ""), alertMessage: NSLocalizedString("Selected survey is not under current Panel. Please change the panel to take survey!", comment: ""), alertAction: "OK")
            return
        }
        if (self.surveySelected?.isOffline.boolValue == false ) {
            self.performSegue(withIdentifier: "embedSurveyDetails", sender: self)

        } else {
            if self.surveySelected?.isOfflineDownloaded == 2 {
                self.performSegue(withIdentifier: "embedOfflineSurveyDetails", sender: self)
            }
            else {
                //if script is not downloaded, take them to home screen
                self.tabBarController?.selectedIndex = 0
            }
        }
    }

    //  MARK: - GeoFence Survey Methods
    func startGeoFencingView() {
        self.lblNoSurveys?.isHidden = true
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                print("No Location access")
                self.setUpGeoFeningView(false)
                showGeoFencePopUp(NSLocalizedString("Please enable location services from device Settings to take the survey.", comment: ""))
                return
            case .authorizedAlways, .authorizedWhenInUse:
                print("Location Access granted")
            }
        } else {
            showGeoFencePopUp(NSLocalizedString("Location Services not enabled!", comment: ""))
            return
        }
        let geoFenceValue: String? = UserDefaults.standard.value(forKey: "isGeoFenced") as? String

        if (geoFenceValue != nil) &&  (geoFenceValue == "1") {
            // calls when you kill the app and come back
            if self.geofencedArrays.count == 0 {
                self.geofencedArrays = CollabrateDB.sharedInstance().getAllGeoFenceSurveys()
            }
            if self.geofencedArrays.count > 0 {
                self.geoFencedTableViewSetUp()
                self.setUpGeoFeningView(true)
                self.removeOverlaysFromMap()
                self.loadInitialData()
            }
            else {
                self.setUpGeoFeningView(false)       //show only map view with no surveys and do nothing
            }
        }
        else if (geoFenceValue == nil) ||  (geoFenceValue == "0") {
            self.setUpGeoFeningView(false)              //show only map view with no surveys
            self.removeOverlaysFromMap()
            self.showGeoFencePopUp(NSLocalizedString("To take your location based surveys turn on ‘Geolocation’ from the App Settings", comment: ""))
        }
    }

    func removeOverlaysFromMap() {
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        let allOverlays = self.mapView.overlays
        self.mapView.removeOverlays(allOverlays)
    }

    func setUpGeoFeningView(_ isGeoFenced: Bool) {
        self.view.layoutIfNeeded()
        if isGeoFenced {
            if geoFencedArrayFiltered.count > 1 {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    self.tableViewGeoFenced?.isScrollEnabled = true
                    self.constraintGeotableViewHeight.constant = 210
                    self.constraintMapViewHeight.constant = (self.geoFencedView?.bounds.size.height)! - 211
                }
                else {
                    self.tableViewGeoFenced?.isScrollEnabled = true
                    self.constraintGeotableViewHeight.constant = 180
                    self.constraintMapViewHeight.constant = (self.geoFencedView?.bounds.size.height)! - 181
                }
                
            }
            else if geoFencedArrayFiltered.count == 1 {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    self.tableViewGeoFenced?.isScrollEnabled = false
                    self.constraintGeotableViewHeight.constant = 105
                    self.constraintMapViewHeight.constant = (self.geoFencedView?.bounds.size.height)! - 106
                }
                else {
                    self.tableViewGeoFenced?.isScrollEnabled = false
                    self.constraintGeotableViewHeight.constant = 90
                    self.constraintMapViewHeight.constant = (self.geoFencedView?.bounds.size.height)! - 91
                }
            }
        }
        else {
            self.constraintMapViewHeight.constant = (self.geoFencedView?.bounds.size.height)!
            self.constraintGeotableViewHeight.constant = 0
        }
        self.view.layoutIfNeeded()
    }

    func geoFencedTableViewSetUp() {
        self.tableViewGeoFenced?.separatorStyle = UITableViewCellSeparatorStyle.none
        var dummyArray: Array<Any> = []
        self.geoFencedArrayFiltered = []
        var surveyNames: Array<String> = []
        for i in 0 ..< geofencedArrays.count {
            let surName = (geofencedArrays[i] as? OPGGeofenceSurvey)?.surveyName            // check once PROM models updated
            if let name = surName {
                if !surveyNames.contains(name) {
                    dummyArray.append(geofencedArrays[i])                       //filter to avoid mduplication
                    surveyNames.append(name)
                }
            }
        }
        self.geoFencedArrayFiltered = dummyArray.filter { dummy in
            return self.surveyGeoAvailable.contains { survey in
                (survey as! OPGSurvey).surveyReference == (dummy as! OPGGeofenceSurvey).surveyReference
            }
        }
        self.tableViewGeoFenced?.reloadData()
    }

    func showGeoFencePopUp(_ message: String) {
        noGeoFenceView = UIView.init(frame: CGRect(x: 15, y: UIScreen.main.bounds.size.height/3, width: UIScreen.main.bounds.size.width - 30, height: 60))
        noGeoFenceView?.backgroundColor = UIColor.black
        noGeoFenceView?.alpha = 0.7
        noGeoFenceView?.layer.cornerRadius = 4
        
        let labelRect = CGRect(x: 0,y: 0, width: UIScreen.main.bounds.size.width - 30, height: 60)
        let titleLabel = UILabel(frame: labelRect)
        titleLabel.numberOfLines = 4
        titleLabel.text = message
        titleLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = NSTextAlignment.center
        
        noGeoFenceView?.addSubview(titleLabel)
        self.view.addSubview(noGeoFenceView!)
        Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(hideGeoFencePopUp), userInfo: nil, repeats: false)
        
    }

    func hideGeoFencePopUp() {
        if self.noGeoFenceView != nil {
            self.noGeoFenceView?.removeFromSuperview()
        }
    }

    //   MARK: - Map Functions
    func loadInitialData() {
        var coordinate:CLLocationCoordinate2D!
        self.mapView.showsUserLocation = true
        for geoFencedArea: OPGGeofenceSurvey in self.geofencedArrays as! Array<OPGGeofenceSurvey> {
            let latitude = Double(geoFencedArea.latitude)
            let longitude = Double(geoFencedArea.longitude)
            let address = geoFencedArea.address as String
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let point = MyPointAnnotation()
            point.identifier = geoFencedArea.surveyReference as String
            point.title = address
            point.subtitle = NSLocalizedString("Welcome! You have a survey here!", comment: "")
            point.coordinate = coordinate
            mapView.addAnnotation(point)
            self.loadOverlayForRegionWithLatitude(latitude, andLongitude: longitude,geoFencedArea.range.doubleValue)
        }
        if self.mapView.userLocation.location != nil {
            let lat = self.mapView.userLocation.location?.coordinate.latitude
            let lon = self.mapView.userLocation.location?.coordinate.longitude
            let initialLocation  = CLLocation(latitude: lat!, longitude: lon!)
            centerMapOnLocation(initialLocation)
        }
    }

    func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }

    func loadOverlayForRegionWithLatitude(_ latitude: Double, andLongitude longitude: Double, _ range: Double) {
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let circle = MKCircle(center: coordinates, radius: range)
        self.mapView.add(circle)
    }

    func mapView(_ mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = AppTheme.appBackgroundColor().withAlphaComponent(0.2)
        circleRenderer.strokeColor = AppTheme.appBackgroundColor().withAlphaComponent(0.7)
        circleRenderer.lineWidth = 2
        return circleRenderer
    }

    func mapView(_ mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView! {
        let identifier = "pin"
        var view: MKPinAnnotationView
        if annotation.isMember(of: MKUserLocation.self) {
            return nil
        }
        else{
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.rightCalloutAccessoryView = UIButton(type: UIButtonType.custom)
                view.centerOffset = CGPoint(x: 0, y: -32)
                
                let deleteButton = UIButton(type: UIButtonType.system) as UIButton
                deleteButton.frame.size.width = 35
                deleteButton.frame.size.height = 35
                deleteButton.backgroundColor = UIColor.white
                deleteButton.setImage(UIImage(named: "survey_nav"), for: UIControlState())
                view.rightCalloutAccessoryView = deleteButton
            }
            self.addBounceAnimationToView(view)
        }
        return view
    }

    func mapView(_ mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        //get tag here
        if(annotationView.tag == 0){
            //Do for 0 pin
        }
        
        if self.mapView.selectedAnnotations.count > 0 {
            
            if let selectedLoc = self.mapView.selectedAnnotations[0] as? MyPointAnnotation {
                print("Annotation has been selected")
                let address: String? = selectedLoc.title!
                let surveyRef: String = selectedLoc.identifier!
                let survey: OPGGeofenceSurvey? = runThroughAddressAnnontationGeoFenceSurvey(address!, surveyRef)
                if survey != nil {
                    if survey?.isDeleted == 2 {
                        self.surveySelected = self.runThroAddressForAnnotationSelection((survey?.surveyReference)!)
                        if (self.surveySelected?.surveyReference == "") || (self.surveySelected?.surveyReference == nil) {
                            super.showAlert(alertTitle: NSLocalizedString("MySurveys", comment: ""), alertMessage: NSLocalizedString("Selected survey is not under current Panel. Please change the panel to take survey!", comment: ""), alertAction: NSLocalizedString("OK", comment: "OK"))
                        } else {
                            if (self.surveySelected?.isOffline.boolValue == false ) {
                                self.performSegue(withIdentifier: "embedSurveyDetails", sender: self)
                            } else {
                                self.performSegue(withIdentifier: "embedOfflineSurveyDetails", sender: self)
                            }
                        }
                        
                    } else if survey?.isDeleted == 1 {
                        super.showAlert(alertTitle: NSLocalizedString("MySurveys", comment: ""), alertMessage: NSLocalizedString("Sorry! You are not in survey location. So, you can not take the survey.", comment: ""), alertAction: NSLocalizedString("OK", comment: "OK"))
                    }
                    
                }
                
            }
        }
    }

    func addBounceAnimationToView(_ view: UIView) {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale") as CAKeyframeAnimation
        bounceAnimation.values = [ 0.05, 1.1, 0.9, 1]
        
        let timingFunctions = NSMutableArray(capacity: bounceAnimation.values!.count)
        
        for i in 0 ..< bounceAnimation.values!.count {
            timingFunctions.add(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        }
        bounceAnimation.timingFunctions = timingFunctions as NSArray as? [CAMediaTimingFunction]
        bounceAnimation.isRemovedOnCompletion = false
        view.layer.add(bounceAnimation, forKey: "bounce")
    }

    deinit {
        print("DEINIT CALLEDDDDDDDDDDDD Survey")
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "NotificationIdentifier"), object: nil);
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "OPGGeofencedArraysObtained"), object: nil);
    }
}
