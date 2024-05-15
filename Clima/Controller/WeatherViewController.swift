
import UIKit
import CoreLocation

class WeatherViewController: UIViewController, UITextFieldDelegate {
   
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
//Inicializando o Struct WeatherManager aqui
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        //Solicitar a autoricão para localizacao
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        
        //Dizer que essa classe terá delegate
        weatherManager.delegate = self
        
        //Para acessar os métodos do Protocolo UITextFieldDelegate, que faz com que o TextField se comunique com a View Controller
        searchTextField.delegate = self
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
}


//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextViewDelegate {
  
    @IBAction func searchPressed(_ sender: UIButton) {
        //Após clicar, o teclado do celular irá se esconder
        searchTextField.endEditing(true)
    }
    
    //Verifica quando o usuário parou de digitar, e executa o que está neste método, além de limpar o textField
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text {
            weatherManager.fetchWeather(cityName: city)
        }
        searchTextField.text = ""
    }
    
    //Aciona o botao de retorno do teclado do celular e ao pressionar o retorno, o teclado do celular desaparece
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Após clicar, o teclado do celular irá se esconder
        searchTextField.endEditing(true)
        return true
    }
    
    //Valida e verifica o que o usuáro digitou
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
           return true
        } else {
            textField.placeholder = "Type Something"
            return false
        }
    }
}

//MARK: - WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    
    func didFalilWithError(error: Error) {
        print(error)
    }
    
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingHeading()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fechWeatherLatLon(latitude: lat, longitude: lon)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}
