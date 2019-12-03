//
//  ViewController.swift
//  ZhiHu2.0
//
//  Created by 游奕桁 on 2019/11/27.
//  Copyright © 2019 游奕桁. All rights reserved.
//

import UIKit
import Alamofire

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

class ViewController: UIViewController {
    
    let bannerView = BannerView()
    let tableView = UITableView()
    var topStories = [BannerViewDataSource]() {
        didSet {
            bannerView.models = topStories
        }
    }
    var news = [News]() {
        didSet {
            OperationQueue.main.addOperation {
                self.tableView.insertSections(IndexSet(integer: self.news.count), with: .top)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationItem()
        setUptableView()
        setUpBannerView()
//        loadLatestNews()
    }
//MARK: SetUpFunc
    func setNavigationItem() {
        let today = Date()
        let formatter = DateFormatter()
        let dateString = formatter.string(from: today)
        formatter.dateFormat = "MMM d"
        formatter.locale = Locale.current
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "\(dateString)", style: .done, target: self, action: nil)
        navigationItem.title = "知乎日报"
        navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func setUptableView() {
        tableView.rowHeight = 100
        tableView.estimatedRowHeight = 100
        tableView.contentInset.top = -64
        tableView.clipsToBounds = false
        tableView.backgroundColor = .white
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "Header")
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    
    func setUpBannerView() {
        bannerView.delegate = self
        view.addSubview(bannerView)
    }
    
    func configureBannerView() {
        bannerView.models = topStories.map({ (story) -> BannerViewDataSource in
            return story as BannerViewDataSource
        })
    }

}

extension ViewController: URLSessionTaskDelegate, URLSessionDelegate {
    fileprivate func getNews(from newsURL: URL) {
        request(newsURL, method: .get).responseJSON { (response) in
            switch response.result {
            case .success(let json):
                do {
                    guard let json = json as? JSONDictionary else { return }
                    let news = try News.parse(json: json)
                    self.news.append(news)
                    if self.news.count == 0 {
                        self.updateTopStories()
                    }
                } catch {
                    fatalError("JSON Data Error")
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    fileprivate func updateTopStories() {
        topStories = news[0].topStories!.map({ (story) -> BannerViewDataSource in
            return story as BannerViewDataSource
        })
    }

    fileprivate func loadLatestNews() {
        getNews(from: News.latestNewsURL)
    }

    fileprivate func loadPreviousNews() {
        getNews(from: news.last!.previousNewsURL)
    }
}

            
     

//MARK: TableViewDelegate
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        header?.textLabel?.text = news[section].dateString
        header?.textLabel?.textColor = .lightGray
        header?.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        header?.layer.backgroundColor = .none
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 40
        }
    }
    
    
}
//MARK: TableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == news.count - 1 && indexPath.row == 0 {
//            loadPreviousNews()
            
        }
    }
   func numberOfSections(in tableView: UITableView) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return news[section].stories.count
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Story") as? StoryCell
        cell?.thumbNail.image = nil
        cell?.configure(for: news[indexPath.section].stories[indexPath.row])
        return cell!
    }
    
    
}

extension ViewController: BannerViewDelegate {
    func tapBanner(model: BannerViewDataSource) {
        guard let story = model as? Story else {
            fatalError()
        }
        let didSelectStory: (Story) -> () = { _ in }
        didSelectStory(story)
    }
}

