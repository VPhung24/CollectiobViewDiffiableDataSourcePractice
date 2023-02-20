//
//  Section.swift
//  CollectiobViewDiffiableDataSourcePractice
//
//  Created by Vivian Phung on 2/19/23.
//

import UIKit

typealias DataSource = UICollectionViewDiffableDataSource<Section, TwitterProfileModel.ID>
typealias Snapshot = NSDiffableDataSourceSnapshot<Section, TwitterProfileModel.ID>
typealias SupplementaryViewDataSource = UICollectionViewDiffableDataSource<Section, TwitterProfileModel.ID>.SupplementaryViewProvider

enum Section: Int {
    case twitter
}
