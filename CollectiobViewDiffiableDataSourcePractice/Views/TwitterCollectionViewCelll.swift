//
//  TwitterCollectionViewCelll.swift
//  CollectiobViewDiffiableDataSourcePractice
//
//  Created by Vivian Phung on 2/19/23.
//
//

import UIKit

class TwitterCollectionViewCell: UICollectionViewCell {

    let label = UILabel()

    override init(frame: CGRect) {
      super.init(frame: frame)

      contentView.addSubview(label)
      label.translatesAutoresizingMaskIntoConstraints = false
      label.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
      label.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
      label.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
      label.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
