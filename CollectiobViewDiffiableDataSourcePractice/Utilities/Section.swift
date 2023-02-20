//
//  Section.swift
//  CollectiobViewDiffiableDataSourcePractice
//
//  Created by Vivian Phung on 2/19/23.
//

import UIKit

typealias DataSource = UICollectionViewDiffableDataSource<Section, TwitterProfileModel>
typealias Snapshot = NSDiffableDataSourceSnapshot<Section, TwitterProfileModel>
typealias SupplementaryViewDataSource = UICollectionViewDiffableDataSource<Section, TwitterProfileModel>.SupplementaryViewProvider

enum Section: Int {
    case twitter
}
