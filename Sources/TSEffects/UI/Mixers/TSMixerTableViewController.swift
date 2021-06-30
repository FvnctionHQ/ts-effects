//
//  TSMixerTableViewController.swift
//  Transfer
//
//  Created by Alex Linkov on 12/2/20.
//  Copyright © 2020 SDWR. All rights reserved.
//

import UIKit
import AudioKit
import EasyPeasy
import TSUtils
import TSLog

class TSMixerTableViewController: UITableViewController, TSEffectsModuleUIInterface {
   
    
    func showPlaybackStoppedUI() {
        
        playBtn.setImage(UIImage(named: "play-icn"), for: .normal)

    }
    
    func reloadData() {
        tableView.reloadData()
        updateDoneBtn()
    }
    

    unowned let effectsDataSoure: TSEffectsModuleUIDataSource
    let fileName: String
    var delegate: TSEffectsModuleUIDelegate?
    let selectBtn = UIButton()
    var playBtn: UIButton!
    var loopBtn: UIButton!
    var doneBtn: UIButton!
    var resetFXBtn: UIButton!
    
    required init(effectDataSource: TSEffectsModuleUIDataSource, delegate: TSEffectsModuleUIDelegate, fileName: String) {
        self.effectsDataSoure = effectDataSource
        self.delegate = delegate
        self.fileName = fileName
        TSLog.sI.logCall()
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    deinit {
        TSLog.sI.logCall()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
        tableView.backgroundColor = .black
        tableView.register(UINib(nibName: "TSMixerTableViewCell", bundle: Bundle.module), forCellReuseIdentifier: "TSMixerTableViewCell")
        
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80)
        headerView.backgroundColor = .white
        selectBtn.setTitle("    \(fileName)    ", for: .normal)
        selectBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        selectBtn.setTitleColor(UIColor.darkGray.withAlphaComponent(0.5), for: .normal)

        let cancelBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        cancelBtn.setImage(UIImage.init(systemName: "xmark")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
        cancelBtn.tintColor = .black
        cancelBtn.addTarget(self, action: #selector(cancelDidTap), for: .touchUpInside)
        
        doneBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        doneBtn.tintColor = .black
      
        doneBtn.setTitle("   Apply FX   ", for: .normal)
        doneBtn.setTitleColor(.black, for: .normal)
        doneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        // doneBtn.setImage(UIImage.init(systemName: "checkmark.circle.fill")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
        doneBtn.addTarget(self, action: #selector(doneDidTap), for: .touchUpInside)
        doneBtn.backgroundColor = .white
        doneBtn.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        doneBtn.layer.borderWidth = 2
       
        doneBtn.layer.cornerRadius = 4
        doneBtn.isEnabled = false
        doneBtn.setTitleColor(.lightGray, for: .disabled)
        
        
        selectBtn.addTarget(self, action: #selector(playDidTap), for: .touchUpInside)
        
        headerView.addSubview(selectBtn)
        headerView.addSubview(cancelBtn)
        headerView.addSubview(doneBtn)
        
        selectBtn.easy.layout(
          Height(34),
            CenterX(0.0).to(headerView),
            CenterY(0.0).to(headerView)
        )
        
        doneBtn.easy.layout(
            Height(30),
            Right(20).to(headerView),
            CenterY(0.0).to(headerView)
        )
        
        cancelBtn.easy.layout(
            Height(44),
            Left(20).to(headerView),
            CenterY(0.0).to(headerView)
        )
        
        tableView.separatorStyle = .none
        tableView.tableHeaderView = headerView
        
        
        let footerView = UIView()
        footerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80)
        footerView.backgroundColor = UIColor(hexCode: "#F8F8F8")
        

        footerView.layer.cornerRadius = 16
        footerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        playBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        playBtn.setImage(UIImage(named: "play-icn"), for: .normal)
        playBtn.tintColor = .black
        playBtn.addTarget(self, action: #selector(playDidTap), for: .touchUpInside)
        
        footerView.addSubview(playBtn)
        
        loopBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        loopBtn.setImage(UIImage(named: "loop_on2"), for: .normal)
        loopBtn.tintColor = .black
        loopBtn.addTarget(self, action: #selector(loopDidTap), for: .touchUpInside)
        loopBtn.layer.opacity = 0.4
        
        footerView.addSubview(loopBtn)
        
        
        resetFXBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        resetFXBtn.tintColor = .black
        resetFXBtn.addTarget(self, action: #selector(resetFXDidTap), for: .touchUpInside)
        
        resetFXBtn.setTitle("   Reset   ", for: .normal)
        resetFXBtn.setTitleColor(.black, for: .normal)
        resetFXBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        
        resetFXBtn.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        resetFXBtn.layer.borderWidth = 2
       
        resetFXBtn.layer.cornerRadius = 4
        resetFXBtn.isEnabled = false
        resetFXBtn.setTitleColor(.lightGray, for: .disabled)
        
        footerView.addSubview(resetFXBtn)
        
        loopBtn.easy.layout(
            Height(44),
            Right(44).to(footerView),
            CenterY(0.0).to(footerView)
        )
        
        playBtn.easy.layout(
            Height(75),
            CenterX(0.0).to(footerView),
            CenterY(0.0).to(footerView)
        )
        
        resetFXBtn.easy.layout(
            Height(30),
            Left(44).to(footerView),
            CenterY(0.0).to(footerView)
        )
        
        tableView.tableFooterView = footerView

    }
    
    func updateDoneBtn() {
        let isEnabled = effectsDataSoure.activeEffectsCount() > 0
        doneBtn.isEnabled = isEnabled
        resetFXBtn.isEnabled = isEnabled
        
        
        if (resetFXBtn.isEnabled) {
            resetFXBtn.layer.borderColor = UIColor.black.cgColor
        } else {
            resetFXBtn.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        if (doneBtn.isEnabled) {
            doneBtn.layer.borderColor = UIColor.black.cgColor
        } else {
            doneBtn.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    @objc func loopDidTap() {
        
        self.delegate?.UIdidTouchLoop()
        

        
        if (self.effectsDataSoure.isLooping()) {
            
            loopBtn.layer.opacity = 1


        } else {
            
            loopBtn.layer.opacity = 0.4

        }
    }
    
    @objc func resetFXDidTap() {
        
        delegate?.UIdidTouchResetFX()
    }
    
    @objc func playDidTap() {
        
        self.delegate?.UIdidTouchPlay()
        
        if (self.effectsDataSoure.isPlaying()) {
            
            playBtn.setImage(UIImage(named: "pause-icn"), for: .normal)

        } else {
            
            playBtn.setImage(UIImage(named: "play-icn"), for: .normal)

        }
    }
    
    @objc func cancelDidTap() {
        
        self.delegate?.UIdidTouchCancel()
    }

    @objc func doneDidTap() {
        
        self.delegate?.UIdidTouchDone()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat( (self.tableView.bounds.size.height - self.tableView.tableHeaderView!.bounds.size.height - self.tableView.tableFooterView!.bounds.size.height - 30) / CGFloat(effectsDataSoure.effectsCount()))
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return effectsDataSoure.effectsCount()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TSMixerTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TSMixerTableViewCell", for: indexPath) as!  TSMixerTableViewCell
        let dw = effectsDataSoure.effectMixer(atIndex: indexPath.row)
        cell.configureWithMixer(mixer: dw)
        
        cell.sliderBlock = {  [weak self] in
            
            self?.updateDoneBtn()
        }
        cell.paramsTapBlock =  { [weak self] in
            
            self?.delegate?.UIdidRequestParams(forMixerAtIndex: indexPath.row, in: cell.paramsToggle)
        }
        
        
        if indexPath.row % 2 == 0 {
            cell.contentView.backgroundColor = UIColor(hexCode: "#101010")
        } else {
            cell.contentView.backgroundColor = UIColor(hexCode: "#0D0D0D")
        }
        
        cell.selectionStyle = .none
        return cell
    }
    


}
