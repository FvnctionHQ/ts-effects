//
//  TSMixerTableViewCell.swift
//  Transfer
//
//  Created by Alex Linkov on 12/2/20.
//  Copyright © 2020 SDWR. All rights reserved.
//

import UIKit
import AudioKit
import SoundpipeAudioKit
import TSUtils

public typealias TSParamsDidTapBlock = () -> Void
public typealias TSEffectSliderDidChangeBlock = () -> Void

class TSMixerTableViewCell: UITableViewCell {
    
    var sliderBlock: TSEffectSliderDidChangeBlock!
    var paramsTapBlock: TSParamsDidTapBlock!
    var mixer: DryWetMixer?
    let gradient: CAGradientLayer = CAGradientLayer()
    
    @IBOutlet weak var paramsToggle: TSButton!
    @IBOutlet weak var slider: UISlider!
    override func awakeFromNib() {
        super.awakeFromNib()
//        let colors = [
//                    UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1.0).cgColor,
//                    UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0).cgColor]
//        gradient.frame = bounds
//        gradient.colors = colors
//        self.layer.insertSublayer(gradient, at: 0)
        
        self.contentView.backgroundColor = .black
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func  configureWithMixer(mixer: TSDryWetMixer) {
        self.mixer = mixer.mixer
        paramsToggle.setTitle(mixer.name, for: .normal)
        paramsToggle.style(with: .standardLookSmallInactive)
        
        
        if (slider != nil) {
            
            slider.minimumValue = Float(0)
            slider.maximumValue = Float(1)
            slider.tintColor =  .red
            slider.thumbTintColor = .red
            slider.value = (self.mixer?.balance)!

    //
           
            slider.thumbTintColor = .lightGray
            slider.tintColor = .lightGray
            
            slider.setThumbImage(UIImage(named: "sliderThumb17"), for: .normal)
            slider.setThumbImage(UIImage(named: "sliderThumb17"), for: .focused)
            slider.setThumbImage(UIImage(named: "sliderThumb17"), for: .highlighted)
        }

    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
    
    @IBAction func didChange(_ sender: UISlider) {
        
        self.mixer?.balance  = sender.value
        sliderBlock()
    }
    
    @IBAction func didTapParams(_ sender: UIButton) {
        
        paramsTapBlock()
        
    }
    
}
