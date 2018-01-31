//
//  SettingsViewController.swift
//  LykkeBlueLife
//
//  Created by Nikola Bardarov on 8/23/17.
//  Copyright © 2017 Nikola Bardarov. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import WalletCore

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var viewModel : SettingsViewModel = {
        return SettingsViewModel()
    }()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "settingsCell")
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<SettingsSection>()
        
        dataSource.configureCell = { ds, tv, ip, item in
            let cell = tv.dequeueReusableCell(withIdentifier: "settingsCell") as! SettingsTableViewCell
            cell.bind(toSetting: item)
            return cell
        }
        
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].header
        }
        
        tableView.rx.itemSelected.asObservable()
            .subscribe(onNext: {[weak tableView] indexPath in
                tableView?.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(SettingItem.self)
            .subscribe(onNext: { $0.handler.onSelect()})
            .disposed(by: disposeBag)
        
        Observable.just(sections)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

struct SettingsSection {
    var header: String
    var items: [Item]
}

extension SettingsSection : AnimatableSectionModelType {
    typealias Item = SettingItem
    
    var identity: String {
        return header
    }
    
    init(original: SettingsSection, items: [Item]) {
        self = original
        self.items = items
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        
        header.textLabel?.alpha = 0.6
        header.textLabel?.font = UIFont(name: "AmericanTypewriter", size: 14)!
    }
}
