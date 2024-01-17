//
//  
//  DetailPageVC.swift
//  WeatherForecastApp
//
//  Created by Ece Poyraz on 13.01.2024.
//
//
import UIKit
import TinyConstraints

class DetailPageVC: UIViewController {
    var viewModel = DetailPageVM()
    lazy var viewAll: UIView = {
        let t = UIView()
        t.layer.maskedCorners = [.layerMinXMinYCorner]
        t.backgroundColor = UIColor(named: "Color")
        t.layer.cornerRadius = 100
        return t
    }()
    lazy var detailsTitle:UILabel = {
        let dn = UILabel()
        dn.text = "HOURLY DETAILS"
        dn.textColor = .blue
        dn.numberOfLines = 1
        dn.lineBreakMode = .byTruncatingTail
        dn.font = UIFont.boldSystemFont(ofSize: 30)
        dn.backgroundColor = UIColor(named: "detailPageColor")
        return dn
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 5
        stackView.backgroundColor = UIColor(named: "Color")
        stackView.layer.cornerRadius = 50
        stackView.layer.masksToBounds = true
        return stackView
    }()
    lazy var humidity:UILabel = {
        let dn = UILabel()
        dn.text = "humidity değeri 10"
        dn.textColor = .blue
        dn.numberOfLines = 1
        dn.lineBreakMode = .byTruncatingTail
        dn.font = UIFont.systemFont(ofSize: 18)
        dn.layer.masksToBounds = true
        dn.backgroundColor = UIColor(named: "Color")
        return dn
    }()
    lazy var speed:UILabel = {
        let dn = UILabel()
        dn.text = "speed 100"
        dn.textColor = .blue
        dn.numberOfLines = 1
        dn.lineBreakMode = .byTruncatingTail
        dn.font = UIFont.systemFont(ofSize: 18)
        dn.backgroundColor = UIColor(named: "Color")
        return dn
    }()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 1, height: 60)
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HourlyTempCell.self, forCellWithReuseIdentifier: "hourlyTemp")
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor(named: "Color")
        return collectionView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "detailPageColor")
        viewModel.reloadClosure = {
            self.collectionView.reloadData()
        }
        self.configureWindHuminityValue()
        setupViews()
    }
    func configureWindHuminityValue(){
        self.humidity.text = " Currently Humidity Value %\(String((self.viewModel.arrFive?.first?.main.humidity)!) ) "
        self.speed.text = "Currently Wind Speed Value \(String((self.viewModel.arrFive?.first?.wind.speed)!)) m/s "
    }
    func setupViews() {
        self.view.addSubviews(detailsTitle, viewAll)
        viewAll.addSubviews(stackView, collectionView)
        stackView.addArrangedSubviews(humidity, speed)
        setupLayout()
    }
    func setupLayout() {
        
        detailsTitle.topToSuperview(offset:30, usingSafeArea: true)
        detailsTitle.centerXToSuperview()
        detailsTitle.height(40)
        
        viewAll.topToSuperview(offset:90)
        viewAll.leadingToSuperview()
        viewAll.trailingToSuperview()
        viewAll.bottomToSuperview()
        
        stackView.topToSuperview(offset:20, usingSafeArea: true)
        stackView.leadingToSuperview(offset:10)
        stackView.centerXToSuperview()
        
        humidity.topToSuperview()
        humidity.leadingToSuperview(offset:30)
        humidity.trailingToSuperview()
        humidity.height(100)
        
        speed.leading(to: humidity)
        speed.trailing(to: humidity)
        humidity.height(100)
        
        collectionView.topToBottom(of: speed, offset:20)
        collectionView.leadingToSuperview()
        collectionView.trailingToSuperview()
        collectionView.bottomToSuperview(offset:-60)
    }
}
extension DetailPageVC:UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.arrFive?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hourlyTemp", for: indexPath) as? HourlyTempCell else {
            fatalError("cell does not exist")
        }
        guard let cellInfo = viewModel.arrFive?[indexPath.row] else {return cell}
        cell.configure(object: cellInfo)
        return cell
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y != 0 {
            scrollView.contentOffset.y = 0
        }
    }
}

//#if DEBUG
//import SwiftUI
//
//@available(iOS 13, *)
//struct DetailPageVC_Preview: PreviewProvider {
//    static var previews: some View{
//
//        DetailPageVC().showPreview()
//    }
//}
//#endif
