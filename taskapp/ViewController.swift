//
//  ViewController.swift
//  taskapp
//
//  Created by 小林大悟 on 2020/06/27.
//  Copyright © 2020 daigo.kobayashi. All rights reserved.
//

import UIKit
import RealmSwift //追加
import UserNotifications    // 追加

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate { //UISearchBarDelegate L6
    @IBOutlet weak var tableView: UITableView!
      
    @IBOutlet weak var category: UISearchBar!//L6



    //Realmインスタンスを取得する
    let realm = try! Realm() //追加
    
    //DB内のタスクが格納されるリスト
    //日付の近い順でソート：昇順
    //以降内容をアップデートするとリスト内は自動的に更新される
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)//追加
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        category.delegate = self//L6 delegate登録する



    }
    

    
    
    
    
    //データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection sevtion: Int) -> Int{
        return taskArray.count//修正
    }
    //各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //再利用可能なcellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //Cellに値を設定するーーここからーー
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        //---ここまで追加---
        
        return cell
    }
    //各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        performSegue(withIdentifier: "cellSegue",sender: nil) // ←追加
    }
    //セルが消去可能な事を伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle{
        return .delete
    }
    //Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        //---ここから---
        if editingStyle == .delete{
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]

            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            //データベースから消去する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }//---ここまで---
    }
    //segueで画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue"{
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }else{
            let task = Task()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
    }
    //入力画面から戻ってきた時にTableViewを更新させる
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    //L6
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){//searchBarSearchButtonClicked
        print("@@@@")
        taskArray = try! Realm().objects(Task.self).filter("category == %@",searchBar.text!)
        tableView.reloadData()
    }
    //L6
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){//searchBarCancelButtonClicked
        searchBar.text = ""

        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath:"date",ascending: true)
        tableView.reloadData()
}
    // 検索バー編集開始時にキャンセルボタン有効化
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
        searchBar.setShowsCancelButton(true, animated: true)
    }
}
