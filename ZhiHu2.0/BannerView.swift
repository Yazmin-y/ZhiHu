//
//  BannerView.swift
//  ZhiHu2.0
//
//  Created by 游奕桁 on 2019/11/28.
//  Copyright © 2019 游奕桁. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

protocol  BannerViewDataSource {
    var bannerTitle: String { get }
    var bannerimageURL: URL? { get }
    var bannerImage: UIImage? { get }
}

protocol  BannerViewDelegate {
    func tapBanner(model: BannerViewDataSource)
}
//MARK: BannerView
var bannerHeight: CGFloat = 200

class BannerView: UIView {
    var delegate: BannerViewDelegate?
    var collectionView: UICollectionView!
    var pageControl: UIPageControl!
    
    var currentPage: Int {
        var currentPage: Int
        let realPage = Int(collectionView.contentOffset.x / screenWidth + 0.5)
        
        if realPage == 6 {
            currentPage = 0
        } else if realPage == 0 {
            currentPage = 4
        } else {
            currentPage = realPage - 1
        }
        return currentPage
    }
    
    var models = [BannerViewDataSource]() {
        didSet {
            collectionView?.contentOffset.x = screenWidth
            collectionView?.reloadData()
              
            }
        }
    var offsetY: CGFloat = 0 {
        didSet {
            collectionView.visibleCells.forEach { (cell) in
                guard let contentView = cell.contentView.subviews[0] as? BannerContentView else { fatalError() }
                let imgView = contentView.imageView
                imgView.frame.origin.y = min(offsetY, 0)
                imgView.frame.size.height = max(frame.height - offsetY, frame.height)
                let label = contentView.label
                label.alpha = 1.6 - offsetY / label.frame.height
                }
            }
        }
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpCollectionView()
        setPAgeControl()
    }
    
    func setUpCollectionView() {
        let layout = UICollectionViewLayout()
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.register(UICollectionView.self, forCellWithReuseIdentifier: "Banner")
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = false
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
        
    }
    
    func setPAgeControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0, y: frame.height - 30, width: screenWidth, height: 30))
        pageControl.numberOfPages = 5
        addSubview(pageControl)
    }
    
}
//MARK: BannerContentView
class BannerContentView: UIView {
    var imageView = UIImageView()
    var label = UILabel()
    var labelMargin: CGFloat = 8
    var dataSource: BannerViewDataSource!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpImg()
        setUpLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpImg() {
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        addSubview(imageView)
    }
    
    func setUpLabel() {
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        addSubview(label)
    }
    
    func configureModel(model: BannerViewDataSource) {
        self.dataSource = model
        imageView.af_setImage(withURL: model.bannerimageURL!)
        label.frame = CGRect(origin: CGPoint(x: labelMargin, y: frame.height - 60), size: CGSize(width: screenWidth, height: 30))
        label.text = model.bannerTitle
    }
}

//MARK: Extension
extension BannerView: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Banner", for: indexPath)
        var index: Int
        if indexPath.row == 6 {
            index = 0
        } else if indexPath.row == 0 {
            index = 4
        } else {
            index = indexPath.row - 1
        }
        if !cell.contentView.subviews.isEmpty, let contentView = cell.contentView.subviews[0] as? BannerContentView {
            contentView.configureModel(model: models[index])
        } else {
            let contentView = BannerContentView(frame: CGRect(origin: .zero, size: cell.frame.size))
            contentView.configureModel(model: models[index])
            cell.contentView.addSubview(contentView)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if models.count != 0 {
            return models.count + 2
        } else {
            return 0
        }
    }
}

extension BannerView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.tapBanner(model: models[currentPage])
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch collectionView.contentOffset.x {
        case 0:
            collectionView.contentOffset.x = 5 * screenWidth
        case 6:
            collectionView.contentOffset.x = screenWidth
        default:
            break;
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = currentPage
    }
}
