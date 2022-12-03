//
//  StockDetailHeaderView.swift
//  StocksAppReplica
//
//  Created by Artemy Ozerski on 02/12/2022.
//

import UIKit
class StockDetailHeaderView: UIView {
    //chartView
private let chartView = StockChartView()

    private var metricViewModels: [MetricCollectionViewCell.ViewModel] = []
    //collectionView
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero,
                                      collectionViewLayout: layout)
        collectionView.register(MetricCollectionViewCell.self, forCellWithReuseIdentifier: MetricCollectionViewCell.identifier)
        collectionView.backgroundColor = .secondarySystemBackground
        return collectionView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubviews(chartView, collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     override func layoutSubviews() {
         super.layoutSubviews()
         chartView.frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: height - 100)
         collectionView.frame = CGRect(
            x: 0,
            y: height - 100,
            width: width,
            height: 100)
    }
    func configure(chartViewModel: StockChartView.ViewModel,
                   metricViewModels: [MetricCollectionViewCell.ViewModel]){
        //update chart
        self.metricViewModels = metricViewModels
        collectionView.reloadData()
    }
}
extension StockDetailHeaderView : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return metricViewModels.count
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel = metricViewModels[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MetricCollectionViewCell.identifier,
            for: indexPath) as? MetricCollectionViewCell else {
            fatalError()

        }
        cell.configure(with: viewModel)
        //cell.backgroundColor = .green
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: width/2, height: 100/3)
    }


}
