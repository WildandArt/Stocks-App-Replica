//
//  SearchResultTableViewCell.swift
//  StocksAppReplica
//
//  Created by Artemy Ozerski on 21/11/2022.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    static let identifier = String(describing: SearchResultTableViewCell.self)

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  

}
