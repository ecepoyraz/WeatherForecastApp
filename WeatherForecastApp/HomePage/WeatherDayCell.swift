//
//  
//  WeatherDayCell.swift
//  WeatherForecastApp
//
//  Created by Ece Poyraz on 13.01.2024.
//
//
import UIKit
import TinyConstraints

class WeatherDayCell: UITableViewCell {
    
    static let reuseIdentifier: String = "WeatherDayCell"
    
    lazy var viewCell:UIView = {
        let vc = UIView()
        vc.backgroundColor = .white
        vc.layer.borderWidth = 1.0
        vc.backgroundColor = UIColor(named: "cell")
        vc.layer.cornerRadius = 3
        vc.layer.shadowRadius = 30
        vc.layer.shadowOpacity = 0.25
        vc.layer.borderColor = UIColor.white.cgColor
        return vc
    }()
    lazy var dayName:UILabel = {
        let dn = UILabel()
        dn.textColor = .blue
        dn.text = "dayName"
        dn.numberOfLines = 1
        dn.lineBreakMode = .byTruncatingTail
        dn.font = UIFont.systemFont(ofSize: 20)
        return dn
    }()
    
    lazy var temperatureValue: UILabel = {
        let t = UILabel()
        t.textColor = .blue
        t.text = "25°C"
        t.font = UIFont.systemFont(ofSize: 20)
        return t
    }()
    
    lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func configure(object: WeatherDailyModel.List) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = dateFormatter.date(from: object.dtTxt) {
            dateFormatter.dateFormat = "EEEE"
            let dayNameString = dateFormatter.string(from: date)
            let iconName = object.weather.first?.icon
            if let iconName = iconName {
                let imageURLString = "https://openweathermap.org/img/w/\(iconName).png"
                if let imageURL = URL(string: imageURLString) {
                    loadImageFromURL(url: imageURL)
                } else {
                    print("Geçersiz URL")
                }
            }
            dayName.text = dayNameString
            temperatureValue.text = " \(String(format: "%.2f", object.main.temp - 273.15)) °C"
            
        } else {
            print("Geçersiz tarih formatı")
        }
    }
    func loadImageFromURL(url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let error = error {
                print("Resim yüklenirken hata oluştu: \(error)")
            } else if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.iconView.image = image
                }
            }
        }.resume()
    }
    func setupViews() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.contentView.addSubview(viewCell)
        viewCell.addSubviews(dayName, temperatureValue, iconView)
        setupLayout()
    }
    func setupLayout() {
        
        viewCell.topToSuperview(offset:5)
        viewCell.leadingToSuperview(offset:5)
        viewCell.trailingToSuperview(offset:5)
        viewCell.bottomToSuperview(offset:-5)
        
        dayName.centerYToSuperview()
        dayName.leadingToSuperview(offset: 10)
        
        temperatureValue.leadingToTrailing(of: dayName, offset: 30)
        temperatureValue.centerYToSuperview()
        
        iconView.trailingToSuperview(offset:20)
        iconView.centerYToSuperview()
        iconView.height(to: viewCell)
        iconView.width(60)
    }
    
}
