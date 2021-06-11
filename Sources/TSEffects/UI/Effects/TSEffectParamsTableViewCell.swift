//
//  TSEffectParamsTableViewCell.swift
//  TransferModular
//
//  Created by Alex Linkov on 6/10/21.
//

import UIKit
import AudioKit

public typealias TSParamDidChangeBlock = (Float) -> Void

class TSEffectParamsTableViewCell: UITableViewCell {

    @IBOutlet weak var effectParamNameLabel: UILabel!
    @IBOutlet weak var effectParamSlider: UISlider!
    
    var changeBlock: TSParamDidChangeBlock!
    var param: TSEffectParameter!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func  configureWith(param: TSEffectParameter) {
        self.param = param
        effectParamNameLabel.text = self.param.label
        
        
        if (effectParamSlider != nil) {
            
            effectParamSlider.minimumValue = self.param.range.lowerBound
            effectParamSlider.maximumValue = self.param.range.upperBound
            effectParamSlider.tintColor =  .white
            effectParamSlider.thumbTintColor = .white
            effectParamSlider.value = self.param.defaultValue

    //
           
            effectParamSlider.thumbTintColor = .lightGray
            effectParamSlider.tintColor = .lightGray
            
            effectParamSlider.setThumbImage(UIImage(named: "sliderThumb17"), for: .normal)
            effectParamSlider.setThumbImage(UIImage(named: "sliderThumb17"), for: .focused)
            effectParamSlider.setThumbImage(UIImage(named: "sliderThumb17"), for: .highlighted)
        }

    }
    
    @IBAction func didChange(_ sender: UISlider) {
        
        changeBlock(sender.value)
    }
    
}
