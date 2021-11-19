//
//  RealmModel.swift
//  SeSAC_Motto
//
//  Created by kokojong on 2021/11/19.
//

import Foundation
import RealmSwift

class Motto: Object {
    
    @Persisted var mottoDrwNo: Int // 회차
    @Persisted var mottoBuyDate: Date // 구매일자
    @Persisted var mottoDrwtNo1: Int // 1
    @Persisted var mottoDrwtNo2: Int // 2
    @Persisted var mottoDrwtNo3: Int // 3
    @Persisted var mottoDrwtNo4: Int // 4
    @Persisted var mottoDrwtNo5: Int // 5
    @Persisted var mottoDrwtNo6: Int // 6
    @Persisted var prize: Int
    @Persisted var mottoNum: Int // 몇 번 모또인지(로또 종이의 번호? - 소속)

    // PK(필수): Int, String, UUID, objectID 등 -> AutoIncrement
    @Persisted(primaryKey: true) var _id: ObjectId
      
    // 초기화
    convenience init(mottoDrwNo: Int, mottoBuyDate: Date, mottoDrwtNo1: Int, mottoDrwtNo2: Int, mottoDrwtNo3: Int, mottoDrwtNo4: Int, mottoDrwtNo5: Int, mottoDrwtNo6: Int, mottoNum: Int) {
        self.init()
        
        self.mottoDrwNo = mottoDrwNo
        self.mottoBuyDate = mottoBuyDate
        self.mottoDrwtNo1 = mottoDrwtNo1
        self.mottoDrwtNo2 = mottoDrwtNo2
        self.mottoDrwtNo3 = mottoDrwtNo3
        self.mottoDrwtNo4 = mottoDrwtNo4
        self.mottoDrwtNo5 = mottoDrwtNo5
        self.mottoDrwtNo6 = mottoDrwtNo6
        self.mottoNum = mottoNum
        
        self.prize = 0 // 처음에는 0으로 만들고 추후에 당첨이 된다면 업데이트 하는식

    }
    
}

class MottoPaper: Object { // 한번에
    @Persisted var mottoPaperDrwNo: Int // 회차
    @Persisted var mottoPaperBuyDate: Date // 구매일자
    @Persisted var mottoPaperNum: Int // 몇 번 모또인지(컬렉션 뷰에서 나타내려고 함
    
    @Persisted var mottoPaper: List<Motto>
    
    convenience init(mottoPaperDrwNo: Int, mottoPaperBuyDate: Date, mottoPaper: [Motto], mottoPaperNum: Int) {
        self.init()
        
        self.mottoPaperDrwNo = mottoPaperDrwNo
        self.mottoPaperBuyDate = mottoPaperBuyDate
        self.mottoPaperNum = mottoPaperNum
        
        self.mottoPaper.append(objectsIn: mottoPaper)
        
    }
    
}

//{
//    "totSellamnt":81032551000,"firstAccumamnt":19488435376,"firstWinamnt":4872108844, -> 총 판매액, 1등총 상금, 1인당 상금
//    "drwNo":861,"firstPrzwnerCo":4,
//    "returnValue":"success",
//    "drwNoDate":"2019-06-01",
//    "drwtNo6":25,"drwtNo4":21,"drwtNo5":22,"drwtNo2":17,"drwtNo3":19,"drwtNo1":11,"bnusNo":24
//}

class Result: Object {
    @Persisted var drwNo: Int // 회차
    @Persisted var drwNoDate: Date // 발표일자
    @Persisted var drwtNo1: Int // 1
    @Persisted var drwtNo2: Int // 2
    @Persisted var drwtNo3: Int // 3
    @Persisted var drwtNo4: Int // 4
    @Persisted var drwtNo5: Int // 5
    @Persisted var drwtNo6: Int // 6
    
//    @Persisted var totSellamnt: Int // 총 판매액(안써도 될듯)
    @Persisted var firstAccumamnt: Int // 1등 총 당첨액
    @Persisted var firstWinamnt: Int // 1인당 1등 당첨액
    @Persisted var firstPrzwnerCo: Int // 1등 당첨자 수
//    @Persisted var returnValue: String // "success" or "fail" -> 이건 json 받아오면서 체크하는 용으로 쓰기
    
    
    @Persisted(primaryKey: true) var _id: ObjectId
    
    convenience init(drwNo: Int, drwNoDate: Date) {
        self.init()
        
        self.drwNo = drwNo
        self.drwNoDate = drwNoDate
        
    }
    
}
