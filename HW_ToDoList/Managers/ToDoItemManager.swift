//
//  ToDoItemManager.swift
//  HW_ToDoList
//
//  Created by 曹家瑋 on 2023/10/16.
//

import Foundation
import UIKit

// 管理待辦事項的存儲和加載。
class ToDoItemManager {
    static let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveURL = documentDirectory.appendingPathComponent("todoItems").appendingPathExtension("plist")
    
    // 保存待辦事項到文件。
    static func saveToDoItems(_ items: [ToDoItem]) {
        let encoder = PropertyListEncoder()
        do {
            let encodedToDoItems = try encoder.encode(items)
            try encodedToDoItems.write(to: archiveURL)
        } catch {
            print("Error encoding items: \(error)")
        }
    }
    
    // 從文件加載待辦事項。
    static func loadToDoItems() -> [ToDoItem]? {
        // 嘗試從文件獲取數據
        guard let retrievedToDoItemsData = try? Data(contentsOf: archiveURL) else { return nil }
        
        let decoder = PropertyListDecoder()
        do {
            let decodedToDoItems = try decoder.decode([ToDoItem].self, from: retrievedToDoItemsData)
            return decodedToDoItems
        } catch {
            print("Error decoding items: \(error)")
            return nil
        }
    }
    
}
