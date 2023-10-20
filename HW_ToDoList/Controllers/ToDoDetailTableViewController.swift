//
//  ToDoDetailTableViewController.swift
//  HW_ToDoList
//
//  Created by 曹家瑋 on 2023/10/16.
//

import UIKit

class ToDoDetailTableViewController: UITableViewController {

    // 待辦事項的內容
    @IBOutlet weak var checkmarkButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var dueDateDatePicker: UIDatePicker!
    @IBOutlet weak var contentTextView: UITextView!
    // 存取按鈕、分享按鈕
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    /// saveUnwind id
    struct PropertyKeys {
        static let saveUnwind = "saveUnwind"
    }
    
    // MARK: - Properties

    /// 待辦事項 dueDateLabel 的位置
    let dueDateLabelCellIndexPath = IndexPath(row: 0, section: 1)
    /// 待辦事項 DatePicker 的位置
    let dueDateDatePickerCellIndexPath = IndexPath(row: 1, section: 1)
    /// 日期選擇器的顯示狀態
    var isDatePickerShown: Bool = false

    /// 保存待辦事項的詳細資訊
    var toDoItem: ToDoItem?
    
    /// 保存圖像的路徑
    var imagePath: String?

    /// 判斷圖片是否被添加
    var isImageAdded: Bool = false {
        didSet {
            // 當標示更改時更新（禁用/啟用添加圖片的按鈕）
            updateCameraButtonState()
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentTextView.delegate = self
        
        setupView()
        updateActionAndSaveButtonState()
    }
    
    // MARK: - Table View Delegate
    // 當選擇 row 時
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == dueDateLabelCellIndexPath {
            // 如果點擊的是 dueDateLabelCell，則切換日期選擇器的顯示狀態
            isDatePickerShown.toggle()
            tableView.deselectRow(at: indexPath, animated: true)
            // 更新其行的高度
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        // 收起鍵盤
        view.endEditing(true)
    }
    
    // 根據 datePicker 的顯示狀態來更改 datePicker cell 的高度。
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == dueDateDatePickerCellIndexPath {
            return isDatePickerShown ? 216 : 0  // 如果 datePicker 是顯示的，則216；否則0。
        }
        // 對於其他行，使用默認高度
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    // MARK: - Actions
    
    // 將拍攝的照片、相簿裡的照片添加至TextView裡
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let alertController = UIAlertController(title: "選擇圖片來源", message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(UIAlertAction(title: "相機", style: .default, handler: { [weak self] _ in
                imagePickerController.sourceType = .camera
                self?.present(imagePickerController, animated: true, completion: nil)
            }))
        }
        alertController.addAction(UIAlertAction(title: "照片庫", style: .default, handler: { [weak self] _ in
            imagePickerController.sourceType = .photoLibrary
            self?.present(imagePickerController, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    // 分享待辦事項
    @IBAction func actionButtonTapped(_ sender: UIBarButtonItem) {
        // 確保有內容可以分享
        guard let titleText = titleTextField.text, !titleText.isEmpty,
              let contentText = contentTextView.text, !contentText.isEmpty else {
            print("標題或內容為nil，無法分享")
            return
        }
        
        let dueDateString = dueDateLabel.text ?? "未設置日期"
        // 建立分享內容的文字部分
        var itemsToShare: [Any] = [
            "項目:\(titleText)\n內容：\(contentText)\n時間：\(dueDateString)"
        ]
        
        // 待辦內容有圖片，則加入分享
        if let imagePath = toDoItem?.imagePath {
            // 使用ImageStorageManager從儲存載入圖片
            if let image = ImageStorageManager.loadImage(from: imagePath) {
                itemsToShare.append(image)  // 添加圖片到分享
            } else {
                print("圖片載入失敗")
            }
        }
        
        // 建立 activityViewController
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    // 切換待辦事項的完成狀態
    @IBAction func checkmarkButtonTapped(_ sender: UIButton) {
        if toDoItem == nil {
            // 對於新的待辦事項，可以直接切換按鈕的圖標，因為還沒有 'toDoItem' 來更新。
            if checkmarkButton.imageView?.image == UIImage(systemName: "checkmark.circle.fill") {
                checkmarkButton.setImage(UIImage(systemName: "circle"), for: .normal)
            } else {
                checkmarkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            }
        } else {
            // 對於已存在的待辦事項，依賴 'toDoItem' 的 'isCompleted' 狀態。
            // 如果沒有待辦事項或待辦事項沒有完成的狀態
            if toDoItem?.isCompleted ?? false {
                toDoItem?.isCompleted = false
                checkmarkButton.setImage(UIImage(systemName: "circle"), for: .normal)
            } else {
                toDoItem?.isCompleted = true
                checkmarkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            }
        }
 
    }
    
    // 當Title文字發生變化時，更新按鈕狀態
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateActionAndSaveButtonState()
    }
    
    // 更新時間
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        updateDueDateLabel(with: sender.date)
    }
    
    // 取消按鈕
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        // 如果有圖片已添加但操作被取消，則可以從存儲中刪除該圖片
        if let imagePath = self.imagePath, self.isImageAdded {
            ImageStorageManager.deleteImage(at: imagePath)
            self.imagePath = nil  // 重置圖片路徑
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Methods
    
    /// 更新按鈕狀態
    private func updateActionAndSaveButtonState() {
        let text = titleTextField.text ?? ""
        let shouldEnableButtons = !text.isEmpty // 如果沒有標題，則禁用保存按鈕
        saveButton.isEnabled = shouldEnableButtons
        actionButton.isEnabled = shouldEnableButtons
    }
    
    /// 將日期格式化為字串，並設置dueDateLabel的文字
    func updateDueDateLabel(with date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm" // 自定義的日期時間格式
        dueDateLabel.text = dateFormatter.string(from: date)
    }
    
    /// 根據是否已有待辦事項來進行不同的設置
    private func setupView() {
        if let toDoItem = toDoItem {
            navigationItem.title = "待辦事項"
            setupForExistingItem(toDoItem)
        } else {
            navigationItem.title = "新增事項"
            setupForNewItem()
        }
    }

    /// 處理以存在的待辦事項
    private func setupForExistingItem(_ item: ToDoItem) {
        // 正在編輯一個現有的待辦事項
        titleTextField.text = item.title
        contentTextView.text = item.content
        
        // 更新dueDateLabel和DatePicker
        if let dueDate = item.dueDate {
            dueDateDatePicker.date = dueDate
            updateDueDateLabel(with: dueDate)
        }
        
        // 處理圖片加載
        if let imagePath = item.imagePath, let image = ImageStorageManager.loadImage(from: imagePath) {
            addImageToTextView(image)
            isImageAdded = true // 如果待辦事項已有圖片
        } else {
            isImageAdded = false // 如果沒有圖片
        }
        
        updateCameraButtonState()
        
        // 設置checkmark圖標
        let checkmarkImage = item.isCompleted ? UIImage(systemName: "checkmark.circle.fill") :  UIImage(systemName: "circle")
        checkmarkButton.setImage(checkmarkImage, for: .normal)
        
        // 啟用保存按鈕
        saveButton.isEnabled = true
    }
    
    /// 新增待辦事項
    private func setupForNewItem() {
        let currentDate = Date()
        dueDateDatePicker.date = currentDate
        updateDueDateLabel(with: currentDate)
        
        // 初始化其他 UI 元件的狀態
        titleTextField.text = ""
        contentTextView.text = ""
        checkmarkButton.setImage(UIImage(systemName: "circle"), for: .normal)
        
        // 因為是新待辦事項，用戶應當輸入標題，所以初始時禁用保存按鈕
        saveButton.isEnabled = false
    }

    /// 在 textView 中新增圖片附件
    /// - Parameter image: 要添加到 textView 中的圖片
    private func addImageToTextView(_ image: UIImage) {
        
        // adjustImageAttachmentSize 來獲取適當大小的圖片
        if let resizedImage = adjustImageAttachmentSize(image: image, for: contentTextView) {
            // 新的文本附件物件
            let attachment = NSTextAttachment()
            // 將調整大小後的圖片設置為附件的內容
            attachment.image = resizedImage
            // 設置附件在文本中的大小為新的圖片大小
            attachment.bounds = CGRect(origin: .zero, size: resizedImage.size)

            // 獲取當前 textView 的屬性文本內容，以便追加 圖片附件
            let oldAttributedText = NSMutableAttributedString(attributedString: contentTextView.attributedText)
            oldAttributedText.append(NSAttributedString(attachment: attachment))
            contentTextView.attributedText = oldAttributedText
        }
        print("addImageToTextView")  // 測試觀察
    }
    
    /// 調整圖片大小以適應TextView的寬度
    /// - Parameters:
    ///   - image: 要調整大小的圖片
    ///   - textView: 會根據這個textView的寬度來調整圖片
    /// - Returns: 調整後的圖片
    func adjustImageAttachmentSize(image: UIImage, for textView: UITextView) -> UIImage? {
        // 計算新的大小。這裡的寬度是TextView的寬度，高度則按照圖片的寬高比進行縮放計算。
        let newSize = CGSize(width: textView.frame.width, height: image.size.height * ((textView.frame.width) / image.size.width))
        
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(origin: .zero, size: newSize))                // 在新的尺寸中繪製原圖片
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }
    
    /// 更新 CameraButton狀態
    private func updateCameraButtonState() {
        cameraButton.isEnabled = !isImageAdded
    }

    
    // MARK: - Navigation
    
    // 將資料傳回 ToDoListTableViewController
    // 按下“Save”來保存更改
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // 保存待辦事項的Unwind
        guard segue.identifier == PropertyKeys.saveUnwind else { return }
        // 將待辦事項封裝到 toDoItem 物件中。
        let title = titleTextField.text ?? ""
        let content = contentTextView.text ?? ""
        let dueDate = dueDateDatePicker.date
        
        // 是否完成待辦事項的標示
        let isCompleted = checkmarkButton.imageView?.image == UIImage(systemName: "checkmark.circle.fill")

        // 如果已經有一個待辦事項，就更新它的屬性；否則，創建一個新的。
        if toDoItem != nil {
            toDoItem?.title = title
            toDoItem?.content = content
            toDoItem?.dueDate = dueDate
            toDoItem?.isCompleted = isCompleted
        } else {
            // 創建一個新的待辦事項
            toDoItem = ToDoItem(title: title, content: content, imagePath: imagePath, dueDate: dueDate, isCompleted: isCompleted, identifier: UUID())
        }
    }
 
}

// MARK: - Extension
// 擴展照片選取以及處理存取
extension ToDoDetailTableViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[.originalImage] as? UIImage {
            // 在待辦內容中添加圖片
            addImageToTextView(selectedImage)

            // 再將圖片附加到 TextView後，保存圖片。
            if let imagePath = ImageStorageManager.saveImage(selectedImage) {
                self.imagePath = imagePath          // 保存新的圖片路徑
                toDoItem?.imagePath = imagePath     // 更新待辦事項的imagePath
                
                self.isImageAdded = true    // 確保只有在圖像成功保存後才設置
                print("didFinishPickingMediaWithInfo")   // 測試觀察
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}


// 處理從contentTextView中刪除圖片的情況，需要檢測到圖片已被刪除，並從存儲中相應地移除它。
extension ToDoDetailTableViewController: UITextViewDelegate {
    
    // 當TextView的內容發生改變時會調用
    func textViewDidChange(_ textView: UITextView) {
        // 檢查是否存在attributedText。因為圖片是以NSTextAttachment的形式存儲在其中。
        guard let currentAttributedText = textView.attributedText else {
            print(" -- textViewDidChange -- 在contentTextView中刪除圖片失敗")
            return
        }
        
        // 尋找圖片附件。
        let range = NSRange(location: 0, length: currentAttributedText.length)
        var imageFound = false      // 用於標記是否在 TextView 中找到圖片
        
        // 搜索 NSTextAttachment 對象（圖片）。
        currentAttributedText.enumerateAttribute(.attachment, in: range, options: []) { (value, _, _) in
            // 如果找到的屬性是NSTextAttachment，並且它含有圖片，則將imageFound設置為true。
            if let attachment = value as? NSTextAttachment, attachment.image != nil {
                imageFound = true
            }
        }
        
        // 根據是否發現圖片來更新 isImageAdded 屬性
        self.isImageAdded = imageFound  // 在確定是否找到圖像之後立即更新狀態

        // 如果attributedText中沒有圖片，表示處理圖片的刪除。
        if !imageFound {
            // 如果待辦事項已有圖片路徑，則需要從本地存儲中刪除該圖片檔案。
            if let imagePath = toDoItem?.imagePath {
                ImageStorageManager.deleteImage(at: imagePath)
                toDoItem?.imagePath = nil
            }
            
            // 從控制器的imagePath屬性中刪除本地路徑。
            if let imagePath = self.imagePath {
                ImageStorageManager.deleteImage(at: imagePath)
                self.imagePath = nil
            }
        }
        
    }
    
}
    
