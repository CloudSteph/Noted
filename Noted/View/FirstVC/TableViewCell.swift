//
//  TableViewCell.swift
//  Noted
//
//  Created by Stephanie Liew on 8/9/22.
//

import Foundation
import UIKit

final class TableViewCell: UITableViewCell {
    
    @IBOutlet private(set) weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var descrLabel: UILabel!
    @IBOutlet private(set) weak var dateLabel: UILabel!
    @IBOutlet private(set) weak var view: UIView!
    
    static let identifer: String = "TableViewCell"
    
    private let colors: [UIColor] = [Colors.blue, Colors.green, Colors.purple, Colors.orange, Colors.teal, Colors.peach]
    
    func configure(with note: ListNote, indexPath: IndexPath) {
        view.backgroundColor = colors[indexPath.row % 6]
//        view.backgroundColor = Colors.peach
        titleLabel.text = note.title
        descrLabel.text = note.descr
//        dateLabel.text = String(describing: note.date)
        dateLabel.text = note.date.formatted()
    }
    
    //Adds spacing 
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
    }
}

//extension TableViewCell {
//    let randomColor = UIColor[]
//}

extension TableViewCell {
    
}
