
import Foundation
import UIKit 


struct Photo{
    
    let text1: String
    let text2: String
    let image: UIImage
    let modImg: UIImage
    
    
    init(text1: String, text2: String, image: UIImage, modImg: UIImage) {
        self.text1 = text1
        self.text2 = text2
        self.image = image
        self.modImg = modImg
    }
}


