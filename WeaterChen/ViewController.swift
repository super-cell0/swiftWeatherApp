//
//  ViewController.swift
//  WeaterChen
//
//  Created by xiaoxiong beidi on 2022/4/29.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    
    let locationManager = CLLocationManager()
    let weather = Weather() //Weather文件
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        //请求授权获取当前位置信息
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestLocation()
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lon = locations[0].coordinate.longitude
        let lat = locations[0].coordinate.latitude
        //30.670695716699246, 104.0287005900947 成都
        //print(lon, lat)
        //获取天气和天气图标
        AF.request("https://devapi.qweather.com/v7/weather/now?location=\(lon),\(lat)&key=a9b1817577be434f8690d20a25b20cc3").responseJSON { response in
            if let data = response.value {
                
                //print(data)
                //print(weatherJson["now", "temp"])
                let weatherJson = JSON(data)
                
                self.weather.temp = "\(weatherJson["now", "temp"].stringValue)˚"
                self.weather.icon = weatherJson["now", "icon"].stringValue
                
                self.tempLabel.text = self.weather.temp
                self.iconImageView.image = UIImage(named: self.weather.icon)
            }
        }
        //获取城市
        AF.request("https://geoapi.qweather.com/v2/city/lookup?location=\(lon),\(lat)&key=a9b1817577be434f8690d20a25b20cc3").responseJSON { response in
            if let data = response.value {
                let cityJSON = JSON(data)
                
                self.weather.city = cityJSON["location", 0, "name"].stringValue
                self.cityLabel.text = self.weather.city
            }
        }
    }
    
    //获取位置信息失败调用
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print(error)
        cityLabel.text = "获取位置信息失败"
    }
}

extension ViewController: QueryViewControllerDelegate {
    
    //页面传值-正向
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "QueryViewControllerSegueID" {
//            let vc = segue.destination as! QueryViewController
//            vc.currentCity = weather.city
//        }
        if let vc = segue.destination as? QueryViewController {
            vc.currentCity = weather.city
            vc.queryDelegate = self
        }
    }
    
    //页面传值-反向
    func didChangeCity(city: String) {
        //print(city)
        let paremeters = [ "location": city, "key": "a9b1817577be434f8690d20a25b20cc3"]
        AF.request("https://geoapi.qweather.com/v2/city/lookup", parameters: paremeters).responseJSON { response in
            if let data = response.value {
                let cityJSON = JSON(data)
                //数据
                self.weather.city = cityJSON["location", 0, "name"].stringValue
                //UI
                self.cityLabel.text = self.weather.city
                
                //异步执行需要在同级--获取城市天气
                let paremeters = [ "location": cityJSON["location", 0, "id"], "key": "a9b1817577be434f8690d20a25b20cc3"]
                AF.request("https://devapi.qweather.com/v7/weather/now", parameters: paremeters).responseJSON { response in
                    if let data = response.value {
                        
                        //print(data)
                        //print(weatherJson["now", "temp"])
                        let weatherJson = JSON(data)
                        
                        self.weather.temp = "\(weatherJson["now", "temp"].stringValue)˚"
                        self.weather.icon = weatherJson["now", "icon"].stringValue
                        
                        self.tempLabel.text = self.weather.temp
                        self.iconImageView.image = UIImage(named: self.weather.icon)
                    }
                }
            }
        }
        
    }
}

