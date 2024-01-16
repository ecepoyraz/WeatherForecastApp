//
//  
//  HourlyTempCellVC.swift
//  WeatherForecastApp
//
//  Created by Ece Poyraz on 13.01.2024.
//
//
import UIKit
import TinyConstraints

class HourlyTempCell: UICollectionViewCell {
    
    lazy var cellView:UIView = {
        let vc = UIView()
        vc.backgroundColor = UIColor(named: "cell")
        vc.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        vc.layer.borderWidth = 1.0
        vc.layer.borderColor = UIColor.white.cgColor
        vc.isUserInteractionEnabled = true
        vc.layer.cornerRadius = 16
        vc.layer.shadowOpacity = 0.15
        return vc
    }()
    lazy var hourName:UILabel = {
        let dn = UILabel()
        dn.textColor = .black
        dn.text = "1:00 AM"
        dn.numberOfLines = 1
        dn.lineBreakMode = .byTruncatingTail
        dn.font = UIFont.systemFont(ofSize: 20)
        return dn
    }()
    
    lazy var temperatureValuee: UILabel = {
       let t = UILabel()
       t.textColor = .black
       t.text = "25°C"
       t.font = UIFont.systemFont(ofSize: 20)
       return t
   }()
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
     public func configure(object: WeatherDailyModel.List) {
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

         if let date = dateFormatter.date(from: object.dtTxt) {
             dateFormatter.dateFormat = "h:mm a"
             let hourString = dateFormatter.string(from: date)
             hourName.text = hourString
         } else {
             print("Geçersiz tarih formatı")
         }

         temperatureValuee.text = " \(String(format: "%.2f", object.main.temp - 273)) °C"
     }
    func setupViews() {
        cellView.addSubview(hourName)
        cellView.addSubview(temperatureValuee)
        self.contentView.addSubview(cellView)
        setupLayout()
    }
    
    func setupLayout() {
        cellView.bottomToSuperview(offset:10)
        cellView.leadingToSuperview(offset:5)
        cellView.trailingToSuperview(offset:15)
        cellView.topToSuperview(offset:5)
        
        hourName.leadingToSuperview(offset:10)
        hourName.topToSuperview()
        hourName.height(50)
        hourName.widthToSuperview(multiplier: 0.5)
        
        temperatureValuee.leadingToTrailing(of: hourName)
        temperatureValuee.height(50)
        temperatureValuee.topToSuperview()
        temperatureValuee.trailingToSuperview()
       
    }
  
}

//#if DEBUG
//import SwiftUI
//
//@available(iOS 13, *)
//struct HourlyTempCell_Preview: PreviewProvider {
//    static var previews: some View{
//
//        HourlyTempCell().showPreview()
//    }
//}
//#endif
