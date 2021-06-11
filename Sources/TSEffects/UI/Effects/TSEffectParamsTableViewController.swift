//
//  TSEffectParamsTableViewController.swift
//  TransferModular
//
//  Created by Alex Linkov on 6/10/21.
//

import UIKit
import EasyPeasy

class TSEffectParamsTableViewController: UITableViewController {

    unowned let parameterDelegate: TSEffectsModuleEffectParametersUIDelegate
    unowned let parameterDataSource: TSEffectsModuleEffectParametersUIDataSource
    let effectType: TSEffectType
    let selectBtn = UIButton()
    
    required init(parameterDataSource: TSEffectsModuleEffectParametersUIDataSource, parameterDelegate: TSEffectsModuleEffectParametersUIDelegate, effectType: TSEffectType) {
        self.parameterDataSource = parameterDataSource
        self.parameterDelegate = parameterDelegate
        self.effectType = effectType
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
        headerView.backgroundColor = .black
        selectBtn.setTitle("    \(effectType.rawValue)    ", for: .normal)
        selectBtn.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        selectBtn.setTitleColor(UIColor.lightGray.withAlphaComponent(0.5), for: .normal)
        
        headerView.addSubview(selectBtn)
        
        selectBtn.easy.layout(
          Height(34),
            CenterX(0.0).to(headerView),
            CenterY(0.0).to(headerView)
        )
        
        
        tableView.tableHeaderView = headerView
        tableView.separatorInset = .zero
        tableView.separatorColor = .darkGray
        tableView.separatorStyle = .none
        tableView.backgroundColor = .black
        tableView.register(UINib(nibName: "TSEffectParamsTableViewCell", bundle: Bundle.module), forCellReuseIdentifier: "TSEffectParamsTableViewCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat( (self.tableView.bounds.size.height - self.tableView.tableHeaderView!.bounds.size.height) / CGFloat(parameterDataSource.parametersCountFor(effect: effectType)))
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return parameterDataSource.parametersCountFor(effect: effectType)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TSEffectParamsTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TSEffectParamsTableViewCell", for: indexPath) as!  TSEffectParamsTableViewCell
        let dw = parameterDataSource.effectParameter(effect: effectType, atIndex: indexPath.row)
        cell.configureWith(param: dw)
        cell.changeBlock =   { (value) in
            
            self.parameterDelegate.didChange(parameter: dw, newValue: value, for: self.effectType)
        }
        cell.backgroundColor = .black
        cell.selectionStyle = .none
        return cell
    }

}
