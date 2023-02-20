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
        $0.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "twitter")
        $0.register(TwitterSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "twitterheader")
        $0.backgroundView = UIView().configured { backgroundView in
            backgroundView.backgroundColor = .systemBackground
        }

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.width - 20, height: 100)
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

        twitterCollectionView.dataSource = dataSource
        twitterCollectionView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getTwitterProfile(type: "twitter")
    }

    private func initDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: twitterCollectionView) { [weak self] (collectionView, indexPath, twitterModelHandleId) -> UICollectionViewCell? in
            let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "twitter", for: indexPath) as! UICollectionViewCell
            let twitterModel = self?.twitterProfiles.first(where: { $0.id == twitterModelHandleId })

            var content = UIListContentConfiguration.cell()
            content.text = twitterModel?.name
            content.secondaryText = twitterModel?.username
            // default profile photo size "normal" is 48x48. circle corner radius 48/2
            content.imageProperties.maximumSize = CGSize(width: 48, height: 48)
            content.imageProperties.cornerRadius = 24

            if let twitterModelImage = twitterModel?.image {
                content.image = twitterModelImage
            } else {
                self?.getProfileImage(for: twitterModel!)
            }

            cell.contentConfiguration = content
            cell.accessibilityTraits = .button
            cell.accessibilityLabel = "handle \(twitterModel?.username) with account name \(twitterModel?.name)"
            cell.accessibilityHint = "tap to tag user"
            return cell
        }

        let headerRegistration = configureHeader()
        dataSource.supplementaryViewProvider = { (_ collectionView: UICollectionView, _ elementKind: String, _ indexPath: IndexPath) in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }

        return dataSource
    }

    // MARK: - NSDiffableDataSourceSnapshot
    func applySnapshot(animated: Bool) {
        let twitterModelIDs = getID(for: twitterProfiles)
        guard !twitterModelIDs.isEmpty else {
            return
        }

        var snapshot = Snapshot()
        snapshot.appendSections([.twitter])
        snapshot.appendItems(twitterModelIDs, toSection: .twitter)
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

    func getProfileImage(for twitterModel: TwitterProfileModel, isFullImage: Bool = false) {
        let baseURL: String = isFullImage ? twitterModel.profileImageURL.replacingOccurrences(of: "_normal", with: "") : twitterModel.profileImageURL
        let urlRequest: URLRequest = apiManager.networkRequest(baseURL: baseURL, endpoint: TwitterAPIEndpoint.getProfilePhoto, parameters: nil, headers: nil)

        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, _, error in
            guard let responseData = data, let image = UIImage(data: responseData), error == nil else {
                print("error ===> \(error!.localizedDescription)")
                return
            }

            var currentSnapshot = self?.dataSource.snapshot()
            if let datasourceIndex = currentSnapshot?.indexOfItem(twitterModel.id) {
                let item = self?.twitterProfiles[datasourceIndex]
                item?.image = image
                currentSnapshot?.reconfigureItems([item!.id])
                self?.dataSource.apply(currentSnapshot!, animatingDifferences: true)
            }
        }
        task.resume()
    }

    func configureHeader() -> UICollectionView.SupplementaryRegistration<TwitterSupplementaryView> {
        return UICollectionView.SupplementaryRegistration<TwitterSupplementaryView>(elementKind: UICollectionView.elementKindSectionHeader, handler: { (_, _, _) in
        })
    }

    func getID(for model: [TwitterProfileModel]) -> [TwitterProfileModel.ID] {
        return model.map { item in
            return item.id
        }
    }
}

extension ViewController: UICollectionViewDelegate {

}
