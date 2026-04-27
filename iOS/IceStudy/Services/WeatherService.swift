import CoreLocation

final class IceWeatherService {
    static let shared = IceWeatherService()

    private init() {}

    func fetchTemperature(at location: CLLocation) async throws -> Int {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current_weather=true"
        guard let url = URL(string: urlString) else { throw WeatherError.invalidURL }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
        return Int(decoded.current_weather.temperature.rounded())
    }
}

private struct OpenMeteoResponse: Decodable {
    struct CurrentWeather: Decodable {
        let temperature: Double
    }
    let current_weather: CurrentWeather
}

enum WeatherError: Error {
    case invalidURL
}
