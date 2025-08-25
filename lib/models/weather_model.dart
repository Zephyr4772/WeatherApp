class Weather {
  final String cityName;
  final double temperature;
  final String condition;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int visibility;
  final double tempMin;
  final double tempMax;
  final DateTime? date;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.visibility,
    required this.tempMin,
    required this.tempMax,
    this.date,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      condition: json['weather'][0]['main'],
      feelsLike: json['main']['feels_like'].toDouble(),
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      visibility: json['visibility'],
      tempMin: json['main']['temp_min'].toDouble(),
      tempMax: json['main']['temp_max'].toDouble(),
    );
  }

  factory Weather.fromForecastJson(Map<String, dynamic> json, String cityName) {
    return Weather(
      cityName: cityName,
      temperature: json['main']['temp'].toDouble(),
      condition: json['weather'][0]['main'],
      feelsLike: json['main']['feels_like'].toDouble(),
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      visibility: json['visibility'] ?? 10000, // Forecast API might not have visibility
      tempMin: json['main']['temp_min'].toDouble(),
      tempMax: json['main']['temp_max'].toDouble(),
      date: DateTime.parse(json['dt_txt']),
    );
  }
}
