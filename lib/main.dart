import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:weather_animation/weather_animation.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WeatherHome(),
    );
  }
}

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  int selectedTabIndex = 0;
  List<Widget> tabs = [];

  late List<double> coordinates;
  late String date;
  late String location;
  late String forecast;
  late Widget weatherScene;
  late List<String> weather;
  // weather[0] = temperature
  // weather[1] = description
  // weather[2] = icon

  @override
  void initState() {
    super.initState();
    initialize();
  }

  // Läser in allt appen behöver
  void initialize() async {
    date = getDate();
    coordinates = await getCoordinates();
    location = await getLocation(coordinates[0], coordinates[1]);
    weather = await getWeather(coordinates[0], coordinates[1]);
    forecast = await getForecast(coordinates[0], coordinates[1]);
    weatherScene = getWeatherScene(weather);

    setState(() {
      tabs = [
        WeatherTab(
          date: date,
          location: location,
          weather: weather,
          weatherScene: weatherScene,
        ),
        ForecastTab(
          forecast: forecast,
        ),
        const AboutTab(),
      ];
    });
  }

  // Metoder

  String getDate() {
    DateTime currentDate = DateTime.now();
    return DateFormat('E, MMMM d, y').format(currentDate);
  }

  Future<List<double>> getCoordinates() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<double> coordinates = [];
    coordinates.addAll(
        [position.latitude, position.longitude]); // Ändra koordinater här
    return coordinates;
  }

  Future<String> getLocation(lat, lon) async {
    final response = await http.get(Uri.parse(
        'http://api.openweathermap.org/geo/1.0/reverse?lat=$lat&lon=$lon&limit=2&appid=${API-KEY}'));
    final jsonData = jsonDecode(response.body);

    return "${jsonData[0]["name"]},${jsonData[0]['country']}";
  }

  Future<List<String>> getWeather(lat, lon) async {
    final response = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=${API-KEY}"));
    final jsonData = jsonDecode(response.body);

    List<String> weather = [];

    weather
        .add("${jsonData["main"]["temp"].toStringAsFixed(0)}°C"); // Temperature

    weather.add(jsonData["weather"][0]["description"]); // description

    weather.add(jsonData["weather"][0]["icon"]); // icon

    return weather;
  }

  Future<String> getForecast(lat, lon) async {
    final response = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=${API-KEY}"));

    return response.body;
  }

  // Prova att ändra koordinater för att se att det funkar!
  Widget getWeatherScene(List<String> weather) {
    // Switching on icon
    switch (weather[2]) {
      case '01d': // Clear sky (day)
        return const ClearSky();
      case '01n': // Clear sky (night)
        return const ClearSkyN();

      case '02d': // Few clouds (day)
        return const FewClouds();
      case '02n': // Few clouds (night)
        return const FewCloudsN();

      case '03d': // Scattered clouds (day)
        return const ScatteredClouds();
      case '03n': // Scattered clouds (night)
        return const ScatteredCloudsN();

      case '04d': // Broken clouds (day)
        return const BrokenClouds();
      case '04n': // Broken clouds (night)
        return const BrokenCloudsN();

      case '09d': // Shower rain (day)
        return const LightRain();
      case '09n': // Shower rain (night)
        return const LightRainN();

      case '10d': // Rain (day)
        return const Rain();
      case '10n': // Rain (night)
        return const RainN();

      case '11d': // Thunderstorm (day)
      case '11n': // Thunderstorm (night)
        return const ThunderStorm();

      case '13d': // Snow (day)
        return const Snow();
      case '13n': // Snow (night)
        return const SnowN();

      case '50d': // Mist (day)
        return const Mist();
      case '50n': // Mist (night)
        return const MistN();

      default:
        return const ClearSky();
    }
  }

  // Build metod
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 184, 233, 255),
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontSize: 24,
            fontFamily: "ArchivoBlack",
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 73, 175, 222),
      ),
      body: IndexedStack(
        index: selectedTabIndex,
        children: tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedTabIndex,
        onTap: (index) {
          setState(() {
            selectedTabIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Current',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Forecast',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
        ],
      ),
    );
  }
}

// Weather Tab
class WeatherTab extends StatelessWidget {
  const WeatherTab(
      {super.key,
      required this.date,
      required this.location,
      required this.weather,
      required this.weatherScene});

  final String date;
  final String location;
  final Widget weatherScene;
  final List<String> weather;
  // weather[0] = temperature
  // weather[1] = description
  // weather[2] = icon

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: weatherScene, // Ändra här för att se olika animationer
        ),
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                  "https://openweathermap.org/img/wn/${weather[2]}@2x.png"), // Icon
              Stack(
                children: [
                  Text(
                    location,
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: "ArchivoBlack",
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 0.8
                        ..color = Colors.white,
                    ),
                  ),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 25,
                      fontFamily: "ArchivoBlack",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Stack(
                children: [
                  Text(
                    weather[0], // Temperature
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: "ArchivoBlack",
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 0.8
                        ..color = Colors.white,
                    ),
                  ),
                  Text(
                    weather[0], // Temperature
                    style: const TextStyle(
                      fontSize: 30,
                      fontFamily: "ArchivoBlack",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Stack(
                children: [
                  Text(
                    weather[1], // Description
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: "ArchivoBlack",
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 0.8
                        ..color = Colors.white,
                    ),
                  ),
                  Text(
                    weather[1], // Description
                    style: const TextStyle(
                      fontSize: 22,
                      fontFamily: "ArchivoBlack",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Stack(
                children: [
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: "ArchivoBlack",
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 0.8
                        ..color = Colors.white,
                    ),
                  ),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: "ArchivoBlack",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Forecast Tab
class ForecastTab extends StatelessWidget {
  const ForecastTab({super.key, required this.forecast});

  final String forecast;

  @override
  Widget build(BuildContext context) {
    // Skapar en lista utav key-value par från Json strängens "list"
    final List<Map<String, dynamic>> forecastData =
        List.from(jsonDecode(forecast)['list']);

    return Center(
      child: ListView.builder(
        itemCount: forecastData.length,
        itemBuilder: (context, index) {
          final Map<String, dynamic> forecastEntry = forecastData[index];

          final String temperature =
              forecastEntry['main']['temp'].toStringAsFixed(0);
          final String description = forecastEntry['weather'][0]['description'];
          final String icon = forecastEntry['weather'][0]['icon'];
          final String dateTime = forecastEntry['dt_txt'] as String;

          final formattedDateTime = DateFormat('EEE, MMMM d, yyyy - HH:mm')
              .format(DateTime.parse(dateTime));

          return ListTile(
            leading:
                Image.network("https://openweathermap.org/img/wn/$icon.png"),
            title: Text(
              '$formattedDateTime - $temperature°C -  $description',
            ),
          );
        },
      ),
    );
  }
}

// About tab
class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 40),
        Text('Project Weather',
            style: TextStyle(
              fontSize: 40,
            )),
        SizedBox(height: 20),
        Text(
          'This is an app that is developed for the course 1DV535 at Linneaus University using Flutter and the OpenWeatherMap API.',
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text("Developed by Timor Falk"),
      ],
    );
  }
}

// Weather Scenes
// Från paketet https://pub.dev/packages/weather_animation
// Skapade i https://packruble.github.io/weather_animation/#/
class ClearSky extends StatelessWidget {
  const ClearSky({super.key});

  @override
  Widget build(BuildContext context) {
    return const WrapperScene(
      isLeftCornerGradient: true,
      colors: [
        Color(0xff1976d2),
        Color(0xffe1f5fe),
      ],
      children: [
        SunWidget(
          sunConfig: SunConfig(
              width: 300,
              blurSigma: 13,
              blurStyle: BlurStyle.solid,
              isLeftLocation: true,
              coreColor: Color(0xffff9800),
              midColor: Color(0xffffee58),
              outColor: Color(0xffffa726),
              animMidMill: 1500,
              animOutMill: 1500),
        ),
      ],
    );
  }
}

class ClearSkyN extends StatelessWidget {
  const ClearSkyN({super.key});

  @override
  Widget build(BuildContext context) {
    return const WrapperScene(
      isLeftCornerGradient: false,
      colors: [
        Color.fromARGB(255, 0, 8, 15),
        Color.fromARGB(255, 0, 71, 110),
      ],
      children: [],
    );
  }
}

class FewClouds extends StatelessWidget {
  const FewClouds({super.key});

  @override
  Widget build(BuildContext context) {
    return const WrapperScene(
      sizeCanvas: Size(350, 540),
      isLeftCornerGradient: true,
      colors: [
        Color(0xff1976d2),
        Color(0xffe1f5fe),
      ],
      children: [
        SunWidget(
          sunConfig: SunConfig(
              width: 300,
              blurSigma: 13,
              blurStyle: BlurStyle.solid,
              isLeftLocation: true,
              coreColor: Color(0xffff9800),
              midColor: Color(0xffffee58),
              outColor: Color(0xffffa726),
              animMidMill: 1500,
              animOutMill: 1500),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 203,
              color: Color(0xaaffffff),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 46,
              y: 60,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 11,
              slideY: 5,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
      ],
    );
  }
}

class FewCloudsN extends StatelessWidget {
  const FewCloudsN({super.key});

  @override
  Widget build(BuildContext context) {
    return const WrapperScene(
      sizeCanvas: Size(350, 540),
      isLeftCornerGradient: false,
      colors: [
        Color.fromARGB(255, 0, 8, 15),
        Color.fromARGB(255, 0, 71, 110),
      ],
      children: [
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 203,
              color: Color(0xaaffffff),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 46,
              y: 60,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 11,
              slideY: 5,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
      ],
    );
  }
}

class ScatteredClouds extends StatelessWidget {
  const ScatteredClouds({super.key});

  @override
  Widget build(BuildContext context) {
    return const WrapperScene(
      sizeCanvas: Size(350, 540),
      isLeftCornerGradient: true,
      colors: [
        Color(0xff1976d2),
        Color(0xffe1f5fe),
      ],
      children: [
        SunWidget(
          sunConfig: SunConfig(
              width: 301,
              blurSigma: 13,
              blurStyle: BlurStyle.solid,
              isLeftLocation: true,
              coreColor: Color(0xffff9800),
              midColor: Color(0xffffee58),
              outColor: Color(0xffffa726),
              animMidMill: 1500,
              animOutMill: 1500),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 154,
              color: Color(0xaaffffff),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 23,
              y: 104,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 11,
              slideY: 5,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 250,
              color: Color(0xaaffffff),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 110,
              y: 5,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 11,
              slideY: 5,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 154,
              color: Color(0xaaffffff),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 94,
              y: 40,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 11,
              slideY: 5,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
      ],
    );
  }
}

class ScatteredCloudsN extends StatelessWidget {
  const ScatteredCloudsN({super.key});

  @override
  Widget build(BuildContext context) {
    return const WrapperScene(
      sizeCanvas: Size(350, 540),
      isLeftCornerGradient: false,
      colors: [
        Color.fromARGB(255, 0, 8, 15),
        Color.fromARGB(255, 0, 71, 110),
      ],
      children: [
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 154,
              color: Color(0xaaffffff),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 23,
              y: 104,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 11,
              slideY: 5,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 250,
              color: Color(0xaaffffff),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 110,
              y: 5,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 11,
              slideY: 5,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 154,
              color: Color(0xaaffffff),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 94,
              y: 40,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 11,
              slideY: 5,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
      ],
    );
  }
}

class BrokenClouds extends StatelessWidget {
  const BrokenClouds({super.key});

  @override
  Widget build(BuildContext context) {
    return const WrapperScene(
      sizeCanvas: Size(350, 540),
      isLeftCornerGradient: true,
      colors: [
        Color(0xff424242),
        Color(0xffcfd8dc),
      ],
      children: [
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 270,
              color: Color(0xcdbdbdbd),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 119,
              y: -50,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 11,
              slideY: 13,
              slideDurMill: 4000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 250,
              color: Color(0x92fafafa),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 20,
              y: 3,
              scaleBegin: 1,
              scaleEnd: 1.08,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 20,
              slideY: 0,
              slideDurMill: 3000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 160,
              color: Color(0xb5fafafa),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 140,
              y: 97,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 20,
              slideY: 4,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
      ],
    );
  }
}

class BrokenCloudsN extends StatelessWidget {
  const BrokenCloudsN({super.key});

  @override
  Widget build(BuildContext context) {
    return const WrapperScene(
      sizeCanvas: Size(350, 540),
      isLeftCornerGradient: false,
      colors: [
        Color.fromARGB(255, 0, 0, 0),
        Color.fromARGB(255, 69, 69, 69),
      ],
      children: [
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 270,
              color: Color(0xcdbdbdbd),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 119,
              y: -50,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 11,
              slideY: 13,
              slideDurMill: 4000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 250,
              color: Color(0x92fafafa),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 20,
              y: 3,
              scaleBegin: 1,
              scaleEnd: 1.08,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 20,
              slideY: 0,
              slideDurMill: 3000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 160,
              color: Color(0xb5fafafa),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 140,
              y: 97,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 20,
              slideY: 4,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
      ],
    );
  }
}

class LightRain extends StatelessWidget {
  const LightRain({super.key});

  @override
  Widget build(BuildContext context) {
    return const WrapperScene(
      sizeCanvas: Size(350, 540),
      isLeftCornerGradient: true,
      colors: [
        Color(0xff1976d2),
        Color(0xffe1f5fe),
      ],
      children: [
        SunWidget(
          sunConfig: SunConfig(
              width: 300,
              blurSigma: 13,
              blurStyle: BlurStyle.solid,
              isLeftLocation: true,
              coreColor: Color(0xffff9800),
              midColor: Color(0xffffee58),
              outColor: Color(0xffffa726),
              animMidMill: 1500,
              animOutMill: 1500),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 241,
              color: Color(0xaaffffff),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 110,
              y: 5,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 11,
              slideY: 5,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 144,
              color: Color(0xaaffffff),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 23,
              y: 104,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 11,
              slideY: 5,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
        RainWidget(
          rainConfig: RainConfig(
              count: 14,
              lengthDrop: 12,
              widthDrop: 4,
              color: Color(0x9978909c),
              isRoundedEndsDrop: true,
              widgetRainDrop: null,
              fallRangeMinDurMill: 500,
              fallRangeMaxDurMill: 1500,
              areaXStart: 38,
              areaXEnd: 279,
              areaYStart: 215,
              areaYEnd: 540,
              slideX: 2,
              slideY: 0,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              fallCurve: Cubic(0.55, 0.09, 0.68, 0.53),
              fadeCurve: Cubic(0.95, 0.05, 0.80, 0.04)),
        ),
      ],
    );
  }
}

class LightRainN extends StatelessWidget {
  const LightRainN({super.key});

  @override
  Widget build(BuildContext context) {
    return const WrapperScene(
      sizeCanvas: Size(350, 540),
      isLeftCornerGradient: false,
      colors: [
        Color.fromARGB(255, 0, 8, 15),
        Color.fromARGB(255, 0, 71, 110),
      ],
      children: [
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 241,
              color: Color(0xaaffffff),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 110,
              y: 5,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 11,
              slideY: 5,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 144,
              color: Color(0xaaffffff),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 23,
              y: 104,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 11,
              slideY: 5,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
        RainWidget(
          rainConfig: RainConfig(
              count: 14,
              lengthDrop: 12,
              widthDrop: 4,
              color: Color(0x9978909c),
              isRoundedEndsDrop: true,
              widgetRainDrop: null,
              fallRangeMinDurMill: 500,
              fallRangeMaxDurMill: 1500,
              areaXStart: 38,
              areaXEnd: 279,
              areaYStart: 215,
              areaYEnd: 540,
              slideX: 2,
              slideY: 0,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              fallCurve: Cubic(0.55, 0.09, 0.68, 0.53),
              fadeCurve: Cubic(0.95, 0.05, 0.80, 0.04)),
        ),
      ],
    );
  }
}

class Rain extends StatelessWidget {
  const Rain({super.key});

  @override
  Widget build(BuildContext context) {
    return const WrapperScene(
      sizeCanvas: Size(350, 540),
      isLeftCornerGradient: true,
      colors: [
        Color(0xff424242),
        Color(0xffcfd8dc),
      ],
      children: [
        RainWidget(
          rainConfig: RainConfig(
              count: 30,
              lengthDrop: 13,
              widthDrop: 4,
              color: Color(0xff9e9e9e),
              isRoundedEndsDrop: true,
              widgetRainDrop: null,
              fallRangeMinDurMill: 500,
              fallRangeMaxDurMill: 1500,
              areaXStart: 41,
              areaXEnd: 264,
              areaYStart: 208,
              areaYEnd: 620,
              slideX: 2,
              slideY: 0,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              fallCurve: Cubic(0.55, 0.09, 0.68, 0.53),
              fadeCurve: Cubic(0.95, 0.05, 0.80, 0.04)),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 270,
              color: Color(0xcdbdbdbd),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 119,
              y: -50,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 11,
              slideY: 13,
              slideDurMill: 4000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 250,
              color: Color(0x92fafafa),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 20,
              y: 3,
              scaleBegin: 1,
              scaleEnd: 1.08,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 20,
              slideY: 0,
              slideDurMill: 3000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 160,
              color: Color(0xb5fafafa),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 140,
              y: 97,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 20,
              slideY: 4,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
      ],
    );
  }
}

class RainN extends StatelessWidget {
  const RainN({super.key});

  @override
  Widget build(BuildContext context) {
    return const WrapperScene(
      sizeCanvas: Size(350, 540),
      isLeftCornerGradient: false,
      colors: [
        Color.fromARGB(255, 0, 0, 0),
        Color.fromARGB(255, 94, 94, 95),
      ],
      children: [
        RainWidget(
          rainConfig: RainConfig(
              count: 30,
              lengthDrop: 13,
              widthDrop: 4,
              color: Color(0xff9e9e9e),
              isRoundedEndsDrop: true,
              widgetRainDrop: null,
              fallRangeMinDurMill: 500,
              fallRangeMaxDurMill: 1500,
              areaXStart: 41,
              areaXEnd: 264,
              areaYStart: 208,
              areaYEnd: 620,
              slideX: 2,
              slideY: 0,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              fallCurve: Cubic(0.55, 0.09, 0.68, 0.53),
              fadeCurve: Cubic(0.95, 0.05, 0.80, 0.04)),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 270,
              color: Color(0xcdbdbdbd),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 119,
              y: -50,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 11,
              slideY: 13,
              slideDurMill: 4000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 250,
              color: Color(0x92fafafa),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 20,
              y: 3,
              scaleBegin: 1,
              scaleEnd: 1.08,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 20,
              slideY: 0,
              slideDurMill: 3000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 160,
              color: Color(0xb5fafafa),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 140,
              y: 97,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 20,
              slideY: 4,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
      ],
    );
  }
}

class ThunderStorm extends StatelessWidget {
  const ThunderStorm({super.key});

  @override
  Widget build(BuildContext context) {
    return const WrapperScene(
      sizeCanvas: Size(350, 540),
      isLeftCornerGradient: false,
      colors: [
        Color(0xff263238),
        Color(0xff78909c),
      ],
      children: [
        WindWidget(
          windConfig: WindConfig(
              width: 5,
              y: 208,
              windGap: 10,
              blurSigma: 6,
              color: Color(0xff607d8b),
              slideXStart: 0,
              slideXEnd: 350,
              pauseStartMill: 50,
              pauseEndMill: 6000,
              slideDurMill: 1000,
              blurStyle: BlurStyle.solid),
        ),
        RainWidget(
          rainConfig: RainConfig(
              count: 40,
              lengthDrop: 13,
              widthDrop: 4,
              color: Color(0x9978909c),
              isRoundedEndsDrop: true,
              widgetRainDrop: null,
              fallRangeMinDurMill: 500,
              fallRangeMaxDurMill: 1500,
              areaXStart: 41,
              areaXEnd: 264,
              areaYStart: 208,
              areaYEnd: 620,
              slideX: 2,
              slideY: 0,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              fallCurve: Cubic(0.55, 0.09, 0.68, 0.53),
              fadeCurve: Cubic(0.95, 0.05, 0.80, 0.04)),
        ),
        ThunderWidget(
          thunderConfig: ThunderConfig(
              thunderWidth: 11,
              blurSigma: 28,
              blurStyle: BlurStyle.solid,
              color: Color(0x99ffee58),
              flashStartMill: 50,
              flashEndMill: 300,
              pauseStartMill: 50,
              pauseEndMill: 6000,
              points: [Offset(110.0, 210.0), Offset(120.0, 240.0)]),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 250,
              color: Color(0xad90a4ae),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 20,
              y: 3,
              scaleBegin: 1,
              scaleEnd: 1.08,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 20,
              slideY: 0,
              slideDurMill: 3000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
        WindWidget(
          windConfig: WindConfig(
              width: 7,
              y: 300,
              windGap: 15,
              blurSigma: 7,
              color: Color(0xff607d8b),
              slideXStart: 0,
              slideXEnd: 350,
              pauseStartMill: 50,
              pauseEndMill: 6000,
              slideDurMill: 1000,
              blurStyle: BlurStyle.solid),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 160,
              color: Color(0xb1607d8b),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 140,
              y: 97,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 20,
              slideY: 4,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
      ],
    );
  }
}

class Snow extends StatelessWidget {
  const Snow({super.key});

  @override
  Widget build(BuildContext context) {
    return const WrapperScene(
      sizeCanvas: Size(350, 540),
      isLeftCornerGradient: true,
      colors: [
        Color(0xff3949ab),
        Color(0xff90caf9),
        Color(0xffd6d6d6),
      ],
      children: [
        SnowWidget(
          snowConfig: SnowConfig(
              count: 30,
              size: 20,
              color: Color(0xb3ffffff),
              icon: IconData(57399, fontFamily: 'MaterialIcons'),
              widgetSnowflake: null,
              areaXStart: 42,
              areaXEnd: 240,
              areaYStart: 200,
              areaYEnd: 540,
              waveRangeMin: 20,
              waveRangeMax: 70,
              waveMinSec: 5,
              waveMaxSec: 20,
              waveCurve: Cubic(0.45, 0.05, 0.55, 0.95),
              fadeCurve: Cubic(0.60, 0.04, 0.98, 0.34),
              fallMinSec: 10,
              fallMaxSec: 60),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 250,
              color: Color(0xa8fafafa),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 20,
              y: 3,
              scaleBegin: 1,
              scaleEnd: 1.08,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 20,
              slideY: 0,
              slideDurMill: 3000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 160,
              color: Color(0xa8fafafa),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 140,
              y: 97,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 20,
              slideY: 4,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
      ],
    );
  }
}

class SnowN extends StatelessWidget {
  const SnowN({super.key});

  @override
  Widget build(BuildContext context) {
    return const WrapperScene(
      sizeCanvas: Size(350, 540),
      isLeftCornerGradient: false,
      colors: [
        Color.fromARGB(255, 0, 8, 15),
        Color.fromARGB(255, 0, 71, 110),
      ],
      children: [
        SnowWidget(
          snowConfig: SnowConfig(
              count: 30,
              size: 20,
              color: Color(0xb3ffffff),
              icon: IconData(57399, fontFamily: 'MaterialIcons'),
              widgetSnowflake: null,
              areaXStart: 42,
              areaXEnd: 240,
              areaYStart: 200,
              areaYEnd: 540,
              waveRangeMin: 20,
              waveRangeMax: 70,
              waveMinSec: 5,
              waveMaxSec: 20,
              waveCurve: Cubic(0.45, 0.05, 0.55, 0.95),
              fadeCurve: Cubic(0.60, 0.04, 0.98, 0.34),
              fallMinSec: 10,
              fallMaxSec: 60),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 250,
              color: Color(0xa8fafafa),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 20,
              y: 3,
              scaleBegin: 1,
              scaleEnd: 1.08,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 20,
              slideY: 0,
              slideDurMill: 3000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 160,
              color: Color(0xa8fafafa),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 140,
              y: 97,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 20,
              slideY: 4,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
      ],
    );
  }
}

class Mist extends StatelessWidget {
  const Mist({super.key});

  @override
  Widget build(BuildContext context) {
    return const WrapperScene(
      sizeCanvas: Size(350, 540),
      isLeftCornerGradient: true,
      colors: [
        Color(0xff37474f),
        Color(0xff546e7a),
        Color(0xffbdbdbd),
        Color(0xff90a4ae),
        Color(0xff78909c),
      ],
      children: [
        WindWidget(
          windConfig: WindConfig(
              width: 5,
              y: 208,
              windGap: 10,
              blurSigma: 6,
              color: Color(0xff607d8b),
              slideXStart: 0,
              slideXEnd: 350,
              pauseStartMill: 50,
              pauseEndMill: 6000,
              slideDurMill: 1000,
              blurStyle: BlurStyle.solid),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 250,
              color: Color(0xa8fafafa),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 20,
              y: 3,
              scaleBegin: 1,
              scaleEnd: 1.08,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 20,
              slideY: 0,
              slideDurMill: 3000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
        WindWidget(
          windConfig: WindConfig(
              width: 7,
              y: 300,
              windGap: 15,
              blurSigma: 7,
              color: Color(0xff607d8b),
              slideXStart: 0,
              slideXEnd: 350,
              pauseStartMill: 50,
              pauseEndMill: 6000,
              slideDurMill: 1000,
              blurStyle: BlurStyle.solid),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 160,
              color: Color(0xa8fafafa),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 140,
              y: 97,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 20,
              slideY: 4,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
      ],
    );
  }
}

class MistN extends StatelessWidget {
  const MistN({super.key});

  @override
  Widget build(BuildContext context) {
    return const WrapperScene(
      sizeCanvas: Size(350, 540),
      isLeftCornerGradient: true,
      colors: [
        Color.fromARGB(255, 41, 53, 59),
        Color.fromARGB(255, 58, 77, 86),
        Color.fromARGB(255, 141, 140, 140),
        Color.fromARGB(255, 110, 126, 134),
        Color.fromARGB(255, 97, 115, 125),
      ],
      children: [
        WindWidget(
          windConfig: WindConfig(
              width: 5,
              y: 208,
              windGap: 10,
              blurSigma: 6,
              color: Color(0xff607d8b),
              slideXStart: 0,
              slideXEnd: 350,
              pauseStartMill: 50,
              pauseEndMill: 6000,
              slideDurMill: 1000,
              blurStyle: BlurStyle.solid),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 250,
              color: Color(0xa8fafafa),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 20,
              y: 3,
              scaleBegin: 1,
              scaleEnd: 1.08,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 20,
              slideY: 0,
              slideDurMill: 3000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
        WindWidget(
          windConfig: WindConfig(
              width: 7,
              y: 300,
              windGap: 15,
              blurSigma: 7,
              color: Color(0xff607d8b),
              slideXStart: 0,
              slideXEnd: 350,
              pauseStartMill: 50,
              pauseEndMill: 6000,
              slideDurMill: 1000,
              blurStyle: BlurStyle.solid),
        ),
        CloudWidget(
          cloudConfig: CloudConfig(
              size: 160,
              color: Color(0xa8fafafa),
              icon: IconData(63056, fontFamily: 'MaterialIcons'),
              widgetCloud: null,
              x: 140,
              y: 97,
              scaleBegin: 1,
              scaleEnd: 1.1,
              scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
              slideX: 20,
              slideY: 4,
              slideDurMill: 2000,
              slideCurve: Cubic(0.40, 0.00, 0.20, 1.00)),
        ),
      ],
    );
  }
}
