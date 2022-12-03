//
//  MetricCollectionViewCell.swift
//  StocksAppReplica
//
//  Created by Artemy Ozerski on 02/12/2022.
//

import UIKit

class MetricCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: MetricCollectionViewCell.self)

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        addSubviews(nameLabel, valueLabel)
    }
    struct ViewModel{
        let name: String
        let value: String
    }
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        return label

    }()
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        return label

    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        valueLabel.sizeToFit()
        nameLabel.sizeToFit()
        nameLabel.frame =  CGRect(
            x: 3,
            y: 0,
            width: nameLabel.width,
            height: contentView.height)
        valueLabel.frame =  CGRect(
            x: nameLabel.right + 3,
            y: 0,
            width: valueLabel.width,
            height: contentView.height)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        valueLabel.text = nil
    }
    func configure(with viewModel: ViewModel){
        nameLabel.text = viewModel.name + ":"
        valueLabel.text = viewModel.value
    }

}
