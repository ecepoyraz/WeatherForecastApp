//
//  WeatherHomeVM.swift
//  WeatherForecastApp
//
//  Created by Ece Poyraz on 14.01.2024.
//

import Foundation
import Alamofire

class WeatherHomeVM {
    
    let dateFormatter = DateFormatter()
    var iconImage: ((Data?) -> Void)?
    var error: ((Error) -> Void)?
    var firstSecreenUpdateClosure: (()->(Void))?
    var updateClosure: (()->(Void))?
    var dailyClosure: (()->(Void))?
    var alertClosure: (()->(Void))?
    var currentWeather: WeatherModel.Weather? {
        didSet{
            fetch(lat: currentWeather?.coord.lat, lon: currentWeather?.coord.lon)
        }
    }
    var modifiedList = [WeatherDailyModel.List]()
    var dailyWeather: WeatherDailyModel.WeatherDaily? {
        didSet{
            DispatchQueue.main.async {
                self.dailyClosure?()
            }
            firstSecreenUpdateClosure?()
        }
    }
    //MARK: Icon Image
    func loadImageFromURL(url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let error = error {
                self?.error?(error)
            } else if let data = data {
                DispatchQueue.main.async {
                    self?.iconImage?(data)
                }
            }
        }.resume()
    }
    //MARK: Date Formater
    func formatDate(from dateString: String) -> String? {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = dateFormatter.date(from: dateString) else {
            print("Geçersiz tarih formatı")
            return nil
        }
        
        dateFormatter.dateFormat = "EEEE"
        let dayNameString = dateFormatter.string(from: date)
        return dayNameString
    }
    // MARK: Home Currently Weather Datas with cityName
    func getWeatherData(cityName: String){
        let apiKey = "48478ebb7533077eb32e1d7022d26429"
        let url =  "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=\(apiKey)"
        let parameters: Parameters = [:]
        NetworkingHelper.shared.getDataFromRemote(url: url, method: .get, params: parameters, callback: { (result:Result<WeatherModel.Weather,Error>) in
            switch result {
            case .success(let data):
                self.currentWeather = data
            case .failure(let error):
                print("Hata: \(error)")
                self.alertClosure!()
            }
        })
    }
    //MARK: Home Currently Weather All Daily Hourly Datas with lon and lat
    func fetch(lat: Double?, lon: Double?){
        guard let lat = lat, let lon = lon else {return}
        let apiKey = "48478ebb7533077eb32e1d7022d26429"
        let url =  "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiKey)"
        let parameters: Parameters = [:]
        NetworkingHelper.shared.getDataFromRemote(url: url, method: .get, params: parameters, callback: { (result:Result<WeatherDailyModel.WeatherDaily,Error>) in
            switch result {
            case .success(let data):
                self.dailyWeather = data
                self.keepUniqueDates()
            case .failure(let error):
                print("Hata: \(error)")
            }
        })
    }
    //MARK: Home Daily Filtered Datas
    func keepUniqueDates() {
        guard let dailyWeather = dailyWeather else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var uniqueDates: [String] = []
        modifiedList.removeAll()
        for item in dailyWeather.list {
            if let date = dateFormatter.date(from: item.dtTxt) {
                dateFormatter.dateFormat = "EEEE"
                let dateString = dateFormatter.string(from: date)
                if !uniqueDates.contains(dateString) {
                    uniqueDates.append(dateString)
                    modifiedList.append(item)
                }
            } else {
                print("Geçersiz tarih formatı")
            }
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }
        dailyClosure?()
        
    }
    //MARK: Present Detail Page Hourly Filtered Datas
    func keepUniqueHour(refferanceDate: String) -> [ WeatherDailyModel.List] {
        guard let dailyWeather = dailyWeather else { return [] }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let filteredList = dailyWeather.list.filter { item in
            if let date = dateFormatter.date(from: item.dtTxt) {
                dateFormatter.dateFormat = "EEEE"
                let dateString = dateFormatter.string(from: date)
                
                if dateString == refferanceDate {
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    return true
                }
            } else {
                print("Geçersiz tarih formatı")
            }
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return false
        }
        return filteredList
    }
}
