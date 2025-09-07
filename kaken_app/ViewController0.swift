import UIKit

class ViewController0: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var goals: [Goal] = []
    private let goalManager = GoalManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadGoals()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 他の画面から戻ってきた時に目標リストを更新
        loadGoals()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // +ボタンの再設定を試行
        if navigationItem.rightBarButtonItem == nil {
            print("Add button is nil, recreating...")
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
            navigationItem.rightBarButtonItem = addButton
        }
    }
    
    private func setupUI() {
        title = "目標一覧"
        print("setupUI called")
        
        // コードで+ボタンを作成
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
        print("Add button created and set")
        
        // Navigation Controllerの確認
        if navigationController != nil {
            print("Navigation Controller exists")
        } else {
            print("ERROR: Navigation Controller is nil")
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // 空のセルの線を消す
        
        // セルの登録（デフォルトスタイル使用）
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GoalCell")
    }
    
    private func loadGoals() {
        goals = goalManager.loadGoals()
        tableView.reloadData()
        
        // 空状態の処理（仕様では何も表示しないとのことなので、backgroundViewはnil）
        tableView.backgroundView = nil
    }
    
    @objc private func addButtonTapped() {
        navigateToWizard(goalId: nil, startFromStep: 1)
    }
    
    private func navigateToWizard(goalId: UUID?, startFromStep step: Int) {
        switch step {
        case 1:
            navigateToViewController1(goalId: goalId)
        case 2:
            navigateToViewController2(goalId: goalId)
        case 5:
            navigateToViewController5(goalId: goalId)
        default:
            // 不整合時はVC1にフォールバック
            navigateToViewController1(goalId: goalId)
        }
    }
    
    private func navigateToViewController1(goalId: UUID?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc1 = storyboard.instantiateViewController(withIdentifier: "ViewController1") as? ViewController1 {
            if let goalId = goalId {
                vc1.goalId = goalId
            }
            navigationController?.pushViewController(vc1, animated: true)
        } else {
            showAlert(title: "エラー", message: "ViewController1が見つかりません")
        }
    }
    
    private func navigateToViewController2(goalId: UUID?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc2 = storyboard.instantiateViewController(withIdentifier: "ViewController2") as? ViewController2 {
            if let goalId = goalId {
                vc2.goalId = goalId
            }
            navigationController?.pushViewController(vc2, animated: true)
        } else {
            // VC2が見つからない場合はVC1にフォールバック
            navigateToViewController1(goalId: goalId)
        }
    }
    
    private func navigateToViewController5(goalId: UUID?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc5 = storyboard.instantiateViewController(withIdentifier: "ViewController5") as? ViewController5 {
            if let goalId = goalId {
                vc5.goalId = goalId
            }
            navigationController?.pushViewController(vc5, animated: true)
        } else {
            // VC5が見つからない場合はVC1にフォールバック
            navigateToViewController1(goalId: goalId)
        }
    }
    
    private func deleteGoal(at indexPath: IndexPath) {
        let goal = goals[indexPath.row]
        
        let alert = UIAlertController(
            title: "目標削除",
            message: "「\(goal.title)」を削除しますか？\\n削除したデータは復元できません。",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        alert.addAction(UIAlertAction(title: "削除", style: .destructive) { [weak self] _ in
            self?.goalManager.deleteGoal(id: goal.id)
            self?.goals.remove(at: indexPath.row)
            self?.tableView.deleteRows(at: [indexPath], with: .fade)
        })
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func formatDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        let startString = formatter.string(from: start)
        let endString = formatter.string(from: end)
        return "\(startString) 〜 \(endString)"
    }
}

// MARK: - UITableView DataSource & Delegate

extension ViewController0: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoalCell", for: indexPath)
        let goal = goals[indexPath.row]
        
        // セル表示：mokuhyou（タイトル）+ kikan（開始〜終了）
        cell.textLabel?.text = goal.title.isEmpty ? "無題の目標" : goal.title
        cell.detailTextLabel?.text = formatDateRange(start: goal.startDate, end: goal.endDate)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let goal = goals[indexPath.row]
        
        // 前回画面への自動再開
        navigateToWizard(goalId: goal.id, startFromStep: goal.currentStep)
    }
    
    // スワイプ削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteGoal(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }
}