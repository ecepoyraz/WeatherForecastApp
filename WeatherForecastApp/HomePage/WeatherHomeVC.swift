
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
    
    enum LayoutOffsets {
        static let offsetmin: CGFloat = 5
        static let offset10: CGFloat = 10
        static let offset20: CGFloat = 20
        static let offset30: CGFloat = 30
        static let offset40: CGFloat = 40
        static let offset45: CGFloat = 45
        static let offset50: CGFloat = 50
    }
    var uniqueDayNames = [String]()
    var deneme = DetailPageVM()
    var test = DetailPageVC()
    var viewModel = WeatherHomeVM()
    let locationManager = CLLocationManager()
    var checkPermissionLocationStatus: Bool?
    
    private lazy var topView: UIImageView = {
        let top = UIImageView()
        top.backgroundColor = .green
        top.image = UIImage(named: "w")
        top.isUserInteractionEnabled = true
        return top
    }()
    lazy var CToZ: UIButton = {
        let cz = UIButton()
        cz.isUserInteractionEnabled = true
        cz.setImage(UIImage(named: "C"), for: .normal)
        
        cz.addTarget(self, action: #selector(convertToFahrenheitToCelsius), for: .touchUpInside)
        return cz
    }()
    lazy var windHumidtyView: UIView = {
       let wh = UIView()
        return wh
    }()
    lazy var windStatus: UIButton = {
        let cz = UIButton()
        cz.isUserInteractionEnabled = true
        cz.backgroundColor = .green
        cz.addTarget(self, action: #selector(windActivePasive), for: .touchUpInside)
        return cz
    }()
    lazy var humidtyStatus: UIButton = {
        let cz = UIButton()
        cz.isUserInteractionEnabled = true
        cz.backgroundColor = .green
        cz.addTarget(self, action: #selector(humidtyActivePasive), for: .touchUpInside)
        return cz
    }()
    @objc func windActivePasive(){
        if windStatus.backgroundColor == .green {
            windValue.isHidden = true
            windStatus.backgroundColor = .red
        }else {
            windStatus.backgroundColor = .green
            windValue.isHidden = false
        }
    }
    @objc func humidtyActivePasive(){
        if humidtyStatus.backgroundColor == .green {
            humidityValue.isHidden = true
            humidtyStatus.backgroundColor = .red
        }else {
            humidtyStatus.backgroundColor = .green
            humidityValue.isHidden = false
        }
    }
    private lazy var cityName: UILabel = {
        let cn = UILabel()
        cn.textColor = .blue
        //        cn.text = "ISTANBUL"
        cn.font = UIFont.boldSystemFont(ofSize: 50)
        return cn
    }()
    private lazy var temperature: UILabel = {
        let t = UILabel()
        t.textColor = .blue
        //        t.text = "25°C"
        t.font = UIFont.boldSystemFont(ofSize: 40)
        return t
    }()
    private lazy var windValue: UILabel = {
        let w = UILabel()
        w.font = UIFont.boldSystemFont(ofSize: 30)
        w.textColor = .blue
        //        w.text = "1000"
        return w
    }()
    private lazy var humidityValue: UILabel = {
        let w = UILabel()
        w.font = UIFont.boldSystemFont(ofSize: 30)
        w.textColor = .blue
        //        w.text = "63767"
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
        sb.setImage(UIImage(named: "s"), for: .normal)
        sb.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
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
                if let tem = Double(cleanedString){
                    let deger = (tem * 1.8) + 32
                    temperature.text =  " \(String(format: "%.2f", deger)) F"
                    CToZ.setImage(UIImage(named: "F"), for: .normal)
                }}}
        else {
            if let cleanedStringF = temperature.text?.replacingOccurrences(of: "F", with: "").trimmingCharacters(in: .whitespaces){
                if let tem1 = Double(cleanedStringF){
                    let deg = (tem1 - 32) / 1.8
                    temperature.text =  " \(String(format: "%.2f", deg)) °C"
                    CToZ.setImage(UIImage(named: "C"), for: .normal)
                }}}
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
                    self.windValue.text = " \( String((firstList.wind.speed))) m/s "
                    self.imageChange()
                }
            }
        }
        alertCityName()
    }
    func imageChange() {
        if let cleanedStringc = temperature.text?.replacingOccurrences(of: "°C", with: "").trimmingCharacters(in: .whitespaces) {
            if let temp = Double(cleanedStringc) {
                if temp <= 14.0 {
                    topView.image = UIImage(named: "snow")
                } else if temp > 14.0 && temp < 50.0 {
                    topView.image = UIImage(named: "w")
                } else {
                    topView.image = UIImage(named: "b")
                }
            }
        }
    }
    func alertCityName(){
        viewModel.alertClosure = {
            self.showAlert(title: "City name not found.", message: "Please check the letters of the city you entered.")
        }
    }
    //alert
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
        self.view.addSubviews()
        self.view.addSubview(topView)
        topView.addSubview(CToZ)
        topView.addSubview(windHumidtyView)
        windHumidtyView.addSubview(windValue)
        windHumidtyView.addSubview(humidityValue)
        topView.addSubview(cityName)
        topView.addSubview(temperature)
//        topView.addSubview(windValue)
        topView.addSubview(windStatus)
//        topView.addSubview(humidityValue)
        topView.addSubview(humidtyStatus)
        topView.addSubview(searchCity)
        topView.addSubview(searchButton)
        self.view.addSubview(tableView)
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
        topView.heightToSuperview(multiplier: 0.44)

        cityName.topToSuperview(offset: LayoutOffsets.offset20, usingSafeArea: true)
        cityName.centerXToSuperview()
        cityName.height(50)
        
        CToZ.height(50)
        CToZ.width(50)
        CToZ.trailingToSuperview(offset: LayoutOffsets.offset20)
        CToZ.centerY(to: cityName)
        
        temperature.topToBottom(of: cityName, offset: LayoutOffsets.offset20)
        temperature.centerXToSuperview()
        
        windHumidtyView.topToBottom(of: temperature, offset: 20)
        windHumidtyView.centerXToSuperview()
        
//        windValue.topToBottom(of: temperature, offset: LayoutOffsets.offset10)
        windValue.height(50)
//        windValue.leading(to: temperature)
        
        humidityValue.centerY(to: windValue)
        humidityValue.leadingToTrailing(of: windValue, offset: 30)
        humidityValue.height(50)
        
        windStatus.topToBottom(of: CToZ, offset: 5)
        windStatus.height(20)
        windStatus.width(20)
        windStatus.centerX(to: CToZ)
        
        humidtyStatus.topToBottom(of: windStatus, offset: LayoutOffsets.offset10)
        humidtyStatus.height(20)
        humidtyStatus.width(20)
        humidtyStatus.centerX(to: CToZ)
  
        searchCity.topToBottom(of: windValue, offset: LayoutOffsets.offset10)
        searchCity.centerXToSuperview()
        searchCity.height(45)
        searchCity.leadingToSuperview(offset: LayoutOffsets.offset40)
        
        searchButton.leadingToTrailing(of: searchCity, offset: 0)
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

