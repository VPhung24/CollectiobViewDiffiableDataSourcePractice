//
//  ViewController.swift
//  CollectiobViewDiffiableDataSourcePractice
//
//  Created by Vivian Phung on 2/19/23.
//

import UIKit
import VivUIKitExtensions

class ViewController: UIViewController {
    let apiManager: APIManager
    private var twitterProfiles: [TwitterProfileModel] = []
    private lazy var dataSource: DataSource = initDataSource()

    private lazy var twitterCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).configured {
        $0.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: "twitter")
        $0.register(TwitterSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "twitterheader")
        $0.backgroundView = UIView().configured { backgroundView in
            backgroundView.backgroundColor = .systemBackground
        }

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.width, height: 100)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.headerReferenceSize = CGSize(width: 0, height: 40)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        $0.collectionViewLayout = layout
    }

    init(apiManager: APIManager) {
        self.apiManager = apiManager

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red

        view.addSubviewWithInsets(twitterCollectionView)

        self.dataSource = initDataSource()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getTwitterProfile(type: "twitter")
    }

    private func initDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: twitterCollectionView) { (collectionView, indexPath, twitterHandle) -> UICollectionViewCell? in
            let cell: UICollectionViewListCell = collectionView.dequeueReusableCell(withReuseIdentifier: "twitter", for: indexPath) as! UICollectionViewListCell as! UICollectionViewListCell
            var content = cell.defaultContentConfiguration()
            content.text = twitterHandle.name
            content.secondaryText = twitterHandle.username
            //            if twitterHandle.image == nil {
            //                self.getProfileImageForTwitterProfile(twitterHandle: twitterHandle)
            //            } else {
            //                content.image = twitterHandle.image
            //                // default profile photo size "normal" is 48x48. circle corner radius 48/2
            //                content.imageProperties.maximumSize = CGSize(width: 48, height: 48)
            //                content.imageProperties.cornerRadius = 24
            //            }
            cell.contentConfiguration = content
            cell.accessibilityTraits = .button
            cell.accessibilityLabel = "handle \(twitterHandle.username) with account name \(twitterHandle.name)"
            cell.accessibilityHint = "tap to tag user"
            return cell
        }

        let headerRegistration = configureHeader()
        dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }

        return dataSource
    }

    // MARK: - NSDiffableDataSourceSnapshot
    func applySnapshot(animated: Bool) {
        var snapshot = Snapshot()
        snapshot.appendSections([.twitter])
        snapshot.appendItems(twitterProfiles, toSection: .twitter)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    private func getTwitterProfile(type: String) {
        let parameters: [String: Any] = ["q": type, "page": "1", "count": "10"]

        guard let bearerToken: String = Bundle.main.infoDictionary?["BEARER_TOKEN"] as? String else { return }
        let header: [String: String] = ["Authorization": bearerToken]

        let urlRequest: URLRequest = apiManager.networkRequest(baseURL: "https://api.twitter.com/", endpoint: TwitterAPIEndpoint.getHandlesForString, parameters: parameters, headers: header)
        apiManager.networkTask(request: urlRequest) { [weak self] (result: Result<[TwitterProfileModel], Error>) in
            switch result {
            case .failure(let error):
                print("error ===> getTwitterProfile \(error.localizedDescription)")
            case .success(let twitterModels):
                self?.twitterProfiles = twitterModels
                self?.applySnapshot(animated: true)
            }
        }
    }

    func configureHeader() -> UICollectionView.SupplementaryRegistration<TwitterSupplementaryView> {

        return UICollectionView.SupplementaryRegistration<TwitterSupplementaryView>(elementKind: UICollectionView.elementKindSectionHeader, handler: { (_, _, _) in
        })

    }
}
