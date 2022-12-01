//
//  ViewController.swift
//  StocksAppReplica
//
//  Created by Artemy Ozerski on 21/11/2022.
//

import UIKit
import FloatingPanel

class WatchListVC: UIViewController, UISearchControllerDelegate, WatchListViewCellDelegate {
    func didUpdateMaxWidth() {
        tableView.reloadData()
    }


    private var watchListMap : [String : [CandleStick]] = [:]
    static var maxChangeWidth: CGFloat = 0
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    private var fpc: FloatingPanelController!
    private var searchTimer : Timer?
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(WatchListTableViewCell.self,
                       forCellReuseIdentifier: WatchListTableViewCell.identifer)
        return table
    }()
    private var observer: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setUpSearchController()
        setupTableView()
        fetchWatchListData()
        setupTitleView()
        setupPanel()
        setupObserver()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    private func setupObserver(){
        observer = NotificationCenter.default.addObserver(
            forName: .didAddToWatchList,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
            self?.viewModels.removeAll()
            self?.fetchWatchListData()
        })
    }

    private func fetchWatchListData(){
        let symbols = PersistenceManager.shared.watchList

        let group = DispatchGroup()
        for symbol in symbols where watchListMap[symbol] == nil{
            group.enter()
            APICaller.shared.marketData(for: symbol) { [weak self] result in
                defer{
                    group.leave()
                }
                switch result{
                case .failure(let error):
                    print(error)
                case .success(let data):
                    let cs = data.candlesticks
                    self?.watchListMap[symbol] = cs
                }
            }        }
        group.notify(queue: .main) {
            [weak self] in
            self?.createViewModels()
            self?.tableView.reloadData()
        }
    }
    private func createViewModels(){
        var viewModels = [WatchListTableViewCell.ViewModel]()
        for (symbol, candleSticks) in watchListMap{
            let changePercentage = getChangePercentage(symbol: symbol,
                                                       for: candleSticks)
            viewModels.append(.init(symbol: symbol,
                                    price: getLatestClosingPrice(from: candleSticks),
                                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
                                    changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
                                    changePercentage: String.percentage(from: changePercentage),
                                    chartViewModel: .init(data: candleSticks.reversed().map{$0.close}, showLegend: false,
                                        showAxis: false)))
        }
//        print("\n\(viewModels)\n")
        self.viewModels = viewModels
    }
    private func getChangePercentage(symbol : String, for data: [CandleStick])->Double{
        let today = Date()
        let priorDate = today.addingTimeInterval(-(3600*24)*2)
        guard let latestClose = data.first?.close,
              let priorClose = data.first(where: {
                  Calendar.current.isDate($0.date,
                                     inSameDayAs: priorDate)
        })?.close
        else{
            return 0.0
        }
        let diff = 1 - (priorClose/latestClose)
//        print("\(symbol): \(diff)%")
//        print("p: \(priorClose/latestClose) ,Current: \(latestClose) | prior: \(priorClose)")
        return diff
        //return priorClose/latestClose
    }
    private func getLatestClosingPrice(from data: [CandleStick])->String{
        guard let closingPrice = data.first?.close else{
            return ""
        }
        return String.formattedNumber(number: closingPrice)
    }
    func setupTableView(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    func setupPanel(){
        let vc = TopStoriesVC(type: .company(symbol: "SNAP"))
        fpc = FloatingPanelController()
        fpc.set(contentViewController: vc)
        fpc.addPanel(toParent: self)
        fpc.delegate = self
        fpc.surfaceView.backgroundColor = .secondarySystemBackground
        fpc.backdropView.backgroundColor = .secondarySystemBackground
    }
    private func setupTitleView(){
        let titleView = UIView(frame: CGRect(
                                   x: 0,
                                   y: 0,
                               width:view.width,
                              height: navigationController?.navigationBar.height ?? 100))
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: titleView.width, height: titleView.height))
        label.text = "Stocks"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        titleView.addSubview(label)
        navigationItem.titleView = titleView
    }
    private func setUpSearchController(){
        let resultVC = SearchResultsVC()
        resultVC.delegate = self
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
    deinit{
        print("watchlist deinit")
    }
}
extension WatchListVC: UISearchResultsUpdating{

    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !(query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty),
        let resultsVC = searchController.searchResultsController as? SearchResultsVC else {
            return
              }
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(
            withTimeInterval: 0.3,
            repeats: false,
            block: { _ in
                APICaller.shared.search(query: query) { result in
                    switch result{

                        case.failure(let error):
                        resultsVC.update(with: [])
                            print(error.localizedDescription)
                        case .success(let response):
                            resultsVC.update(with: response.result)
                    }
                }
            })
    }
}
extension WatchListVC : SearchResultsVCDelegate{
    func SearchResultsVCdidSelect(searchResult: SearchResult) {
        navigationItem.searchController?.searchBar.resignFirstResponder()
        let vc = StockDetailsVC()
        let navVC = UINavigationController(rootViewController: vc)
        vc.title = searchResult.description

        present(navVC, animated: true)
    }
}
extension WatchListVC : FloatingPanelControllerDelegate{
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.titleView?.isHidden = fpc.state == .full
    }
}
extension WatchListVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WatchListTableViewCell.identifer, for: indexPath) as? WatchListTableViewCell else {fatalError()}
        cell.delegate = self
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WatchListTableViewCell.preferredHeight
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            tableView.beginUpdates()
//update VM & update persistence & delete row
            PersistenceManager.shared.removeFromWatchList(symbol: viewModels[indexPath.row].symbol)
            viewModels.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }

    
}
