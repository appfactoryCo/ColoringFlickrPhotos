 
 import UIKit
 import CoreImage
 import AssetsLibrary
 import Photos
 
 // MARK: - ViewController: UIViewController
 
 class FlickrViewController: UIViewController, UITextFieldDelegate {
    
    
    // MARK: Outlets
    
    @IBOutlet weak var phraseTxtField: UITextField!
    @IBOutlet weak var latTxtField: UITextField!
    @IBOutlet weak var lngTxtField: UITextField!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var blurSlider: UISlider!
    @IBOutlet weak var hueSlider: UISlider!
    @IBOutlet weak var sepiaSlider: UISlider!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var imgView: CustomizeImage!
    
    
    
    // MARK: Variables & Constants
    
    var ciContext: CIContext!
    var index = 0
    var bottomViewOriginY: CGFloat = 0.0
    let alert = UIAlertController()
    
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phraseTxtField.delegate = self
        latTxtField.delegate = self
        lngTxtField.delegate = self
        topText.delegate = self
        bottomText.delegate = self
        
        topText.textAlignment = .center
        bottomText.textAlignment = .center
        
        ciContext = CIContext(options: nil);
        
        bottomViewOriginY = bottomView.frame.origin.y
        
        //Keep original icon colors in tab bar
        for item in (self.tabBarController?.tabBar.items as NSArray!){
            (item as! UITabBarItem).image = (item as! UITabBarItem).image?.withRenderingMode(.alwaysOriginal)
        }
        
        // Disable views if there is no image
        setViewIsEnabled()
        
    }
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // subscribeToKeyboardNotifications()
    }
    
    
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        imgView.visualEffectView.alpha = CGFloat(0)
        blurSlider.setValue(0.5, animated: true)
        
    }
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    
    
    
    // MARK: Action Methods
    
    @IBAction func hueSliderValueChange(_ sender: UISlider) {
        
        imgView.applyHueEffect(amount: sender.value)
        
    }
    
    
    
    @IBAction func sepiaSliderValueChange(_ sender: UISlider) {
        
        imgView.applySepiaEffect(amount: sender.value)
        
    }
    
    
    
    @IBAction func blurSliderValueChanged(_ sender: UISlider) {
        
        imgView.applyBlurEffect(amount: sender.value)
    }
    
    
    
    
    @IBAction func phraseSrchAction(_ sender: Any) {
        
        if phraseTxtField.text == ""{
            showAlert(title: "Empty Field", message: "Enter a search term.", autoDismiss: true)
            return
        }
        showAlert(title: "Searching Flickr...", message: phraseTxtField.text!, autoDismiss: false)
        reset(sender)
        latTxtField.text = ""
        lngTxtField.text = ""
        let phrase = phraseTxtField.text
        let paramsDictionary = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Format: "json",
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Text: phrase!
        ]
        
        // Set flickrDelegate protocol to self
        FlickrAPIRequests.Instance.flickrDelegate = self
        
        // Call the method for api requests
        FlickrAPIRequests.Instance.flickrAPIRequest(paramsDictionary as [String : AnyObject], page: 0)
    }
    
    
    
    
    @IBAction func latLngSrchAction(_ sender: Any) {
        
        if latTxtField.text == "" || lngTxtField.text == ""{
            showAlert(title: "Empty Field", message: "Enter latitude and longitude", autoDismiss: true)
            return
        }
        let alertMsg = "Latitude: \(latTxtField.text!)  Longitude: \(lngTxtField.text!)"
        showAlert(title: "Searching Flickr...", message: alertMsg, autoDismiss: false)
        phraseTxtField.text = ""
        reset(sender)
        let paramsDictionary = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Format: "json",
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.BoundingBox: bBoxString()
        ]
        
        // Set flickrDelegate protocol to self
        FlickrAPIRequests.Instance.flickrDelegate = self
        
        // Call the method for api requests
        FlickrAPIRequests.Instance.flickrAPIRequest(paramsDictionary as [String : AnyObject], page: 0)
    }
    
    
    
    
    
    @IBAction func share(_ sender:Any){
        
        if self.imgView.image != nil{
            
            let imgToShare = self.generateImageWithText()
            
            DispatchQueue.main.async(execute:{
                let controller = UIActivityViewController(activityItems: [imgToShare], applicationActivities: nil)
                self.present(controller, animated: true, completion: nil)
            })
            
        }
    }
    
    
    
    
    
    @IBAction func save(_ sender: UIButton) {
        
        // Add it to the array on the Application Delegate
        let imgToSave = self.generateImageWithText()
        let photo = Photo(text1: self.topText.text!, text2: self.bottomText.text!, image: self.imgView.image!, modImg: imgToSave)
        (UIApplication.shared.delegate as! AppDelegate).photos.append(photo)
        
        // Save to device's photo album
        UIImageWriteToSavedPhotosAlbum(imgToSave, self, #selector(imageSaveFinished(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    
    
    
    
    
    @IBAction func reset(_ sender: Any) {
        
        imgView.resetImg()
        
        hueSlider.setValue(0.5, animated: true)
        sepiaSlider.setValue(0.5, animated: true)
        blurSlider.setValue(0.5, animated: true)
        
    }
    
    
    
    
    
    // MARK: Helper Methods
    
    
    // Initialize CoreImage variables
    func setFiltersAndViews(){
        imgView.initFiltersAndContext()
        setViewIsEnabled()
    }
    
    
    
    // Enable UI elements if there is an image
    func setViewIsEnabled(){
        saveBtn.isEnabled = imgView.image != nil
        shareBtn.isEnabled = imgView.image != nil
        hueSlider.isEnabled = imgView.image != nil
        sepiaSlider.isEnabled = imgView.image != nil
        blurSlider.isEnabled = imgView.image != nil
        topText.isHidden = imgView.image == nil
        bottomText.isHidden = imgView.image == nil
        resetBtn.isHidden = imgView.image == nil
    }
    
    
    
    // Calculate bbox range
    private func bBoxString() -> String{
        
        if let lat = latTxtField.text, let lng = lngTxtField.text{
            
            var minLat = Double(lat)! - Constants.Flickr.SearchBBoxHalfHeight
            var maxLat = Double(lat)! + Constants.Flickr.SearchBBoxHalfHeight
            
            var minLng = Double(lng)! - Constants.Flickr.SearchBBoxHalfWidth
            var maxLng = Double(lng)! + Constants.Flickr.SearchBBoxHalfWidth
            
            minLat = max(minLat, Constants.Flickr.SearchLatRange.0)
            maxLat = min(maxLat, Constants.Flickr.SearchLatRange.1)
            
            minLng = max(minLng, Constants.Flickr.SearchLngRange.0)
            maxLng = min(maxLng, Constants.Flickr.SearchLngRange.1)
            return "\(minLng),\(minLat),\(maxLng),\(maxLat)"
        }
        return "0,0,0,0"
    }
    
    
    
    // Image Label
    func setImgLabel (_ text: String){
        if(topText.isHidden){
            topText.isHidden = false
        }
        topText.text = text
        dismissAlert()
    }
    
    
    
    
    // Generate Image
    func generateImageWithText() -> UIImage {
        
        if topText.text == ""{
            topText.isHidden = true
        }
        if bottomText.text == ""{
            bottomText.isHidden = true
        }
        
        // Render view to an image
        UIGraphicsBeginImageContextWithOptions(bottomView.frame.size, false, 0.0)
        bottomView.drawHierarchy(in: CGRect(origin: CGPoint.zero, size: (bottomView.frame.size)), afterScreenUpdates: true)
        
        let vibrancyEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .light))
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        bottomView.addSubview(vibrancyView)
        
        let img:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        topText.isHidden = false
        bottomText.isHidden = false
        
        return img
    }
    
    
    
    
    func imageSaveFinished(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // We got back an error!
            showAlert(title: "Saving Error", message: error.localizedDescription, autoDismiss: false)
            
        } else {
            showAlert(title: "Save Complete!", message: "Photo saved to the Photos album", autoDismiss: true)
        }
    }
    
    
    
    
    
    
    func showAlert(title: String, message: String, autoDismiss: Bool){
        
        if presentedViewController is UIAlertController{
            dismissAlert()
        }
        
        alert.title = title
        alert.message = message
        
        self.present(alert, animated: true, completion: nil)
        
        if(autoDismiss){
            // change to desired number of seconds (in this case 5 seconds)
            let when = DispatchTime.now() + 3
            DispatchQueue.main.asyncAfter(deadline: when){
                // your code with delay
                self.alert.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    
    
    
    func dismissAlert(){
        alert.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    // MARK: Keyboard Methods:
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        phraseTxtField.resignFirstResponder()
        latTxtField.resignFirstResponder()
        lngTxtField.resignFirstResponder()
        topText.resignFirstResponder()
        bottomText.resignFirstResponder()
        
        return false
    }
    
    
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        
        if textField == bottomText{
            subscribeToKeyboardNotifications()
        }else{
            unsubscribeFromKeyboardNotifications()
        }
        return true
    }
    
    
    
    
    func keyboardWillShow(_ notification:Notification) {
        
        if bottomView.frame.origin.y == bottomViewOriginY{
            bottomView.frame.origin.y -=  getKeyboardHeight(notification)
        }
    }
    
    
    
    
    func keyboardWillHide(_ notification:Notification) {
        
        if bottomView.frame.origin.y != bottomViewOriginY{
            bottomView.frame.origin.y +=  getKeyboardHeight(notification)
        }
        
    }
    
    
    
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
    
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    
    
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    
 }
 
 
 
 
 
 
 extension FlickrViewController: FlickrAPIRequestDelegate{
    
    func showFlickrPhoto(photo: UIImage){
        
        self.imgView.image = photo
        self.setFiltersAndViews()
    }
    
    
    func setPhotoTitle(photoTitle: String) {
        self.setImgLabel(photoTitle)
    }
    
    func showAlert(msg: String) {
        self.showAlert(title: "Error", message: msg, autoDismiss: true)
    }
    
 }
 
 
 
 
 
 
 
