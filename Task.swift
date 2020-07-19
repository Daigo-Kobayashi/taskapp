//
//  Task.swift
//  taskapp
//
//  Created by 小林大悟 on 2020/07/01.
//  Copyright © 2020 daigo.kobayashi. All rights reserved.
//
import RealmSwift

class Task: Object{
    //
    @objc dynamic var id = 0
    //
    @objc dynamic var title = ""
    //
    @objc dynamic var contents = ""
    //
    @objc dynamic var date = Date()
    //
    @objc dynamic var category = "" //L6カテゴリ追加
    //
    override static func primaryKey() -> String?{
        return "id"

    }

}
//import Foundation//デフォ（消去しても可）
