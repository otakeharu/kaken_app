//
//  ViewController2.swift
//  kaken_app
//
//  Created by Haru Takenaka on 2025/07/22.
//

import UIKit

class ViewController2: UIViewController {

  @IBOutlet weak var datePicker: UIDatePicker!
  @IBOutlet weak var nextButton: UIButton!
  
  // 目標ID（VC1から受け取る）
  var goalId: UUID?
  private var goalDraft: GoalDraft?
  private let goalManager = GoalManager.shared

  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupGoalData()
    setupUI()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    saveDraftData()
    updateLastViewedScreen()
  }
  
  private func setupGoalData() {
    guard let goalId = self.goalId else { return }
    
    // ドラフトまたは既存データを読み込み
    goalDraft = goalManager.loadDraft(id: goalId) ?? GoalDraft(id: goalId)
    
    // 既存の期間データがあれば設定、なければドラフトから、最終的にはデフォルト
    if let existingKikan = goalManager.getGoalData(forKey: "kikan", goalId: goalId) as? Date {
      datePicker.date = existingKikan
    } else if let draftEndDate = goalDraft?.endDate {
      datePicker.date = draftEndDate
    } else {
      // デフォルトは今日から1ヶ月後
      let calendar = Calendar(identifier: .gregorian)
      datePicker.date = calendar.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    }
  }
  
  private func setupUI() {
    datePicker.datePickerMode = .date
    datePicker.locale = Locale(identifier: "ja_JP")
    datePicker.calendar = Calendar(identifier: .gregorian)
    if #available(iOS 13.4, *) {
        datePicker.preferredDatePickerStyle = .wheels
    }
    nextButton.layer.cornerRadius = 20
    nextButton.clipsToBounds = true
    
    title = "期間設定"
  }
  
  private func saveDraftData() {
    guard var draft = goalDraft else { return }
    
    draft.endDate = datePicker.date
    draft.currentStep = 2
    
    goalManager.saveDraft(draft)
    self.goalDraft = draft
  }
  
  private func updateLastViewedScreen() {
    guard let goalId = self.goalId else { return }
    goalManager.updateLastViewedScreen(goalId: goalId, screenId: "ViewController2", step: 2)
  }

  @IBAction func nextButtontapped(_ sender: UIButton) {
    guard let goalId = self.goalId else { return }
    
    let kikan = datePicker.date
    
    // 目標固有のキーで保存
    goalManager.setGoalData(kikan, forKey: "kikan", goalId: goalId)
    
    // ドラフト更新
    goalDraft?.endDate = kikan
    goalDraft?.currentStep = 5  // 次はVC5（最終画面）
    
    if let draft = goalDraft {
      goalManager.saveDraft(draft)
      
      // ドラフトを正式なGoalに変換して保存
      if let goal = draft.toGoal() {
        goalManager.saveGoal(goal)
        // ドラフトは削除（正式な目標になったため）
        goalManager.deleteDraft(id: goalId)
      }
    }
    
    print("Goal ID: \(goalId.uuidString), kikan: \(kikan)")
    performSegue(withIdentifier: "toViewController3", sender: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toViewController3",
       let vc5 = segue.destination as? ViewController5 {
      vc5.goalId = self.goalId
    }
  }
}
