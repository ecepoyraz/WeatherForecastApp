//
//  WeatherHomeVM.swift
//  WeatherForecastApp
//
//  Created by Ece Poyraz on 14.01.2024.
//

import Foundation
import Alamofire

class WeatherHomeVM {
    
    var currentWeather: WeatherModel.Weather? {
        didSet{
            fetch(lat: currentWeather?.coord.lat, lon: currentWeather?.coord.lon)
        }
    }
    var modifiedList = [WeatherDailyModel.List]()
    var firstSecreenUpdateClosure: (()->(Void))?
    var updateClosure: (()->(Void))?
    var dailyClosure: (()->(Void))?
    var alertClosure: (()->(Void))?
    var dailyWeather: WeatherDailyModel.WeatherDaily? {
        didSet{
            DispatchQueue.main.async {
                      self.dailyClosure?()
                  }
            firstSecreenUpdateClosure?()
        }
    }
    //firstscreen için data fonksiyonu
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
    //tableviewe all verilerin çekilmesi
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
                print(self.dailyWeather)
            case .failure(let error):
                print("Hata: \(error)")
            }
        })
    }
    //tableviewe modified DAily verilerin çekilmesi
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
    
    //collectionviewe filtered Hourly verilerin çekilmesi
    
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
