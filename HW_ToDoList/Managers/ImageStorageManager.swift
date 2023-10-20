//
//  ImageStorageManager.swift
//  HW_ToDoList
//
//  Created by 曹家瑋 on 2023/10/16.
//

import Foundation
import UIKit

// 負責圖片的存儲和加載。
class ImageStorageManager {
    
    // 將圖片保存到文件系統。
    static func saveImage(_ image: UIImage) -> String? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let identifier = UUID().uuidString
        let filename = "\(identifier).jpg"  // 這裡只是文件名，不包括路徑。
        let imagePath = documentsDirectory.appendingPathComponent(filename)
        
        // 將圖片轉換為JPEG格式的數據。
        guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
        do {
            try data.write(to: imagePath)
            print("Image saved at: \(imagePath)") // 完整路徑
            return filename                       // 返回文件名而不是整個路徑。
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    // 從指定路徑加載圖片。
    static func loadImage(from filename: String) -> UIImage? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let fileURL = documentsDirectory.appendingPathComponent(filename)  // 根據文件名建立完整路徑。
        do {
            let imageData = try Data(contentsOf: fileURL)
            print("Image loaded from: \(fileURL)") // 完整路徑
            return UIImage(data: imageData)
        } catch {
            print("Error load image: \(error)")
            return nil
        }
    }
    
    // 刪除圖片
    static func deleteImage(at path: String) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(path)
        
        do {
            try fileManager.removeItem(at: fileURL)
            print("Image deleted at: \(fileURL)") // 完整路徑
        } catch {
            print("Error deleting image: \(error)")
        }
    }
}

