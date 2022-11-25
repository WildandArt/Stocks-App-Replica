//
//  extensions.swift
//  StocksAppReplica
//
//  Created by Artemy Ozerski on 21/11/2022.
//

import UIKit


extension DateFormatter{
    static let newsDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()
}


extension UIView{
    func addSubviews(_ views: UIView...){
        views.forEach {addSubview($0)}
    }

    var width : CGFloat{
        frame.size.width
    }
    var height: CGFloat{
        frame.size.height
    }
    var left: CGFloat{
        frame.origin.x
    }
    var right: CGFloat{
        left + width
    }
    var top: CGFloat{
        frame.origin.y
    }
    var bottom: CGFloat{
        top + height
    }
}
