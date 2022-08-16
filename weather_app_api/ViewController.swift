//
//  ViewController.swift
//  weather_app_api
//
//  Created by Cenk Bahadır Çark on 15.08.2022.
//

import UIKit
import CoreLocation


class ViewController: UIViewController {
    @IBOutlet weak var temperatureView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var minTemperatureLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var maxTemperatureLabel: UILabel!
    @IBOutlet weak var weatherSitutation: UILabel!
    @IBOutlet weak var weatherNameLabel: UILabel!
    
    @IBOutlet weak var windLabel: UILabel!
    var weatherInfo : MainResponse?
    var iconLink : String?
    var gelenWeather = [Weather]()
    var choosenLocationLat:Double?
    var choosenLocationLon:Double?
    var locationManager : CLLocationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self

        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        getDataResponse()

    }
    
    func getDataResponse() {
        
        if let lat = choosenLocationLat, let log = choosenLocationLon {
            let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(log)&appid=76c86debbbd10bd3e04fd0164502c3df")
            
            URLSession.shared.dataTask(with: url!){data, response, error in
                            
                            if error != nil || data == nil{
                                print("Error")
                            }
                            do{
                                
                                let response = try JSONDecoder().decode(WeatherResponse.self, from: data!)
                                
                                DispatchQueue.main.async {
                                    if let weatherData = response.main{
                                        self.weatherInfo = weatherData
                                        self.temperatureLabel.text = "\(Int(self.weatherInfo!.temp - 273))°"
                                        self.minTemperatureLabel.text = "Min Temp: \(Int(self.weatherInfo!.tempMin - 273))°"
                                        self.maxTemperatureLabel.text = "Max Temp: \(Int(self.weatherInfo!.tempMax - 273))°"
                                        self.feelsLikeLabel.text = "Feels Like: \(Int(self.weatherInfo!.feelsLike - 273))°"
                                        self.humidityLabel.text = "Humidity: \(Int(self.weatherInfo!.humidity))%"
                                        if let gelenName = response.name{
                                            self.weatherNameLabel.text = gelenName
                                        }
                                        if let gelenWind = response.wind{
                                            self.windLabel.text = "Wind : \(gelenWind.speed!) km/h"
                                        }
                                        if let gelenHava = response.weather{
                                            self.gelenWeather = gelenHava
                                            let gelenDescription = self.gelenWeather.map{$0.description!}
                                            let situationName = gelenDescription.joined().uppercased()
                                            self.weatherSitutation.text = "\(situationName)"
                                            let gelenIcon = self.gelenWeather.map{$0.icon!}
                                            let gelenIconName = gelenIcon.joined()
                                            //for weather icon
                                            let iconURL = URL(string: "https://openweathermap.org/img/wn/\(gelenIconName)@2x.png")
                                                DispatchQueue.global().async {
                                                    let data = try? Data(contentsOf: iconURL!)
                                                    if data != nil{
                                                        DispatchQueue.main.async {
                                                            self.temperatureView.image = UIImage(data: data!)
                                                        }
                                                    }
                                                }
                                            
                                    }
                                }

                                }
                            }catch{
                                print(error.localizedDescription)
                            }
            }.resume()

        }

        }
    }


extension ViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let lastLocation : CLLocation = locations[locations.count - 1]
        
        
        choosenLocationLat = lastLocation.coordinate.latitude
        choosenLocationLon = lastLocation.coordinate.longitude
        getDataResponse()

    }
}

