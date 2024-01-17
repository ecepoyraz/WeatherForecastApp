
//
//
//  WeatherHomeVCVC.swift
//  WeatherForecastApp
//
//  Created by Ece Poyraz on 13.01.2024.
//
//
import UIKit
import TinyConstraints
import Alamofire
import CoreLocation

class WeatherHomeVC: UIViewController, CLLocationManagerDelegate {
    
    enum TemperatureSpacing {
        static let winter: CGFloat = 10.0
        static let spring: CGFloat = 15.0
        static let autumn: CGFloat = 20.0
        static let summer: CGFloat = 30.0
    }
    
    var uniqueDayNames = [String]()
    var viewModel = WeatherHomeVM()
    let locationManager = CLLocationManager()
    var checkPermissionLocationStatus: Bool?
    
    private lazy var topView: UIImageView = {
        let top = UIImageView()
        top.backgroundColor = .green
        top.image = UIImage(named: "w")
        top.isUserInteractionEnabled = true
        top.contentMode = .scaleToFill
        return top
    }()
    lazy var CToZ: UIButton = {
        let cz = UIButton()
        cz.isUserInteractionEnabled = true
        cz.setImage(UIImage(named: "C"), for: .normal)
        
        cz.addTarget(self, action: #selector(convertToFahrenheitToCelsius), for: .touchUpInside)
        return cz
    }()
    lazy var windStatus: UIButton = {
        let cz = UIButton()
        cz.isUserInteractionEnabled = true
        cz.backgroundColor = .green
        cz.addTarget(self, action: #selector(windActivePasive), for: .touchUpInside)
        cz.setImage(UIImage(named: "windBtn"), for: .normal)
        cz.layer.masksToBounds = true
        cz.layer.cornerRadius = 15
        return cz
    }()
    lazy var humidtyStatus: UIButton = {
        let cz = UIButton()
        cz.isUserInteractionEnabled = true
        cz.backgroundColor = .green
        cz.addTarget(self, action: #selector(humidtyActivePasive), for: .touchUpInside)
        cz.setImage(UIImage(systemName: "humidity.fill" ), for: .normal)
        cz.layer.cornerRadius = 15
        cz.layer.masksToBounds = true
        return cz
    }()
    private lazy var cityName: UILabel = {
        let cn = UILabel()
        cn.textColor = .black
        cn.font = UIFont.boldSystemFont(ofSize: 50)
        return cn
    }()
    private lazy var temperature: UILabel = {
        let t = UILabel()
        t.textColor = .black
        t.font = UIFont.boldSystemFont(ofSize: 40)
        return t
    }()
    lazy var windIcon: UIImageView  = {
        let hd = UIImageView()
        hd.image = UIImage(systemName: "wind")
        return hd
    }()
    private lazy var windValue: UILabel = {
        let w = UILabel()
        w.font = UIFont.italicSystemFont(ofSize: 16)
        w.textColor = .black
        return w
    }()
    lazy var humidityIcon: UIImageView  = {
        let hd = UIImageView()
        hd.image = UIImage(systemName: "humidity.fill" )
        return hd
    }()
    private lazy var humidityValue: UILabel = {
        let w = UILabel()
        w.font = UIFont.italicSystemFont(ofSize: 16)
        w.textColor = .black
        return w
    }()
    private lazy var searchCity: UITextField = {
        let s = UITextField()
        s.backgroundColor = UIColor(named: "cell")
        s.font = UIFont.systemFont(ofSize: 20)
        s.placeholder = "  Enter City"
        s.textColor = .black
        s.layer.cornerRadius = 10
        s.clipsToBounds = true
        s.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        s.layer.borderColor = UIColor.lightGray.cgColor
        s.layer.borderWidth = 0.1
        s.layer.masksToBounds = true
        s.leftViewMode = .always
        s.layer.shadowRadius = 30
        s.layer.shadowOpacity = 10
        s.layer.borderColor = UIColor.black.cgColor
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    private lazy var searchButton: UIButton = {
        let sb = UIButton()
        sb.setImage(UIImage(named: "searchBtn"), for: .normal)
        sb.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
        sb.layer.cornerRadius = 10
        sb.layer.masksToBounds = true
        return sb
    }()
    private lazy var tableView:UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.register(WeatherDayCell.self, forCellReuseIdentifier: WeatherDayCell.reuseIdentifier)
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()
    @objc func convertToFahrenheitToCelsius() {
        if CToZ.currentImage == UIImage(named: "C") {
            if let cleanedString = temperature.text?.replacingOccurrences(of: "°C", with: "").trimmingCharacters(in: .whitespaces){
                if let tempCelcius = Double(cleanedString){
                    let value = (tempCelcius * 1.8) + 32
                    temperature.text =  " \(String(format: "%.2f", value)) F"
                    CToZ.setImage(UIImage(named: "F"), for: .normal)
                }}}
        else {
            if let cleanedStringF = temperature.text?.replacingOccurrences(of: "F", with: "").trimmingCharacters(in: .whitespaces){
                if let tempF = Double(cleanedStringF){
                    let valueF = (tempF - 32) / 1.8
                    temperature.text =  " \(String(format: "%.2f", valueF)) °C"
                    CToZ.setImage(UIImage(named: "C"), for: .normal)
                }}}
    }
    @objc func windActivePasive(){
        if windStatus.backgroundColor == .green {
            windValue.isHidden = true
            windIcon.isHidden = true
            windStatus.backgroundColor = .red
        }else {
            windStatus.backgroundColor = .green
            windValue.isHidden = false
            windIcon.isHidden = false
        }
    }
    @objc func humidtyActivePasive(){
        if humidtyStatus.backgroundColor == .green {
            humidityValue.isHidden = true
            humidityIcon.isHidden = true
            humidtyStatus.backgroundColor = .red
        }else {
            humidtyStatus.backgroundColor = .green
            humidityValue.isHidden = false
            humidityIcon.isHidden = false
        }
    }
    @objc func searchAction(){
        if let enteredCity = searchCity.text {
            viewModel.getWeatherData(cityName: enteredCity)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        locationManagerSetup()
        viewModel.dailyClosure = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        viewModel.firstSecreenUpdateClosure = {
            DispatchQueue.main.async {
                self.cityName.text = String((self.viewModel.dailyWeather?.city.name)!)
                if let firstList = self.viewModel.dailyWeather?.list.first {
                    let deger = String(format: "%.2f", firstList.main.temp - 273.15)
                    self.temperature.text =  " \(deger) °C"
                    self.humidityValue.text = " % \(String((firstList.main.humidity)))"
                    self.windValue.text = " \( String((firstList.wind.speed))) km/sa "
                    self.imageChange()
                }
            }
        }
        alertCityName()
    }
    func imageChange() {
        if let cleanedStringc = temperature.text?.replacingOccurrences(of: "°C", with: "").trimmingCharacters(in: .whitespaces) {
            if let temp = Double(cleanedStringc) {
                if temp <= TemperatureSpacing.winter {
                    topView.image = UIImage(named: "winter")
                } else if temp > TemperatureSpacing.winter && temp < TemperatureSpacing.autumn {
                    topView.image = UIImage(named: "summer")
                } else if temp > TemperatureSpacing.autumn && temp < TemperatureSpacing.spring {
                    topView.image = UIImage(named: "autumn")
                }else {
                    
                }
            }
        }
    }
    func alertCityName(){
        viewModel.alertClosure = {
            self.showAlert(title: "City name not found.", message: "Please check the letters of the city you entered.")
        }
    }
    func showAlert(title:String,message:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    func locationManagerSetup(){
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        let latitude = location.latitude
        let longitude = location.longitude
        viewModel.fetch(lat: latitude, lon: longitude)
        print("Latitude: \(latitude), Longitude: \(longitude)")
        self.locationManager.stopUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    func setupViews() {
        self.view.addSubviews(topView,tableView)
        topView.addSubviews(CToZ,cityName,temperature,windValue,windStatus,windIcon,humidityIcon,humidityValue,humidtyStatus,searchCity,searchButton)
        setupLayout()
        
        let headerLabel: UILabel = {
            let label = UILabel()
            label.text = " Daily Weather Forecast"
            label.textColor = .black
            label.font = UIFont.boldSystemFont(ofSize: 25)
            return label
        }()
        tableView.tableHeaderView = headerLabel
        headerLabel.sizeToFit()
        tableView.tableHeaderView?.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupLayout() {
        topView.topToSuperview()
        topView.leadingToSuperview()
        topView.trailingToSuperview()
        topView.heightToSuperview(multiplier: 0.5)
        
        cityName.topToSuperview(offset: 20, usingSafeArea: true)
        cityName.centerXToSuperview()
        cityName.height(50)
        
        temperature.topToBottom(of: cityName, offset: 20)
        temperature.centerXToSuperview()
        
        CToZ.height(30)
        CToZ.width(30)
        CToZ.trailingToSuperview(offset: 10)
        CToZ.topToBottom(of: cityName)
        
        
        windIcon.height(20)
        windIcon.width(20)
        windIcon.leadingToSuperview(offset:5)
        windIcon.bottomToTop(of: tableView, offset: -10)
        
        windValue.height(to: windIcon)
        windValue.leadingToTrailing(of: windIcon, offset: 10)
        windValue.centerY(to: windIcon)
        
        humidityIcon.centerY(to: windValue)
        humidityIcon.height(20)
        humidityIcon.leadingToTrailing(of: windValue, offset: 10)
        
        humidityValue.leadingToTrailing(of: humidityIcon, offset: 10)
        humidityValue.height(20)
        humidityValue.centerY(to: humidityIcon)
        
        windStatus.topToBottom(of: CToZ, offset: 5)
        windStatus.height(30)
        windStatus.width(30)
        windStatus.centerX(to: CToZ)
        
        humidtyStatus.topToBottom(of: windStatus, offset: 10)
        humidtyStatus.height(30)
        humidtyStatus.width(30)
        humidtyStatus.centerX(to: CToZ)
        
        searchCity.centerXToSuperview()
        searchCity.height(45)
        searchCity.leadingToSuperview(offset: 40)
        searchCity.bottomToTop(of: humidityIcon, offset: -20)
        
        searchButton.leadingToTrailing(of: searchCity, offset: 5)
        searchButton.height(30)
        searchButton.width(30)
        searchButton.centerY(to: searchCity)
        
        tableView.topToBottom(of: topView)
        tableView.leadingToSuperview()
        tableView.trailingToSuperview()
        tableView.bottomToSuperview()
    }
    func goToHourlyDetailPage(indexPath: IndexPath){
        let vc = DetailPageVC()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = dateFormatter.date(from: viewModel.modifiedList[indexPath.row].dtTxt) {
            dateFormatter.dateFormat = "EEEE"
            let dateString = dateFormatter.string(from: date)
            vc.viewModel.arrFive = viewModel.keepUniqueHour(refferanceDate: dateString)
        }
        present(vc, animated: true, completion: nil)
    }
}

extension WeatherHomeVC:UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.modifiedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeatherDayCell.reuseIdentifier, for: indexPath) as? WeatherDayCell else {
            fatalError("Cell does not exist")
        }
        let cellInfo = viewModel.modifiedList[indexPath.row]
        cell.configure(object: cellInfo)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToHourlyDetailPage(indexPath: indexPath)
    }
}

