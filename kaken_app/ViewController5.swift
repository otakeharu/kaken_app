import UIKit

// MARK: - Constants（Storyboardの数値と一致）
private enum Grid {
  static let titleWidth: CGFloat   = 156
  static let editWidth: CGFloat    = 44
  static let dayWidth: CGFloat     = 44
  static let rowHeight: CGFloat    = 44
  static let headerHeight: CGFloat = 44
  static let lineWidth: CGFloat    = 1.0 / UIScreen.main.scale
  //static let lineWidth: CGFloat    = 0
  static let maxRows               = 24
}

private func pixelAlign(_ x: CGFloat) -> CGFloat {
  let s = UIScreen.main.scale
  return (x * s).rounded() / s
}

// MARK: - Date utils（VC内で完結させる）
private let jpCal    = Calendar(identifier: .gregorian)
private let jpLocale = Locale(identifier: "ja_JP")

private func ymdString(_ date: Date) -> String {
  let df = DateFormatter(); df.calendar = jpCal; df.locale = jpLocale
  df.dateFormat = "yyyy-MM-dd"; return df.string(from: date)
}
private func dString(_ date: Date) -> String {
  let df = DateFormatter(); df.calendar = jpCal; df.locale = jpLocale
  df.dateFormat = "d"; return df.string(from: date)
}
private func monthString(_ date: Date) -> String {
  let df = DateFormatter(); df.calendar = jpCal; df.locale = jpLocale
  df.dateFormat = "yyyy年M月"; return df.string(from: date)
}
private func weekdaySymbolJP(for date: Date) -> String {
  ["日","月","火","水","木","金","土"][Calendar.current.component(.weekday, from: date) - 1]
}
private func monthStart(of date: Date) -> Date {
  let comps = jpCal.dateComponents([.year,.month], from: date)
  return jpCal.date(from: comps)!
}
private func monthEnd(of date: Date) -> Date {
  let start = monthStart(of: date)
  let next  = jpCal.date(byAdding: .month, value: 1, to: start)!
  return jpCal.date(byAdding: .day, value: -1, to: next)!
}
private func daysArray(from start: Date, to end: Date) -> [Date] {
  var arr: [Date] = []
  var cur = jpCal.startOfDay(for: start)
  let endDay = jpCal.startOfDay(for: end)
  while cur <= endDay {
    arr.append(cur)
    cur = jpCal.date(byAdding: .day, value: 1, to: cur)!
  }
  return arr
}

// MARK: - UserDefaults keys
private enum UDKey {
  static let createdAt   = "gantt.createdAt"
  static let goalEnd     = "gantt.goalEnd"
  
  // 例: (row=1, col=3) -> "koudou13"
  static func koudou(row: Int, col: Int) -> String { "koudou\(row)\(col)" }
  
  static func onoff(row: Int, date: String) -> String { "onoff_\(row)_\(date)" }
  
}

// MARK: - 軽量カスタムレイアウト（横縦両方向スクロール対応）
class GridLayout: UICollectionViewLayout {
  private var contentWidth: CGFloat = 0
  private var contentHeight: CGFloat = 0
  private var cachedAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]
  
  override var collectionViewContentSize: CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }
  
  override func prepare() {
    guard let collectionView = collectionView else { return }
    
    // 基本サイズのみ計算（属性は必要時に作成）
    let numberOfSections = collectionView.numberOfSections
    let numberOfItemsInFirstSection = numberOfSections > 0 ? collectionView.numberOfItems(inSection: 0) : 0
    
    contentWidth = CGFloat(numberOfItemsInFirstSection) * Grid.dayWidth
    contentHeight = CGFloat(numberOfSections) * Grid.rowHeight
    
    // キャッシュをクリア（メモリ節約）
    cachedAttributes.removeAll()
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let collectionView = collectionView else { return nil }
    
    var attributes: [UICollectionViewLayoutAttributes] = []
    
    // 見える範囲のセクションとアイテムのみ計算
    let startSection = max(0, Int(rect.minY / Grid.rowHeight))
    let endSection = min(collectionView.numberOfSections - 1, Int(rect.maxY / Grid.rowHeight))
    let startItem = max(0, Int(rect.minX / Grid.dayWidth))
    
    guard startSection <= endSection else { return attributes }
    
    for section in startSection...endSection {
      let numberOfItems = collectionView.numberOfItems(inSection: section)
      guard numberOfItems > 0 else { continue }
      
      let endItem = min(numberOfItems - 1, Int(rect.maxX / Grid.dayWidth) + 1)
      let validStartItem = max(0, min(startItem, numberOfItems - 1))
      let validEndItem = max(0, min(endItem, numberOfItems - 1))
      
      // Rangeが有効か確認
      guard validStartItem <= validEndItem else { continue }
      
      for item in validStartItem...validEndItem {
        let indexPath = IndexPath(item: item, section: section)
        if let attr = layoutAttributesForItem(at: indexPath) {
          attributes.append(attr)
        }
      }
    }
    
    return attributes
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    // キャッシュから取得、なければ作成
    if let cached = cachedAttributes[indexPath] {
      return cached
    }
    
    let x = CGFloat(indexPath.item) * Grid.dayWidth
    let y = CGFloat(indexPath.section) * Grid.rowHeight
    let frame = CGRect(x: x, y: y, width: Grid.dayWidth, height: Grid.rowHeight)
    
    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
    attributes.frame = frame
    
    // 少数のみキャッシュ（メモリ節約）
    if cachedAttributes.count < 100 {
      cachedAttributes[indexPath] = attributes
    }
    
    return attributes
  }
  
  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return false // スクロール時の再計算を防ぐ
  }
}

// MARK: - 右本体セル（Storyboard プロトタイプでもOK）
final class DayStateCell: UICollectionViewCell {
  func configure(on: Bool, isAfterKikan: Bool = false) {
    contentView.layer.borderWidth = 0
    
    if isAfterKikan {
      // 期間以降は灰色のままにするならここを残す
      contentView.backgroundColor = .systemGray5
      alpha = 0.5
      isUserInteractionEnabled = false
    } else {
      // 固定セル色
      if on {
        // ON のとき → #FF8F7C
        contentView.backgroundColor = UIColor(red: 255/255.0, green: 143/255.0, blue: 124/255.0, alpha: 1.0)
      } else {
        // OFF のとき → #FFF7E9
        contentView.backgroundColor = UIColor(red: 255/255.0, green: 247/255.0, blue: 233/255.0, alpha: 1.0)
      }
      alpha = 1.0
      isUserInteractionEnabled = true
    }
    
    // 以下は枠線の処理（そのまま）
    contentView.layer.sublayers?.removeAll { $0.name == "border" }
    
    let rightBorder = CALayer()
    rightBorder.name = "border"
    rightBorder.backgroundColor = UIColor.separator.cgColor
    rightBorder.frame = CGRect(x: bounds.width - Grid.lineWidth, y: 0,
                               width: Grid.lineWidth, height: bounds.height)
    contentView.layer.addSublayer(rightBorder)
    
    let bottomBorder = CALayer()
    bottomBorder.name = "border"
    bottomBorder.backgroundColor = UIColor.separator.cgColor
    bottomBorder.frame = CGRect(x: 0, y: bounds.height - Grid.lineWidth,
                                width: bounds.width, height: Grid.lineWidth)
    contentView.layer.addSublayer(bottomBorder)
  }
  
  
  override func layoutSubviews() {
    super.layoutSubviews()
    // レイアウト変更時に境界線位置を更新
    for sublayer in contentView.layer.sublayers ?? [] {
      guard sublayer.name == "border" else { continue }
      if sublayer.frame.origin.x > 0 { // 右境界線
        sublayer.frame = CGRect(x: bounds.width - Grid.lineWidth, y: 0, width: Grid.lineWidth, height: bounds.height)
      } else { // 下境界線
        sublayer.frame = CGRect(x: 0, y: bounds.height - Grid.lineWidth, width: bounds.width, height: Grid.lineWidth)
      }
    }
  }
}

// MARK: - ViewController
final class ViewController5: UIViewController {
  
  // Storyboard Outlets（忘れず接続）
  @IBOutlet weak var monthLabel: UILabel!
  @IBOutlet weak var headerDaysCV: UICollectionView!
  @IBOutlet weak var fixedLeftCV: UICollectionView!
  @IBOutlet weak var hScrollView: UIScrollView!
  @IBOutlet weak var mainCV: UICollectionView!
  @IBOutlet weak var collectionWidth: NSLayoutConstraint! // MainCV の Width=Constant
  
  // Data
  private var createdAt = Date()
  private var goalEnd   = Date()
  private var kikanEnd  = Date() // VC2で設定されたkikan日付
  private var days: [Date] = []
  private var titles: [String] = Array(repeating: "", count: Grid.maxRows)
  private var firstVisibleDayIndex = 0
  private var isUpdatingScroll = false // 無限ループ防止フラグ
  
  // 斜めスクロール防止用
  private var scrollDirection: ScrollDirection = .none
  private enum ScrollDirection {
    case none, horizontal, vertical
  }
  
  private var leftFixedWidth: CGFloat { Grid.titleWidth + Grid.editWidth }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupDataFromUserDefaults()
    setupViews()
    updateContentWidth()
    updateMonthLabel()
    syncHeaderToHorizontal()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // VC6から戻った時にmainCVを更新（UserDefaultsの変更を反映）
    mainCV.reloadData()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    updateContentWidth()
    // mainCVのcontentSizeを手動で更新（横スクロール有効化のため）
    DispatchQueue.main.async {
      self.mainCV.layoutIfNeeded()
    }
  }
  
  // MARK: - Setup
  private func setupDataFromUserDefaults() {
    let ud = UserDefaults.standard
    
    if let s = ud.string(forKey: UDKey.createdAt),
       let d = DateFormatter.cached("yyyy-MM-dd", cal: jpCal, loc: jpLocale).date(from: s) {
      createdAt = d
    } else {
      createdAt = jpCal.startOfDay(for: Date())
      ud.set(ymdString(createdAt), forKey: UDKey.createdAt)
    }
    
    if let s = ud.string(forKey: UDKey.goalEnd),
       let d = DateFormatter.cached("yyyy-MM-dd", cal: jpCal, loc: jpLocale).date(from: s) {
      goalEnd = d
    } else {
      goalEnd = createdAt
      ud.set(ymdString(goalEnd), forKey: UDKey.goalEnd)
    }
    
    // VC2で設定されたkikan日付を取得
    if let kikanDate = ud.object(forKey: "kikan") as? Date {
      kikanEnd = jpCal.startOfDay(for: kikanDate)
    } else {
      kikanEnd = jpCal.startOfDay(for: Date()) // デフォルト値
    }
    
    // 表示範囲を開始月の月初〜goalEndまでに設定（kikan日付制限は表示のみ）
    let startMonth = monthStart(of: createdAt)
    createdAt = startMonth
    goalEnd = max(goalEnd, monthEnd(of: createdAt)) // 最低月末まで表示
    ud.set(ymdString(createdAt), forKey: UDKey.createdAt)
    ud.set(ymdString(goalEnd),   forKey: UDKey.goalEnd)
    
    // kikan日付以降もスクロール可能にするため、goalEndまでdays配列を作成
    days = daysArray(from: createdAt, to: goalEnd)
    if days.isEmpty {
      days = daysArray(from: createdAt, to: monthEnd(of: createdAt))
    }
    
    for rowIndex in 1...Grid.maxRows { // 1..24
      let (row, col) = elementRowAndCol(forRowIndex: rowIndex)
      let key = UDKey.koudou(row: row, col: col) // "koudou11" .. "koudou84"
      titles[rowIndex - 1] = ud.string(forKey: key) ?? key
      
      
    }
  }
  
  private func setupViews() {
    // Scroll behaviors
    hScrollView.delegate = self
    hScrollView.alwaysBounceHorizontal = true
    hScrollView.alwaysBounceVertical = false
    hScrollView.isDirectionalLockEnabled = true
    hScrollView.decelerationRate = UIScrollView.DecelerationRate.fast // スナップ効果強化
    if #available(iOS 11.0, *) { hScrollView.contentInsetAdjustmentBehavior = .never }
    
    // CollectionViews
    headerDaysCV.dataSource = self; headerDaysCV.delegate = self
    fixedLeftCV.dataSource  = self; fixedLeftCV.delegate  = self
    mainCV.dataSource       = self; mainCV.delegate       = self

    
    // 固定背景色設定
    headerDaysCV.backgroundColor = UIColor(red: 162/255.0, green: 132/255.0, blue: 94/255.0, alpha: 1.0)

    fixedLeftCV.backgroundColor = UIColor(red: 255/255.0, green: 247/255.0, blue: 233/255.0, alpha: 1.0)
    
    mainCV.backgroundColor = .systemBackground
    
    // 横スクロールは hScrollView のみが担当 - 縦スクロールは有効
    mainCV.alwaysBounceHorizontal = false
    mainCV.showsHorizontalScrollIndicator = false
    // mainCV.isScrollEnabled = true // 縦スクロール有効（デフォルト）
    
    headerDaysCV.alwaysBounceHorizontal = true
    headerDaysCV.showsHorizontalScrollIndicator = false
    headerDaysCV.isScrollEnabled = true // スクロール有効
    headerDaysCV.decelerationRate = UIScrollView.DecelerationRate.fast // スナップ効果強化
    
    // XIBセルの登録（Prototype=0 想定）
    headerDaysCV.register(UINib(nibName: "HeaderDayCell", bundle: nil),
                          forCellWithReuseIdentifier: "HeaderDayCell")
    fixedLeftCV.register(UINib(nibName: "RowTitleCell", bundle: nil),
                         forCellWithReuseIdentifier: "RowTitleCell")
    fixedLeftCV.register(UINib(nibName: "RowEditCell", bundle: nil),
                         forCellWithReuseIdentifier: "RowEditCell")
    // MainCV は Storyboard のプロトタイプを使うなら register 不要
    // もしプロトタイプを使わないなら↓を有効化
    // mainCV.register(DayStateCell.self, forCellWithReuseIdentifier: "DayStateCell")
    
    // Flow 設定（ズレ防止）
    if let fl = headerDaysCV.collectionViewLayout as? UICollectionViewFlowLayout {
      fl.scrollDirection = .horizontal
      fl.minimumLineSpacing = 0; fl.minimumInteritemSpacing = 0
      fl.itemSize = CGSize(width: Grid.dayWidth, height: Grid.headerHeight)
      fl.estimatedItemSize = .zero
      fl.sectionInset = .zero
    }
    if let fl = fixedLeftCV.collectionViewLayout as? UICollectionViewFlowLayout {
      fl.scrollDirection = .vertical
      fl.minimumLineSpacing = 0; fl.minimumInteritemSpacing = 0
      fl.estimatedItemSize = .zero
    }
    
    // mainCVにカスタムレイアウトを適用（縦スクロールのみ有効）
    mainCV.collectionViewLayout = GridLayout()
    
    // mainCVは縦スクロールのみ有効、横はhScrollViewが担当
    mainCV.showsHorizontalScrollIndicator = false
    mainCV.showsVerticalScrollIndicator = true
    mainCV.bounces = true
    mainCV.alwaysBounceVertical = true
    // スナップ効果を強化
    mainCV.decelerationRate = UIScrollView.DecelerationRate.fast
    
    // ヘッダー高さぶんだけ中身を下げる（重なり防止）- 空白行を削除
    mainCV.contentInset.top = 0
    mainCV.verticalScrollIndicatorInsets.top = 0
    fixedLeftCV.contentInset.top = 0
    fixedLeftCV.verticalScrollIndicatorInsets.top = 0
  }
  
  // MARK: - Width & Header
  private func updateContentWidth() {
    // 右側の合計幅 = 左固定幅 + 日数 * dayWidth
    let raw = leftFixedWidth + CGFloat(days.count) * Grid.dayWidth
    collectionWidth.constant = pixelAlign(raw)
    view.layoutIfNeeded()
    
    // カスタムレイアウトを使用しているため、レイアウトを再計算
    mainCV.collectionViewLayout.invalidateLayout()
  }
  
  private func updateMonthLabel() {
    guard !days.isEmpty else { monthLabel.text = ""; return }
    let idx = max(0, min(days.count - 1, firstVisibleDayIndex))
    monthLabel.text = monthString(days[idx])
  }
  
  private func syncHeaderToHorizontal() {
    let x = max(0, hScrollView.contentOffset.x - leftFixedWidth)
    let syncedX = pixelAlign(x)
    
    isUpdatingScroll = true
    
    // 差が大きい場合のみ更新
    if abs(headerDaysCV.contentOffset.x - syncedX) > 0.5 {
      headerDaysCV.contentOffset = CGPoint(x: syncedX, y: 0)
    }
    if abs(mainCV.contentOffset.x - syncedX) > 0.5 {
      mainCV.contentOffset = CGPoint(x: syncedX, y: mainCV.contentOffset.y)
    }
    
    let dayIndex = Int(round(syncedX / Grid.dayWidth))
    if dayIndex != firstVisibleDayIndex {
      firstVisibleDayIndex = max(0, min(days.count - 1, dayIndex))
      updateMonthLabel()
    }
    
    isUpdatingScroll = false
  }
  
  private func appendNextMonthIfNeeded() {
    // 右端近くで翌月列を自動追加（任意）
    let rightEdge = hScrollView.contentOffset.x + hScrollView.bounds.width
    let threshold = max(0, hScrollView.contentSize.width - Grid.dayWidth * 7)
    guard rightEdge >= threshold, let last = days.last else { return }
    let nextMonthEnd = monthEnd(of: jpCal.date(byAdding: .month, value: 1, to: last)!)
    if nextMonthEnd <= goalEnd { return } // すでにgoalEnd以内なら追加不要
    
    let start = jpCal.date(byAdding: .day, value: 1, to: last)!
    let more  = daysArray(from: start, to: nextMonthEnd)
    guard !more.isEmpty else { return }
    days.append(contentsOf: more)
    goalEnd = nextMonthEnd
    UserDefaults.standard.set(ymdString(goalEnd), forKey: UDKey.goalEnd)
    
    headerDaysCV.reloadData()
    mainCV.reloadData()
    updateContentWidth()
  }
  
  // MARK: - Toggle helper
  private func isOn(row: Int, date: Date) -> Bool {
    UserDefaults.standard.bool(forKey: UDKey.onoff(row: row, date: ymdString(date)))
  }
  private func toggle(row: Int, date: Date) {
    let ud = UserDefaults.standard
    let k = UDKey.onoff(row: row, date: ymdString(date))
    ud.set(!ud.bool(forKey: k), forKey: k)
  }
  
  // MARK: - Calendar Editor
  private func openCalendarEditor(for rowIndex: Int) {
    // コードでViewController6を作成（Storyboard不要）
    let vc6 = ViewController6()
    
    // VC6に必要なデータを渡す
    vc6.rowIndex = rowIndex
    vc6.startDate = createdAt    // 開始日
    vc6.endDate = kikanEnd       // 終了日（kikan日付まで）
    
    // ナビゲーションタイトルを設定
    vc6.title = "\(titles[rowIndex - 1]) - 編集"
    
    // 画面遷移
    navigationController?.pushViewController(vc6, animated: true)
  }
  
  // 特定行の即時反映
  private func reloadSpecificRow(_ rowIndex: Int) {
    let sectionIndex = rowIndex - 1
    guard sectionIndex >= 0 && sectionIndex < Grid.maxRows else { return }
    
    let indexPaths = (0..<days.count).map { item in
      IndexPath(item: item, section: sectionIndex)
    }
    mainCV.reloadItems(at: indexPaths)
  }
}

// MARK: - DataSource
extension ViewController5: UICollectionViewDataSource {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    if collectionView === headerDaysCV { return 1 }
    return Grid.maxRows
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int {
    if collectionView === headerDaysCV { return days.count }
    if collectionView === fixedLeftCV { return 2 } // [タイトル, 編集]
    return days.count
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    if collectionView === headerDaysCV {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderDayCell", for: indexPath) as! HeaderDayCell
      let date = days[indexPath.item]
      let isKikanDay = jpCal.isDate(date, inSameDayAs: kikanEnd)
      cell.configure(dayText: dString(date), weekdayText: weekdaySymbolJP(for: date), isKikanDay: isKikanDay)
      return cell
    }
    
    if collectionView === fixedLeftCV {
      if indexPath.item == 0 {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RowTitleCell", for: indexPath) as! RowTitleCell
        cell.configure(text: titles[indexPath.section])
        return cell
      } else {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RowEditCell", for: indexPath) as! RowEditCell
        let rowIndex = indexPath.section + 1
        cell.onTap = { [weak self] in
          print("Edit tapped row:", rowIndex)
          self?.openCalendarEditor(for: rowIndex)
        }
        return cell
      }
    }
    
    // 右本体（日付マス）
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayStateCell", for: indexPath) as! DayStateCell
    let rowIndex = indexPath.section + 1
    let date = days[indexPath.item]
    let isAfterKikan = jpCal.compare(date, to: kikanEnd, toGranularity: .day) == .orderedDescending
    cell.configure(on: isOn(row: rowIndex, date: date), isAfterKikan: isAfterKikan)
    return cell
  }
}

// MARK: - Delegate（サイズ・同期・タップ）
extension ViewController5: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView === headerDaysCV {
      return CGSize(width: pixelAlign(Grid.dayWidth), height: pixelAlign(Grid.headerHeight))
    }
    if collectionView === fixedLeftCV {
      let w = (indexPath.item == 0) ? Grid.titleWidth : Grid.editWidth
      return CGSize(width: pixelAlign(w), height: pixelAlign(Grid.rowHeight))
    }
    return CGSize(width: pixelAlign(Grid.dayWidth), height: pixelAlign(Grid.rowHeight))
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if collectionView === headerDaysCV { return }
    if collectionView === fixedLeftCV { return } // 編集はボタンで
    
    let rowIndex = indexPath.section + 1
    let date = days[indexPath.item]
    toggle(row: rowIndex, date: date)
    collectionView.reloadItems(at: [indexPath])
  }
  
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    scrollDirection = .none
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard !isUpdatingScroll else { return } // 無限ループ防止
    
    if scrollView === hScrollView {
      syncHeaderToHorizontal()
      appendNextMonthIfNeeded()
    } else if scrollView === mainCV {
      // 斜めスクロール防止
      limitScrollDirection(for: scrollView)
      
      isUpdatingScroll = true
      // 縦スクロール連動
      fixedLeftCV.contentOffset.y = mainCV.contentOffset.y
      // 横スクロール連動
      headerDaysCV.contentOffset.x = mainCV.contentOffset.x
      isUpdatingScroll = false
    } else if scrollView === fixedLeftCV {
      isUpdatingScroll = true
      // 縦スクロール連動
      mainCV.contentOffset.y = fixedLeftCV.contentOffset.y
      isUpdatingScroll = false
    } else if scrollView === headerDaysCV {
      isUpdatingScroll = true
      // 横スクロール連動
      mainCV.contentOffset.x = headerDaysCV.contentOffset.x
      isUpdatingScroll = false
    }
  }
  
  private func limitScrollDirection(for scrollView: UIScrollView) {
    let panGesture = scrollView.panGestureRecognizer
    let velocity = panGesture.velocity(in: scrollView)
    
    if scrollDirection == .none {
      // 最初の方向を決定
      if abs(velocity.x) > abs(velocity.y) {
        scrollDirection = .horizontal
      } else if abs(velocity.y) > abs(velocity.x) {
        scrollDirection = .vertical
      }
    }
    
    // 方向に応じてスクロールを制限
    if scrollDirection == .horizontal {
      scrollView.contentOffset.y = scrollView.contentOffset.y
    } else if scrollDirection == .vertical {
      scrollView.contentOffset.x = scrollView.contentOffset.x
    }
  }
  
  // スナップ機能付きスクロール終了処理（hScrollViewのみ）
  func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                 withVelocity velocity: CGPoint,
                                 targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    if scrollView === hScrollView {
      // 横スクロール：列単位でスナップ
      let left = leftFixedWidth
      let rawX = max(0, targetContentOffset.pointee.x - left)
      let col = round(rawX / Grid.dayWidth)
      let snapped = left + col * Grid.dayWidth
      targetContentOffset.pointee.x = snapped
    } else if scrollView === mainCV {
      // 縦スクロール：行単位でスナップ
      let rawY = targetContentOffset.pointee.y
      let row = round(rawY / Grid.rowHeight)
      let snappedY = row * Grid.rowHeight
      targetContentOffset.pointee.y = snappedY
    }
    // headerDaysCVのスナップは削除（hScrollViewが一元管理）
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat { 0 }
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 0 }
}

// MARK: - DateFormatter cache
private extension DateFormatter {
  static func cached(_ format: String, cal: Calendar, loc: Locale) -> DateFormatter {
    let df = DateFormatter(); df.calendar = cal; df.locale = loc; df.dateFormat = format; return df
  }
}

// MARK: - Helper
private func elementRowAndCol(forRowIndex rowIndex: Int) -> (row: Int, col: Int) {
  let row = (rowIndex - 1) / 4 + 1   // 1..8   （要素番号）
  let col = (rowIndex - 1) % 4 + 1   // 1..4   （その要素の第何行動）
  return (row, col)
}

