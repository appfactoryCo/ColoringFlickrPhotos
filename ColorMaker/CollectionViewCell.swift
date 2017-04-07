
import UIKit

class CollectionViewCell: UICollectionViewCell {
 
    var photoImageView: UIImageView!
    
    
    override func awakeFromNib() {
        photoImageView = UIImageView(frame: contentView.frame)
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.clipsToBounds = true
        contentView.addSubview(photoImageView)
        
    }

    
}
