//
//  ViewController.swift
//  StocksAppReplica
//
//  Created by Artemy Ozerski on 21/11/2022.
//

import UIKit
import FloatingPanel

class WatchListVC: UIViewController, UISearchControllerDelegate {

    private var watchListMap : [String : [CandleStick]] = [:]
//ViewModels
    private var viewModels: [String] = []
    private var fpc: FloatingPanelController!
    private var searchTimer : Timer?
    private let tableView: UITableView = {
        let table = UITableView()

        return table
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setUpSearchController()
        setupTableView()
        fetchWatchListData()
        setupTitleView()
        setupPanel()
    }

    func fetchWatchListData(){
        let symbols = PersistenceManager.shared.watchList

        let group = DispatchGroup()
        for symbol in symbols{
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
            self?.tableView.reloadData()
        }
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
        return watchListMap.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
}
