
import UIKit

class CustomizeImage: UIImageView {
    
    
    // Image variables
    var ciImage: CIImage!
    var hueCIImg: CIImage!
    var sepiaCIImg: CIImage!
    var newUIImage: UIImage!
    var uiImage: UIImage!
    var orientation: UIImageOrientation = .up
    
    // Filters
    var hueFilter: CIFilter!
    var sepiaFilter: CIFilter!
 
    
    // Blur variablesn
    var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    var ciContext: CIContext!
    
    
    
    func applyHueEffect(amount: Float) {
 
            if self.sepiaCIImg != nil{
                self.hueFilter.setValue(self.sepiaCIImg, forKey: "inputImage")
            }
            else{
                self.hueFilter.setValue(ciImage, forKey: "inputImage")
              }
        
            self.hueFilter.setValue(amount, forKey: "inputSaturation")
            
             // Get the output CIImage from the CIFilter.
             if let hueOutput = self.hueFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
                self.hueCIImg = hueOutput
                self.applyFilter(hueOutput)
            }
 
        
    }
    
    
    
    
    
    func applySepiaEffect(amount: Float){
 
            if self.hueCIImg != nil{
                self.sepiaFilter?.setValue(self.hueCIImg, forKey: kCIInputImageKey)
            }else{
                self.sepiaFilter?.setValue(self.ciImage, forKey: kCIInputImageKey)
            }
 
            self.sepiaFilter?.setValue(amount, forKey: "inputIntensity")
            if let sepiaOutput = self.sepiaFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
                
                let exposureFilter = CIFilter(name: "CIExposureAdjust")
                exposureFilter?.setValue(sepiaOutput, forKey: kCIInputImageKey)
                exposureFilter?.setValue(1, forKey: kCIInputEVKey)
                
                if let exposureOutput = exposureFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
                    self.sepiaCIImg = exposureOutput
                    self.applyFilter(exposureOutput)
                }
                
            }
            
 
    }
    
    
    
    
    
    func applyBlurEffect(amount: Float){
        visualEffectView.frame = calculateRectOfImageInImageView()
        self.addSubview(visualEffectView)
        visualEffectView.alpha = CGFloat(amount)
        
    }
    
    
    
    
    
    
    func initFiltersAndContext(){
        
        uiImage = self.image
        let cgImage = uiImage?.cgImage;
        
        // Core Image operates on CIImage, instead of UIImage
        ciImage = CIImage(cgImage: cgImage!)
        
        hueFilter = CIFilter(name: "CIColorControls");
        hueFilter.setValue(ciImage, forKey: "inputImage")
        sepiaFilter = CIFilter(name:"CISepiaTone")
        sepiaFilter.setValue(ciImage, forKey: "inputImage")
 
        hueCIImg = nil
        sepiaCIImg = nil
        
        // Use the GPU instead of CPU for image processing
        let openGLContext = EAGLContext(api: .openGLES3)
        ciContext = CIContext(eaglContext: openGLContext!);
        
        // Preserve the orientation before conversions strip it away
        orientation = (uiImage?.imageOrientation)!
        
    }
    
    
    
    
    func resetImg(){
        if self.image != nil{
            self.image = uiImage
            visualEffectView.alpha = CGFloat(0)
            sepiaCIImg = nil
            hueCIImg = nil 
        }
    }
    
    
    
    
    
    func calculateRectOfImageInImageView() -> CGRect {
        let imageViewSize = self.frame.size
        let imgSize = self.image?.size
        
        guard let imageSize = imgSize, imgSize != nil else {
            return CGRect.zero
        }
        
        let scaleWidth = imageViewSize.width / imageSize.width
        let scaleHeight = imageViewSize.height / imageSize.height
        let aspect = fmin(scaleWidth, scaleHeight)
        
        var imageRect = CGRect(x: 0, y: 0, width: imageSize.width * aspect, height: imageSize.height * aspect)
        // Center image
        imageRect.origin.x = (imageViewSize.width - imageRect.size.width) / 2
        imageRect.origin.y = (imageViewSize.height - imageRect.size.height) / 2
        
        // Add imageView offset
        imageRect.origin.x += self.frame.origin.x
        imageRect.origin.y += self.frame.origin.y
        
        return imageRect
    }
    
    
    
    
    
    
    
    
    // Applying Image After Changes
    func applyFilter(_ img: CIImage){
        
        // Convert the CIImage to a CGImage.
        // Convert the CGImage to a UIImage, and display it in the image view.
        
        // let cgImage = ciContext.createCGImage(outputImage, from: outputImage.extent)
        
        let cgImage = ciContext.createCGImage(img, from: img.extent)
        
        newUIImage = UIImage(cgImage: cgImage!, scale:1, orientation:orientation)
        
        self.image = newUIImage
        
    }
    
    
    
    
    
    
}
