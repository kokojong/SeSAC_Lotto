//
//  ResultViewController.swift
//  SeSAC_Motto
//
//  Created by kokojong on 2021/11/20.
//

import UIKit
import RealmSwift

class ResultViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let localRealm = try! Realm()
    
    var mottoes: Results<Motto>!
    
    var drawResults: Results<DrawResult>!
    
    var winMottoes: [Motto] = []
    
    var winDrawResults: [DrawResult] = []
    
    var isMotto: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        let predicate = NSPredicate(format: "mottoPaperDrwNo == %@", NSNumber(integerLiteral: nextDrawNo))
        
        if isMotto {
            let predicate = NSPredicate(format: "isMotto == true")
            mottoes = localRealm.objects(Motto.self).filter(predicate)
        } else {
            let predicate = NSPredicate(format: "isMotto == false")
            mottoes = localRealm.objects(Motto.self).filter(predicate)
        }
        
        
        drawResults = localRealm.objects(DrawResult.self)
        

        let nibName = UINib(nibName: ResultTableViewCell.identifier, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: ResultTableViewCell.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        for motto in mottoes {
            for drawResult in drawResults {
                // 모두 일치한다면
                if motto.mottoDrwtNo1 == drawResult.drwtNo1 && motto.mottoDrwtNo2 == drawResult.drwtNo2 && motto.mottoDrwtNo3 == drawResult.drwtNo3 && motto.mottoDrwtNo4 == drawResult.drwtNo4 && motto.mottoDrwtNo5 == drawResult.drwtNo5 && motto.mottoDrwtNo6 == drawResult.drwtNo6 {
                    
                    if !winMottoes.contains(motto) {
                        winMottoes.append(motto)
                        winDrawResults.append(drawResult)
                    }
                    
                }
            }
            
        }
        print(winMottoes)
        print(winDrawResults)
        
        tableView.estimatedRowHeight = 70
//        tableView.rowHeight = UITableView.automaticDimension
        
        
    }
  
}

extension ResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return winMottoes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ResultTableViewCell.identifier, for: indexPath) as? ResultTableViewCell else { return UITableViewCell() }
        
//        cell.testLabel.text = "\(winMottoes[indexPath.row].mottoDrwNo)회차 구매, \(winDrawResults[indexPath.row].drwNo)회차 1등! 상금: \(winDrawResults[indexPath.row].firstWinamnt)"
        
        let winMotto = winMottoes[indexPath.row]
        let winDrawResult = winDrawResults[indexPath.row]
        // 1000회차 구매 번호  1 2 3 4 5 6
        cell.numberLabel.text = "\(winMotto.mottoDrwNo)회차 구매 번호 \(winMotto.mottoDrwtNo1) \(winMotto.mottoDrwtNo2) \(winMotto.mottoDrwtNo3) \(winMotto.mottoDrwtNo4) \(winMotto.mottoDrwtNo5) \(winMotto.mottoDrwtNo6)"
        
        // 900회차 1등 상금 : 123456789원
        cell.winLabel.text = "\(winDrawResult.drwNo)회차 1등! 상금 : \(winDrawResult.firstWinamnt)원"
        cell.backgroundColor = .yellow
        
        return cell
    }
    
    
}