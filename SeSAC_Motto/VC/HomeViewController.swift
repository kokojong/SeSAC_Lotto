//
//  HomeViewController.swift
//  SeSAC_Motto
//
//  Created by kokojong on 2021/11/18.
//

import UIKit
import SwiftyJSON
import Alamofire
import RealmSwift
import Network
import JGProgressHUD
import KRProgressHUD


class HomeViewController: UIViewController {
    
    @IBOutlet weak var drawNumLabel: UILabel!
    @IBOutlet weak var firstAccumamntLabel: UILabel!
    @IBOutlet weak var firstWinamntLabel: UILabel!
    @IBOutlet weak var firstPrzwnerCoLabel: UILabel!
    @IBOutlet weak var resultStackView: UIStackView!
    
    @IBOutlet weak var mottoTableView: UITableView!
    @IBOutlet weak var lottoTableView: UITableView!
    let localRealm = try! Realm()
    
    var drawResults : Results<DrawResult>!
    
    var recentMottoLists: Results<Motto>!
    var recentLottoLists: Results<Motto>!
//    var recentDrawResult: Results<DrawResult>!
    
    var recentDrawNo = UserDefaults.standard.integer(forKey: "recentDrawNo") {
        didSet {
            drawNumLabel.text = "\(recentDrawNo)"
            print("recentDrawNo",recentDrawNo)
            
            UserDefaults.standard.set(recentDrawNo, forKey: "recentDrawNo")
            let predicate = NSPredicate(format: "drwNo == %@", NSNumber(integerLiteral: recentDrawNo))
            
            // 이걸 지금 못받아옴(처음 991)
            recentDrawResults = drawResults.filter(predicate)// 가장 최근 회차 정보
            checkIsRecent(recent: recentDrawNo)
            updateTableViewByRecentDrawNo()
            updateUIByRecentDrawNo(recentDrawNo: recentDrawNo)
            
        }
    }
    
    var recentDrawResults: Results<DrawResult>! {
        didSet {
            updateUIByRecentDrawNo(recentDrawNo: recentDrawNo)
        }
    }
    
    var recentDrawResult = DrawResult(drwNo: 0, drwNoDate: "", drwtNo1: 0, drwtNo2: 0, drwtNo3: 0, drwtNo4: 0, drwtNo5: 0, drwtNo6: 0, firstAccumamnt: 0, firstWinamnt: 0, firstPrzwnerCo: 0, bnusNo: 0)
    
    
    var recentResultNumList: [Int] = []
    var recentResultBnsNum: [Int] = []
    var recentMottoNumList: [Int] = []
    var recentLottoNumList: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mottoTableView.delegate = self
        mottoTableView.dataSource = self
        lottoTableView.delegate = self
        lottoTableView.dataSource = self
        
        let nibName = UINib(nibName: HomeTableViewCell.identifier, bundle: nil)
        mottoTableView.register(nibName, forCellReuseIdentifier: HomeTableViewCell.identifier)
        lottoTableView.register(nibName, forCellReuseIdentifier: HomeTableViewCell.identifier)
        
        let result = monitorNetwork()
        
        print("Realm:",localRealm.configuration.fileURL!) // 경로 찾기
        
        drawResults = localRealm.objects(DrawResult.self)
        
        recentDrawNo = 991
        loadAllDrawData(drwNo: recentDrawNo)

        checkIsRecent(recent: recentDrawNo)
        
        updateTableViewByRecentDrawNo()
        
        updateUIByRecentDrawNo(recentDrawNo: recentDrawNo)
        
        // 기본적으로 처음에 realm에 저장
        if drawResults.count < 991 { // 네트워크 오류,  등으로 991개를 못받은 경우 -> 모자란 만큼 받아오자
//            DispatchQueue.global().sync {
               
                let progress = JGProgressHUD()
                progress.textLabel.text = "loading"
                progress.show(in: self.view)
                
                for i in 1...991 {
                    let predicate = NSPredicate(format: "drwNo == %@", NSNumber(integerLiteral: 991 - i))

                    if drawResults.filter(predicate).count == 0 {
                        loadAllDrawData(drwNo: 991 - i)
                    }
                    
                }
                
                UserDefaults.standard.set(991, forKey: "recentDrawNo")
                print(drawResults.count)
                let c = drawResults.count
                self.recentDrawNo = 991
                progress.dismiss(afterDelay: 6.0)
//            }
        }
        
        let predicate = NSPredicate(format: "drwNo == %@", NSNumber(integerLiteral: recentDrawNo))
        recentDrawResults = drawResults.filter(predicate) // 가장 최근 회차 정보
        
        
    }
    
    func loadAllDrawData(drwNo: Int) {
    
        let url = "https://www.dhlottery.co.kr/common.do?method=getLottoNumber&drwNo=\(drwNo)"
            // https://www.dhlottery.co.kr/common.do? method=getLottoNumber&drwNo=903

        
        AF.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                if json["returnValue"] == "fail" {
                    return
                }
                
                let drwNo = json["drwNo"].intValue
                let drwNoDate = json["drwNoDate"].stringValue
                let drwtNo1 = json["drwtNo1"].intValue
                let drwtNo2 = json["drwtNo2"].intValue
                let drwtNo3 = json["drwtNo3"].intValue
                let drwtNo4 = json["drwtNo4"].intValue
                let drwtNo5 = json["drwtNo5"].intValue
                let drwtNo6 = json["drwtNo6"].intValue
                let bnusNo = json["bnusNo"].intValue
                let firstAccumamnt = json["firstAccumamnt"].intValue
                let firstWinamnt = json["firstWinamnt"].intValue
                let firstPrzwnerCo = json["firstPrzwnerCo"].intValue
                
                let result = DrawResult(drwNo: drwNo, drwNoDate: drwNoDate, drwtNo1: drwtNo1, drwtNo2: drwtNo2, drwtNo3: drwtNo3, drwtNo4: drwtNo4, drwtNo5: drwtNo5, drwtNo6: drwtNo6, firstAccumamnt: firstAccumamnt, firstWinamnt: firstWinamnt, firstPrzwnerCo: firstPrzwnerCo, bnusNo: bnusNo)
                self.saveResult(drawResult: result)
                

            case .failure(let error):
                // 네트워크 오류라던가
                print(error)
            }
        }
        
    }
    
    func saveResult(drawResult: DrawResult){
        print("saveResult",drawResult.drwNo)
        try! self.localRealm.write {
            localRealm.add(drawResult)
        }
        if drawResult.drwNo == recentDrawNo {
            updateUIByRecentDrawNo(recentDrawNo: recentDrawNo)
            updateTableViewByRecentDrawNo()
        }
    }
    
    func checkIsRecent(recent: Int) {
        let url = "https://www.dhlottery.co.kr/common.do?method=getLottoNumber&drwNo=\(recent + 1)"
        print("checkIsRecent",recent)
        
//        DispatchQueue.global().sync {
            
            AF.request(url, method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    
                    if json["returnValue"] == "fail" { // 아직 발표 이전
                        print("발표 이전")
                        return
                    } else { // 새로운 회차가 있다면
                  
                        let drwNo = json["drwNo"].intValue
                        let drwNoDate = json["drwNoDate"].stringValue
                        let drwtNo1 = json["drwtNo1"].intValue
                        let drwtNo2 = json["drwtNo2"].intValue
                        let drwtNo3 = json["drwtNo3"].intValue
                        let drwtNo4 = json["drwtNo4"].intValue
                        let drwtNo5 = json["drwtNo5"].intValue
                        let drwtNo6 = json["drwtNo6"].intValue
                        let bnusNo = json["bnusNo"].intValue
                        let firstAccumamnt = json["firstAccumamnt"].intValue
                        let firstWinamnt = json["firstWinamnt"].intValue
                        let firstPrzwnerCo = json["firstPrzwnerCo"].intValue
                        
                        let result = DrawResult(drwNo: drwNo, drwNoDate: drwNoDate, drwtNo1: drwtNo1, drwtNo2: drwtNo2, drwtNo3: drwtNo3, drwtNo4: drwtNo4, drwtNo5: drwtNo5, drwtNo6: drwtNo6, firstAccumamnt: firstAccumamnt, firstWinamnt: firstWinamnt, firstPrzwnerCo: firstPrzwnerCo, bnusNo: bnusNo)
                        self.saveResult(drawResult: result)
                        
//                        UserDefaults.standard.set(recent+1, forKey: "recentDrawNo")
                        print("UD: ", UserDefaults.standard.integer(forKey: "recentDrawNo"))
                        self.recentDrawNo = recent+1
                    }
                    
                case.failure(let error):
                    print(error)
                
                }
            
            }
            
            
            
//        }
        
    }
    

    func monitorNetwork() -> Bool {
            
        var status: Bool = false
        
        let monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = {
            path in
            if path.status == .satisfied {
                status = true
                DispatchQueue.main.async {
                    print("연결되어 있음")
                    status = true
                    
                }
            } else {
                status = false
                DispatchQueue.main.async {
                    print("연결되어 있지 않음")
                    status = false
                    
                    let alert = UIAlertController(title: "네트워크 오류", message: "네트워크에 연결되어 있지 않아요.\n설정화면으로 이동합니다 🥲", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "확인", style: .default)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                   
                }
            }
        }
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
        
//        print("status",status)
        return status
    }

    func updateUIByRecentDrawNo(recentDrawNo: Int) {
        
        drawNumLabel.text = "\(recentDrawNo)"
        let recentResult = recentDrawResults.first ?? DrawResult(drwNo: 0, drwNoDate: "", drwtNo1: 0, drwtNo2: 0, drwtNo3: 0, drwtNo4: 0, drwtNo5: 0, drwtNo6: 0, firstAccumamnt: 0, firstWinamnt: 0, firstPrzwnerCo: 0, bnusNo: 0)
        
        // nil 발생
        print("update",recentDrawResults.first)
        print("recentResult",recentResult)
//        let recentResult = recentDrawResult.first!
        var index = 1
        for v in resultStackView.arrangedSubviews {
            let label = v as! UILabel
            
            switch index {
            case 1: label.text = "\(recentResult.drwtNo1)"
            case 2: label.text = "\(recentResult.drwtNo2)"
            case 3: label.text = "\(recentResult.drwtNo3)"
            case 4: label.text = "\(recentResult.drwtNo4)"
            case 5: label.text = "\(recentResult.drwtNo5)"
            case 6: label.text = "\(recentResult.drwtNo6)"
            case 8: label.text = "\(recentResult.bnusNo)"
            default: // 7번은 +
                label.text = "+"
            }
       
            index += 1
        }
        
        firstWinamntLabel.text = "\(recentResult.firstWinamnt)"
        firstAccumamntLabel.text = "\(recentResult.firstAccumamnt)"
        firstPrzwnerCoLabel.text = "\(recentResult.firstPrzwnerCo)"
        
        
        
    }
    
    func updateTableViewByRecentDrawNo() {
        let recentMottoPredicate = NSPredicate(format: "mottoDrwNo == %@ AND isMotto == true", NSNumber(integerLiteral: recentDrawNo))
        let recentLottoPredicate = NSPredicate(format: "mottoDrwNo == %@ AND isMotto == false", NSNumber(integerLiteral: recentDrawNo))
        recentMottoLists = localRealm.objects(Motto.self).filter(recentMottoPredicate)
        recentLottoLists = localRealm.objects(Motto.self).filter(recentLottoPredicate)
        
        // 여기서 recentDrawResult가 nil
        recentDrawResult = recentDrawResults.first ?? recentDrawResult
        recentResultNumList = [recentDrawResult.drwtNo1, recentDrawResult.drwtNo2, recentDrawResult.drwtNo3, recentDrawResult.drwtNo4, recentDrawResult.drwtNo5, recentDrawResult.drwtNo6]
        recentResultBnsNum = [recentDrawResult.bnusNo]
        
        
        for motto in recentMottoLists {
            recentMottoNumList = [motto.mottoDrwtNo1, motto.mottoDrwtNo2, motto.mottoDrwtNo3, motto.mottoDrwtNo4, motto.mottoDrwtNo5, motto.mottoDrwtNo6]
            
            let common = Set(recentMottoNumList).intersection(Set(recentResultNumList)).count
            
            var prize = 0
            switch common {
            case 6: prize = 1
            case 5:
                if Set(recentMottoNumList).intersection(Set(recentResultNumList + recentResultBnsNum)).count == 6 {
                    prize = 2
                } else {
                    prize = 3
                }
            case 4: prize = 4
            case 3: prize = 5
            default: prize = 0
            }
            try! localRealm.write {
                motto.prize = prize
            }
            
        }
        
        for lotto in recentLottoLists {
            recentLottoNumList = [lotto.mottoDrwtNo1, lotto.mottoDrwtNo2, lotto.mottoDrwtNo3, lotto.mottoDrwtNo4, lotto.mottoDrwtNo5, lotto.mottoDrwtNo6]
            
            let common = Set(recentLottoNumList).intersection(Set(recentResultNumList)).count
            
            var prize = 0
            switch common {
            case 6: prize = 1
            case 5:
                if Set(recentLottoNumList).intersection(Set(recentResultNumList + recentResultBnsNum)).count == 6 {
                    prize = 2
                } else {
                    prize = 3
                }
            case 4: prize = 4
            case 3: prize = 5
            default: prize = 0
            }
            try! localRealm.write {
                lotto.prize = prize
            }
            
        }
        
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier) as? HomeTableViewCell else { return UITableViewCell() }
        
        let row = indexPath.row
        
        var recentTargetList: Results<Motto>!
        if tableView == mottoTableView {
            recentTargetList = recentMottoLists
        } else {
            recentTargetList = recentLottoLists
        }
        
        switch row {
        case 0:
            let count = recentTargetList.filter("prize == 1").count
            cell.prizeLabel.text = "1등"
            cell.countLabel.text = "\(count)개"
        case 1:
            let count = recentTargetList.filter("prize == 2").count
            cell.prizeLabel.text = "2등"
            cell.countLabel.text = "\(count)개"
        case 2:
            let count = recentTargetList.filter("prize == 3").count
            cell.prizeLabel.text = "3등"
            cell.countLabel.text = "\(count)개"
        case 3:
            let count = recentTargetList.filter("prize == 4").count
            cell.prizeLabel.text = "4등"
            cell.countLabel.text = "\(count)개"
        case 4:
            let count = recentTargetList.filter("prize == 5").count
            cell.prizeLabel.text = "5등"
            cell.countLabel.text = "\(count)개"
        default:
            print("error")
        }
        
        
        return cell
    }
    
    
}
