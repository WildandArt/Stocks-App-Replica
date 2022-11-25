//
//  SearchResultsVC.swift
//  StocksAppReplica
//
//  Created by Artemy Ozerski on 21/11/2022.
//

import UIKit
protocol SearchResultsVCDelegate: AnyObject{
    func SearchResultsVCdidSelect(searchResult: SearchResult)
}
class SearchResultsVC: UIViewController{

    weak var delegate : SearchResultsVCDelegate?
    var results = [SearchResult]()
  
    private let tableView : UITableView = {
        let table = UITableView()
        table.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        table.isHidden = true
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTable()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    private func setupTable(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    public func update(with results: [SearchResult]){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.results = results
            self.tableView.isHidden = results.isEmpty
            self.tableView.reloadData()
        }

    }
}
extension SearchResultsVC : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath) as? SearchResultTableViewCell else{fatalError("cell creation")}
        let result = results[indexPath.row]
        cell.textLabel?.text = result.displaySymbol
        cell.detailTextLabel?.text = result.description
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = results[indexPath.row]
        delegate?.SearchResultsVCdidSelect(searchResult: result)
    }
}
