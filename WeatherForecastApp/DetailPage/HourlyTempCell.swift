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
    var viewModel = DetailPageVM()
    var viewModelWeatherHome = WeatherHomeVM()
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
        dn.numberOfLines = 1
        dn.lineBreakMode = .byTruncatingTail
        dn.font = UIFont.systemFont(ofSize: 15)
        dn.numberOfLines = 0
        return dn
    }()
    lazy var temperatureValuee: UILabel = {
        let t = UILabel()
        t.textColor = .black
        t.font = UIFont.systemFont(ofSize: 15)
        t.numberOfLines = 0
        return t
    }()
    lazy var iconWeather: UIImageView = {
        let t = UIImageView()
        return t
    }()
    lazy var humidityHourly: UILabel = {
        let t = UILabel()
        t.textColor = .black
        t.font = UIFont.systemFont(ofSize: 15)
        t.numberOfLines = 0
        return t
    }()
    lazy var windHourly: UILabel = {
        let t = UILabel()
        t.textColor = .black
        t.font = UIFont.systemFont(ofSize: 15)
        t.numberOfLines = 0
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
    func configure(object: WeatherDailyModel.List) {
        if let dayNameString = viewModelWeatherHome.formatDate(from:  object.dtTxt) {
            let iconName = object.weather.first?.icon
            if let iconName = iconName {
                let imageURLString = "https://openweathermap.org/img/w/\(iconName).png"
                if let imageURL = URL(string: imageURLString) {
                    viewModelWeatherHome.loadImageFromURL(url: imageURL)
                    viewModelWeatherHome.iconImage = { [weak self] data in
                        if let image = UIImage(data: data!) {
                            DispatchQueue.main.async {
                                self?.iconWeather.image = image
                            }
                        }
                    }
                } else {
                    print("Geçersiz URL")
                }
            }
            temperatureValuee.text = " \(String(format: "%.2f", object.main.temp - 273))°C\nTemp"
            humidityHourly.text =  " %\(String(object.main.humidity))\nHumidity"
            windHourly.text =  " \( String(object.wind.speed))km/sa \n Wind Speed"
        }
    }
    func setupViews() {
        cellView.addSubview(hourName)
        cellView.addSubview(temperatureValuee)
        cellView.addSubview(iconWeather)
        cellView.addSubview(humidityHourly)
        cellView.addSubview(windHourly)
        self.contentView.addSubview(cellView)
        setupLayout()
    }
    func setupLayout() {
        cellView.bottomToSuperview(offset:10)
        cellView.leadingToSuperview(offset:5)
        cellView.trailingToSuperview(offset:15)
        cellView.topToSuperview(offset:5)
        
        hourName.leadingToSuperview(offset:10)
        hourName.centerYToSuperview()
        hourName.height(50)
        
        temperatureValuee.leadingToTrailing(of: hourName, offset: 8)
        temperatureValuee.height(50)
        temperatureValuee.centerY(to: hourName)
        
        humidityHourly.leadingToTrailing(of: temperatureValuee, offset: 8)
        humidityHourly.height(to: temperatureValuee)
        humidityHourly.centerY(to: temperatureValuee)
        
        windHourly.leadingToTrailing(of: humidityHourly, offset: 6)
        windHourly.height(to: humidityHourly)
        windHourly.centerY(to: humidityHourly)
        
        iconWeather.height(50)
        iconWeather.width(50)
        iconWeather.trailingToSuperview(offset: 5)
        iconWeather.centerY(to: temperatureValuee)
    }
}
