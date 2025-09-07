import UIKit

class ViewController1: UIViewController {

  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var nextButton: UIButton!
  
  // 目標ID（新規作成時はnil、編集時は既存ID）
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
    if let goalId = self.goalId {
      // 既存目標の編集
      goalDraft = goalManager.loadDraft(id: goalId) ?? GoalDraft(id: goalId)
      
      // 既存データがあれば読み込み、なければドラフトから
      let mokuhyou = goalManager.getGoalData(forKey: "mokuhyou", goalId: goalId) as? String 
                    ?? goalDraft?.title 
                    ?? ""
      textView.text = mokuhyou
    } else {
      // 新規作成
      let newId = UUID()
      self.goalId = newId
      goalDraft = GoalDraft(id: newId)
      textView.text = ""
    }
  }
  
  private func setupUI() {
    nextButton.layer.cornerRadius = 20
    nextButton.clipsToBounds = true
    
    title = goalDraft?.title?.isEmpty == false ? goalDraft?.title : "目標設定"
  }
  
  private func saveDraftData() {
    guard var draft = goalDraft else { return }
    
    let mokuhyou = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    draft.title = mokuhyou.isEmpty ? nil : mokuhyou
    draft.currentStep = 1
    
    goalManager.saveDraft(draft)
    self.goalDraft = draft
  }
  
  private func updateLastViewedScreen() {
    guard let goalId = self.goalId else { return }
    goalManager.updateLastViewedScreen(goalId: goalId, screenId: "ViewController1", step: 1)
  }

  @IBAction func nextButtonTapped(_ sender: UIButton) {
    let mokuhyou = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    
    guard let goalId = self.goalId else { return }
    
    // 目標固有のキーで保存
    goalManager.setGoalData(mokuhyou, forKey: "mokuhyou", goalId: goalId)
    
    // ドラフト更新
    goalDraft?.title = mokuhyou.isEmpty ? nil : mokuhyou
    goalDraft?.currentStep = 2  // 次はVC2
    
    if let draft = goalDraft {
      goalManager.saveDraft(draft)
    }
    
    print("Goal ID: \(goalId.uuidString), mokuhyou: \(mokuhyou)")
    performSegue(withIdentifier: "toViewController2", sender: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toViewController2",
       let vc2 = segue.destination as? ViewController2 {
      vc2.goalId = self.goalId
    }
  }
}
