//
//  WeatherManager.swift
//  Clima
//
//  Created by Higor  Lo Castro on 04/02/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

//Criando o protolo que fica na mesma classe que será utilizado
protocol WeatherManagerDelegate {
    
    //Função do protocolo que deve ser usada obrigatoriamente onde o protocolo for utilizado
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    
    //Funcao para verificar erros
    func didFalilWithError(error: Error)
    
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=8306eda4f3e50e44edc1988cb63a04f4&units=metric"
    
    
    var delegate: WeatherManagerDelegate?
    
    //Passa a URL e o nome da cidade para chamar a API
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fechWeatherLatLon(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }

    
    //Requisicao da API
    func performRequest(with urlString: String) {
        
        //1 - Constante que armazena a URL
        if let url = URL(string: urlString) {
            
            //2 - onstante que armazena URLSession
            let session = URLSession(configuration: .default)
            
            //3 - Da uma tarefa à Sessão
            let task = session.dataTask(with: url) { (data, response, error) in
                
                if error != nil {
                    self.delegate?.didFalilWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        //Coloca-se Self para apontar que é o delegate da classe atual
                        self.delegate?.didUpdateWeather(self, weather:weather)
                    }
                    
                }
                
            }
            //4 - Inicia a tarefa
            task.resume()
        }
    }
    
    //Transforma o Json em um objeto
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
        
            let  weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
       
        } catch {
            delegate?.didFalilWithError(error: error)
            return nil
        }
    }

    
}
