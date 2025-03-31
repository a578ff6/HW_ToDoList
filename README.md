# 📝 HW_ToDoList

一個使用 UIKit 實作的待辦事項管理 App。支援新增、編輯、刪除、搜尋待辦事項，並可添加圖片與截止日期。

本專案為學習 iOS 開發時的練習作品，採用 MVC 架構與本地資料儲存，並搭配 Medium 文章詳細記錄開發過程與設計思維。

---

## 🔧 專案技術

- Swift 5
- UIKit + Storyboard
- UITableView + UISearchBar
- UIImagePickerController：支援相機 / 相簿選取
- UIDatePicker：設定截止日期
- FileManager + PropertyListEncoder/Decoder：圖片與資料本地儲存
- MVC 架構實作

---

## 📱 功能介紹

- ✅ 顯示所有待辦事項清單
- ✅ 新增 / 編輯待辦事項
- ✅ 設定截止日期（Date Picker）
- ✅ 拍照或選取圖片，插入到事項中
- ✅ 勾選完成與未完成狀態
- ✅ 搜尋待辦事項標題
- ✅ 分享事項內容與圖片
- ✅ 拖曳排序 / 滑動刪除
- ✅ 使用者操作時自動儲存與載入

---

## 🗂 專案結構

```
HW_ToDoList/
├── Models/
│   └── ToDoItem.swift                  // 資料模型
│ 
├── Managers/
│   ├── ImageStorageManager.swift       // 圖片儲存管理
│   └── ToDoItemManager.swift           // 資料儲存管理
│ 
├── Views/
│   └── ToDoListTableViewCell.swift     // 自定義 Cell 顯示待辦事項
│ 
├── Controllers/
│   ├── ToDoListTableViewController.swift       // 顯示事項清單
│   └── ToDoDetailTableViewController.swift     // 新增 / 編輯頁面
│ 
├── Main.storyboard              // 使用 Storyboard 管理畫面
├── Assets.xcassets              // 圖片資源
└── Info.plist
```

---

## 🖼 預覽畫面


- 📋 待辦清單頁
- 🆕 新增/編輯待辦事項頁（含日期與圖片）
- 🔍 搜尋待辦事項
- 📤 分享待辦事項內容

---