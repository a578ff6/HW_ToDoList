//
//  ToDoListTableViewController.swift
//  HW_ToDoList
//
//  Created by 曹家瑋 on 2023/10/16.
//

import UIKit

class ToDoListTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Properties
    // id
    struct PropertyKeys {
        static let toDoListTableViewCell = "ToDoListTableViewCell"
        static let saveUnwind = "saveUnwind"
    }
    
    // 待辦事項
    var toDoItems: [ToDoItem] = []
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化數據：從本地加載或使用預設數據
        toDoItems = ToDoItemManager.loadToDoItems() ?? ToDoItem.sampleData()
        
        // 編輯按鈕
        navigationItem.leftBarButtonItem = editButtonItem
        
        // 設置search代理
        searchBar.delegate = self
        
        // 在編輯模式下允許用戶可以選擇特定的行來進行編輯
        // tableView.allowsSelectionDuringEditing = true
    }

    // MARK: - Table view data source

    // Section
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // 每個section中的行數是待辦事項的數量
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems.count
    }
    
    // 使用自定義cell，並配置其內容
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.toDoListTableViewCell, for: indexPath) as? ToDoListTableViewCell else {
            fatalError("Unable to dequeue ToDoListTableViewCell")
        }
        
        let toDoItem = toDoItems[indexPath.row]
        cell.titleNameLabel.text = toDoItem.title
        // 呼叫 cell 中的方法來根據待辦事項的狀態更新 checkmark 按鈕的圖像
        cell.updateCheckmark(for: toDoItem)
        // 設置代理
        cell.delegate = self
        
        return cell
    }
    
    // 允許row為可以編輯
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // 刪除待辦事項（以及內存的圖片）
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 如果有與待辦事項相關聯的圖片，則從文件系統中刪除它。
            if let imagePath = toDoItems[indexPath.row].imagePath {
                ImageStorageManager.deleteImage(at: imagePath)
            }
            
            // 刪除陣列中相對應的待辦事項、TableView相應的row
            toDoItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // 保存更改
            ToDoItemManager.saveToDoItems(toDoItems)
        }
    }
    
    // 允許行被移動
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // 當用戶通過拖動改變行的順序
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // 更新數據源: 先移除再插入
        let movedToDoItem = toDoItems.remove(at: sourceIndexPath.row)
        toDoItems.insert(movedToDoItem, at: destinationIndexPath.row)
        
        // 進行數據的持久化儲存，保存變更
        ToDoItemManager.saveToDoItems(toDoItems)
    }
    
    // MARK: - Navigation

    // 處理unwind segue，更新待辦事項列表
    @IBAction func unwindToToDoList(segue: UIStoryboardSegue) {
        guard 
            segue.identifier == PropertyKeys.saveUnwind,
            let sourceViewController = segue.source as? ToDoDetailTableViewController,
            let todoItem = sourceViewController.toDoItem
        else {
            return
        }

        // 檢查待辦事項是否已經在列表中。
        if let indexOfExistingToDo = toDoItems.firstIndex(of: todoItem) {
            // 更新現有的待辦事項。
            toDoItems[indexOfExistingToDo] = todoItem
            tableView.reloadRows(at: [IndexPath(row: indexOfExistingToDo, section: 0)], with: .automatic)
        } else {
            // 添加新的待辦事項。
            let newIndexPath = IndexPath(row: toDoItems.count, section: 0)
            toDoItems.append(todoItem)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }

        // 保存待辦事項列表的更改。
        ToDoItemManager.saveToDoItems(toDoItems)
    }
    
    // 傳遞所選擇待辦事項的詳細資訊到ToDoDetailTableViewController
    @IBSegueAction func editToDoItem(_ coder: NSCoder, sender: Any?) -> ToDoDetailTableViewController? {
        // 確認是UITableViewCell。並取得cell的索引路徑
        guard let cell = sender as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else {
            return nil
        }
        
        let detailViewController = ToDoDetailTableViewController(coder: coder)
        detailViewController?.toDoItem = toDoItems[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)

        return detailViewController
    }

}


// MARK: - Eextension

// 實現協議中的方法。當 cell 中的按鈕被點擊時，這個方法會被調用。
extension ToDoListTableViewController: ToDoListTableViewCellDelegate {
    
    func didTapCheckmarkButton(in cell: ToDoListTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        /// 獲取對應的待辦事項
        var toDoItem = toDoItems[indexPath.row]
        
        /// 更改事項的完成狀態
        toDoItem.isCompleted.toggle()
        
        // 將更新後的事項存回陣列
        toDoItems[indexPath.row] = toDoItem
        print("勾選更新：\(toDoItem.title) - isCompleted = \(toDoItem.isCompleted)")
        
        // 即時儲存勾選狀態
        ToDoItemManager.saveToDoItems(toDoItems)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

// Search的擴展
extension ToDoListTableViewController: UISearchBarDelegate {
    
    // 當 searchBar 的文字發生變化時，根據使用者輸入來過濾待辦事項清單
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("輸入文字：\(searchText)")
        
        // 每次輸入時都重新從本地儲存載入完整資料（避免過濾過的資料再被過濾）
        let allItems = ToDoItemManager.loadToDoItems() ?? ToDoItem.sampleData()
        
        // 判斷是否為空白搜尋（空字串時表示清除搜尋，顯示全部資料）
        if searchText.isEmpty {
            toDoItems = allItems
        } else {
            
            // 使用 localizedCaseInsensitiveContains：支援中文、英文與不分大小寫搜尋
            // 每次都針對完整資料來源進行比對，不會因為前一次搜尋導致資料遺失
            toDoItems = allItems.filter { item in
                print("比對項目：\(item.title)")
                return item.title.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // 刷新表格以顯示新的選擇
        tableView.reloadData()
    }
    
    // 使用者點擊鍵盤上的“搜索”按鈕時調用
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()    // 關閉鍵盤
    }
}
