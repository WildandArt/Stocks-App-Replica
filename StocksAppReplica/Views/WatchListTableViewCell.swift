//
//  WatchListTableViewCell.swift
//  StocksAppReplica
//
//  Created by Artemy Ozerski on 26/11/2022.
//

import UIKit
protocol WatchListViewCellDelegate: AnyObject{
    func didUpdateMaxWidth()
}
class WatchListTableViewCell: UITableViewCell {
    static let identifer = String(describing: WatchListTableViewCell.self)
    static let preferredHeight: CGFloat = 60
    weak var delegate : WatchListViewCellDelegate?

    struct ViewModel{
        let symbol: String
        let price: String
        let companyName : String
        let changeColor: UIColor
        let changePercentage : String
        let chartViewModel: StockChartView.ViewModel
    }
    private let miniChartView : StockChartView = {
        let chart = StockChartView()
        chart.clipsToBounds = true
        return chart
    }()

    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .right
        return label
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 6
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        addSubviews(symbolLabel, priceLabel, changeLabel, miniChartView, nameLabel )
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        symbolLabel.sizeToFit()
        nameLabel.sizeToFit()
        priceLabel.sizeToFit()
        changeLabel.sizeToFit()

        let yStart: CGFloat = (contentView.height - symbolLabel.height - nameLabel.height)/2
        symbolLabel.frame = CGRect(x: separatorInset.left,
                                   y: yStart,
                                   width: symbolLabel.width,
                                   height: symbolLabel.height)
        nameLabel.frame = CGRect(x: separatorInset.left,
                                 y: symbolLabel.bottom,
                                   width: nameLabel.width,
                                   height: nameLabel.height)
        let currentWidth = max(max(priceLabel.width, changeLabel.width), WatchListVC.maxChangeWidth)
        if currentWidth > WatchListVC.maxChangeWidth{
            WatchListVC.maxChangeWidth = currentWidth
            delegate?.didUpdateMaxWidth()
        }
        priceLabel.frame = CGRect(x: contentView.width - 10 - currentWidth,
                                  y: (contentView.height - priceLabel.height - changeLabel.height)/2,
                                  width: currentWidth,
                                  height: priceLabel.height)
        changeLabel.frame = CGRect(x: contentView.width - 10 - currentWidth,
                                   y: priceLabel.bottom,
                                  width: currentWidth,
                                  height: changeLabel.height)
        miniChartView.frame = CGRect(x: priceLabel.left - (contentView.width/3) - 5,
                                     y: 6,
                                     width: contentView.width/3,
                                     height: contentView.height - 12)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        nameLabel.text = nil
        priceLabel.text = nil
        changeLabel.text = nil
        miniChartView.reset()
    }
    public func configure(with viewModel : ViewModel){
        symbolLabel.text = viewModel.symbol
        nameLabel.text = viewModel.companyName
        priceLabel.text = viewModel.price
        changeLabel.text = viewModel.changePercentage
        changeLabel.backgroundColor = viewModel.changeColor
        // configure chart
    }

}
