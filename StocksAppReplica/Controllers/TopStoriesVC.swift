//
//  TopStoriesVC.swift
//  StocksAppReplica
//
//  Created by Artemy Ozerski on 21/11/2022.
//

import UIKit
import SafariServices
class TopStoriesVC: UIViewController {


    enum `Type`{
        case topStories
        case company(symbol: String)

        var title: String{
            switch self{
            case .topStories:
                return "Top Stories"
            case .company(let symbol):
                return symbol.uppercased()
            }
        }
    }
    private var stories = [NewsStory]()

    private let type: Type

    let tableView : UITableView = {
        let table = UITableView()
        table.backgroundColor = .secondarySystemBackground
        table.register(NewsHeaderView.self,
                       forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        table.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)

        return table
    }()
    init(type: Type){
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        fetchNews()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    private func setUpTable(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    private func fetchNews(){
        APICaller.shared.news(for: type) { [weak self] result in
            switch result{
            case .failure(let error):
                print(error)
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories = stories
                    self?.tableView.reloadData()
                }
            }
        }
    }
    private func open(url:URL){
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }

}
extension TopStoriesVC: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewsStoryTableViewCell.identifier,
            for: indexPath
        ) as? NewsStoryTableViewCell
        else {fatalError("Cell creation error")}
        cell.configure(with: .init(model: stories[indexPath.row]))
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsStoryTableViewCell.preferredHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let story = stories[indexPath.row]
        guard let url = URL(string: story.url) else {
            presentFailedToOpenAlert()
            return
        }
        open(url: url)

    }
    func presentFailedToOpenAlert(){
        let alert = UIAlertController(
            title: "Unable to open",
            message: "We were unable to open",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: "Dismiss",
            style: .cancel,
            handler: nil
            ))
        present(alert, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else {
            print("Header error")
            return nil
        }
        header.configure(with: .init(
            title: self.type.title,
            shouldShowAddButton: true
        ))
        return header
    }

}
