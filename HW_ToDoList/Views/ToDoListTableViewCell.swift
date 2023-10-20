//
//  ToDoListTableViewCell.swift
//  HW_ToDoList
//
//  Created by 曹家瑋 on 2023/10/16.
//

import UIKit

// 定義protocol，作為 cell 和 tableView 之間溝通的橋樑。
protocol ToDoListTableViewCellDelegate: AnyObject {
    func didTapCheckmarkButton(in cell: ToDoListTableViewCell)
}

// 客製化cell
class ToDoListTableViewCell: UITableViewCell {

    @IBOutlet weak var checkmarkButton: UIButton!       // 待辦事項確認
    @IBOutlet weak var titleNameLabel: UILabel!         // 事項名稱
    
    weak var delegate: ToDoListTableViewCellDelegate?   // 代理的引用
    
    // 待辦事項確認與否
    @IBAction func checkmarkButtonTapped(_ sender: UIButton) {
        // 按鈕被點擊時，通知代理（視圖控制器）
        delegate?.didTapCheckmarkButton(in: self)

    }
    
    // 將根據待辦事項是否完成來更新 checkmark 按鈕的圖像。
    func updateCheckmark(for item: ToDoItem) {
        // 如果待辦事項已完成，設置一個“已勾選”圖示；否則，設置為“未勾選”圖示。
        if item.isCompleted {
            checkmarkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        } else {
            checkmarkButton.setImage(UIImage(systemName: "circle"), for: .normal)
        }
    }
    
}
