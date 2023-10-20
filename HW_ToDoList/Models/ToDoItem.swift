//
//  ToDoItem.swift
//  HW_ToDoList
//
//  Created by 曹家瑋 on 2023/10/16.
//

import Foundation
import UIKit

struct ToDoItem: Codable, Equatable {
    var title: String            // 待辦事項的標題
    var content: String?         // 待辦事項的內容
    var imagePath: String?       // 圖片的文件路徑（因為我要將其存放在documentDirectory）
    var dueDate: Date?           // 截止日期
    var isCompleted: Bool        // 是否已完成
    var identifier: UUID         // 用於唯一辨識每一個待辦事項
    
    // Equatable，用來比較兩個待辦事項是否相等
    static func ==(lhs: ToDoItem, rhs: ToDoItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

// ToDoItem擴展，生成預設數據
extension ToDoItem {
    static func sampleData() -> [ToDoItem] {
        // 建立不同的待辦事項
        let item1 = ToDoItem(title: "購買牛奶", content: "記得去美聯社購買一瓶牛奶", imagePath: nil, dueDate: Date(), isCompleted: false, identifier: UUID())
        let item2 = ToDoItem(title: "練習寫程式", content: "練習製作表格", imagePath: nil, dueDate: Date(), isCompleted: false, identifier: UUID())
        let item3 = ToDoItem(title: "慢跑", content: "進行一小時的慢跑訓練", imagePath: nil, dueDate: Date(), isCompleted: false, identifier: UUID())
        
        // 返回包含所有預設待辦事項陣列
        return [item1, item2, item3]
    }
}
