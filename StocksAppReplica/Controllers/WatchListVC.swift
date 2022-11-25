//
//  ViewController.swift
//  StocksAppReplica
//
//  Created by Artemy Ozerski on 21/11/2022.
//

import UIKit
import FloatingPanel

class WatchListVC: UIViewController, UISearchControllerDelegate {
    
    var fpc: FloatingPanelController!
    private var searchTimer : Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setUpSearchController()
        setupTitleView()
        setupPanel()
    }
    func setupPanel(){
        let vc = TopStoriesVC(type: .topStories)
        fpc = FloatingPanelController()
        fpc.surfaceView.backgroundColor = .secondarySystemBackground
        fpc.set(contentViewController: vc)
        fpc.addPanel(toParent: self)
        fpc.delegate = self
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
