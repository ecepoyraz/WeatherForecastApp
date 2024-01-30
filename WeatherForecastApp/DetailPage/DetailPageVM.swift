//
//  DetailPageVM.swift
//  WeatherForecastApp
//
//  Created by Ece Poyraz on 14.01.2024.
//
import Foundation
import Alamofire

class DetailPageVM {
    var reloadClosure: (()->(Void))?
    var arrFive: [WeatherDailyModel.List]? {
        didSet{
            reloadClosure?()
        }
    }
}

