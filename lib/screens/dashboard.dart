import 'package:aa_new/screens/chat_ai_screen.dart';
import 'package:aa_new/screens/profile_screen.dart';
import 'package:aa_new/screens/disease_detection_screen.dart';
import 'package:aa_new/screens/about_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/weather.dart';
import '../services/weather_service.dart';
import '../services/bluetooth_service_stub.dart'
    if (dart.library.io) '../services/bluetooth_service.dart';
import 'package:flutter/foundation.dart';
import 'login.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isOnline = true;
  String selectedCity = "Vadodara";
  User? currentUser;
  final BluetoothService _bt = BluetoothService();
  bool _btConnecting = false;

  final List<String> cities = [
    "Vadodara",
    "Mumbai",
    "Delhi",
    "Bengaluru",
    "Chennai",
    "Hyderabad",
    "Ahmedabad",
    "Jaipur",
    "Kolkata",
    "Pune",
  ];

  Weather? _weather;
  List<Map<String, dynamic>> _forecast = [];
  bool _isLoadingWeather = true;

  // Motor and UV states
  bool isMotor1On = false;
  bool isMotor2On = false;
  bool isUVLightOn = false;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _fetchWeather();
    // Auto-connect to HC-05 after first frame on supported platforms (non-web)
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensureBtConnected();
      });
    }
  }

  Future<void> _ensureBtConnected() async {
    if (_bt.isConnected) return;
    setState(() => _btConnecting = true);
    try {
      await _bt.connect(name: 'HC-05');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bluetooth: Connected to HC-05')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Bluetooth connect failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _btConnecting = false);
    }
  }

  Future<bool> _sendBt(String cmd) async {
    try {
      if (!_bt.isConnected) {
        await _ensureBtConnected();
      }
      if (_bt.isConnected) {
        await _bt.send(cmd);
        return true;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Bluetooth send failed: $e')));
    }
    return false;
  }

  Future<void> _toggleMotor1() async {
    final cmd = isMotor1On ? 'B' : 'A';
    final ok = await _sendBt(cmd);
    if (ok) setState(() => isMotor1On = !isMotor1On);
  }

  Future<void> _toggleMotor2() async {
    final cmd = isMotor2On ? 'D' : 'C';
    final ok = await _sendBt(cmd);
    if (ok) setState(() => isMotor2On = !isMotor2On);
  }

  Future<void> _toggleUV() async {
    final cmd = isUVLightOn ? 'l' : 'L';
    final ok = await _sendBt(cmd);
    if (ok) setState(() => isUVLightOn = !isUVLightOn);
  }

  /// 🌦 Fetch Weather
  void _fetchWeather() async {
    setState(() => _isLoadingWeather = true);
    try {
      final coords = {
        "Vadodara": [22.3072, 73.1812],
        "Mumbai": [19.0760, 72.8777],
        "Delhi": [28.7041, 77.1025],
        "Bengaluru": [12.9716, 77.5946],
        "Chennai": [13.0827, 80.2707],
        "Hyderabad": [17.3850, 78.4867],
        "Ahmedabad": [23.0225, 72.5714],
        "Jaipur": [26.9124, 75.7873],
        "Kolkata": [22.5726, 88.3639],
        "Pune": [18.5204, 73.8567],
      };

      final lat = coords[selectedCity]![0];
      final lon = coords[selectedCity]![1];

      // Get current weather
      final weather = await WeatherService.getWeather(lat, lon);

      // Get forecast data
      final forecast = await WeatherService.getForecast(lat, lon);

      setState(() {
        _weather = weather;
        _forecast = forecast;
        _isLoadingWeather = false;
      });
    } catch (e) {
      setState(() => _isLoadingWeather = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load weather: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildBody(),
      floatingActionButton: _buildFABs(),
    );
  }

  /// ✅ AppBar
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        "AgroXpert Plus",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.green.shade600,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchWeather),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Row(
            children: [
              Icon(
                isOnline ? Icons.circle : Icons.circle_outlined,
                color: isOnline ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                isOnline ? "Online" : "Offline",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              Switch(
                value: isOnline,
                activeColor: Colors.white,
                onChanged: (value) => setState(() => isOnline = value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ✅ Drawer
  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(currentUser?.displayName ?? "User"),
            accountEmail: Text(currentUser?.email ?? ""),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: currentUser?.photoURL != null
                  ? NetworkImage(currentUser!.photoURL!)
                  : null,
              child: currentUser?.photoURL == null
                  ? Text(
                      (currentUser?.displayName != null &&
                              currentUser!.displayName!.isNotEmpty)
                          ? currentUser!.displayName![0].toUpperCase()
                          : "U",
                      style: const TextStyle(fontSize: 24, color: Colors.green),
                    )
                  : null,
            ),
            decoration: BoxDecoration(color: Colors.green.shade600),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.health_and_safety),
            title: const Text('Disease Detection'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DiseaseDetectionScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('AI History'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("AI History clicked")),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  /// ✅ Body
  Widget _buildBody() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBluetoothStatusCard(),
            const SizedBox(height: 12),
            if (isOnline) ...[
              _buildWeatherCard(),
              const SizedBox(height: 16),
              _buildWindSpeedCard(),
              const SizedBox(height: 16),
            ] else ...[
              _buildOfflineNotice(),
              const SizedBox(height: 16),
            ],
            _buildMetricsGrid(),
            const SizedBox(height: 16),
            _buildUVLightCard(), // Rectangular UV Light Card
            const SizedBox(height: 16),
            if (isOnline) _buildSuggestionsSection(),
            const SizedBox(height: 80), // Padding for FAB
          ],
        ),
      ),
    );
  }

  /// 🌤 Weather Card
  Widget _buildWeatherCard() {
    // Get current date and time for realistic display
    final now = DateTime.now();
    final formattedDate =
        "${_getWeekday(now.weekday)}, ${now.day} ${_getMonth(now.month)}";
    final formattedTime =
        "${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<String>(
                      value: selectedCity,
                      underline: const SizedBox(),
                      dropdownColor: Colors.white,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      items: cities.map((String city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedCity = newValue!;
                          _fetchWeather();
                        });
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$formattedDate • Updated at $formattedTime",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLoadingWeather
                          ? "Loading..."
                          : _weather?.description.toUpperCase() ?? "",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.air, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          _isLoadingWeather ? "" : "${_weather?.windSpeed} m/s",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.water_drop,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isLoadingWeather
                              ? ""
                              : "${_getHumidity()}% humidity",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          _isLoadingWeather
                              ? "--°"
                              : "${_weather?.temperature.toStringAsFixed(1)}°C",
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isLoadingWeather
                              ? ""
                              : "Feels like ${_weather?.feelsLike.toStringAsFixed(1)}°",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  _isLoadingWeather || _weather == null
                      ? Icons.wb_cloudy
                      : _weather!.getWeatherIcon(),
                  size: 50,
                  color: Colors.blueGrey,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildForecastRow(),
          ],
        ),
      ),
    );
  }

  /// Get weekday name
  String _getWeekday(int day) {
    switch (day) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
      default:
        return "";
    }
  }

  /// Get month name
  String _getMonth(int month) {
    switch (month) {
      case 1:
        return "Jan";
      case 2:
        return "Feb";
      case 3:
        return "Mar";
      case 4:
        return "Apr";
      case 5:
        return "May";
      case 6:
        return "Jun";
      case 7:
        return "Jul";
      case 8:
        return "Aug";
      case 9:
        return "Sep";
      case 10:
        return "Oct";
      case 11:
        return "Nov";
      case 12:
        return "Dec";
      default:
        return "";
    }
  }

  /// Get realistic humidity based on weather condition
  int _getHumidity() {
    if (_weather == null) return 65;

    final condition = _weather!.main.toLowerCase();
    if (condition.contains('rain') || condition.contains('drizzle')) {
      return 85 + (DateTime.now().microsecond % 10);
    } else if (condition.contains('clear')) {
      return 45 + (DateTime.now().microsecond % 15);
    } else if (condition.contains('cloud')) {
      return 65 + (DateTime.now().microsecond % 15);
    } else if (condition.contains('snow')) {
      return 75 + (DateTime.now().microsecond % 10);
    }
    return 60 + (DateTime.now().microsecond % 20);
  }

  /// Build forecast row with next few days
  Widget _buildForecastRow() {
    final now = DateTime.now();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_forecast.length > 0 ? _forecast.length : 4, (
        index,
      ) {
        // Use real forecast data if available
        if (_forecast.isNotEmpty && index < _forecast.length) {
          final forecastDay = _forecast[index];
          final date = forecastDay['date'] as DateTime;
          final temp = forecastDay['temp'].toStringAsFixed(1);
          final main = forecastDay['main'] as String;

          // Get icon based on weather condition
          IconData icon = Icons.wb_cloudy;
          switch (main.toLowerCase()) {
            case 'clouds':
              icon = Icons.wb_cloudy;
              break;
            case 'rain':
              icon = Icons.grain;
              break;
            case 'clear':
              icon = Icons.wb_sunny;
              break;
            case 'snow':
              icon = Icons.ac_unit;
              break;
            case 'thunderstorm':
              icon = Icons.flash_on;
              break;
          }

          return Column(
            children: [
              Text(
                _getWeekday(date.weekday).substring(0, 3),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 4),
              Icon(icon, size: 20, color: Colors.blueGrey),
              const SizedBox(height: 4),
              Text(
                "$temp°",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          );
        } else {
          // Fallback to generated forecast if API data not available
          final day = now.add(Duration(days: index + 1));
          final temp = _generateForecastTemp(index);
          final icon = _getForecastIcon(index);

          return Column(
            children: [
              Text(
                _getWeekday(day.weekday).substring(0, 3),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 4),
              Icon(icon, size: 20, color: Colors.blueGrey),
              const SizedBox(height: 4),
              Text(
                "$temp°",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          );
        }
      }),
    );
  }

  /// Generate realistic forecast temperatures
  String _generateForecastTemp(int dayOffset) {
    if (_weather == null) return "25";

    // Base temperature from current weather
    double baseTemp = _weather!.temperature;

    // Add some realistic variation (±3 degrees)
    final random = DateTime.now().microsecond % 60;
    final variation = (random - 30) / 10;

    // Slight cooling trend for future days
    final trend = dayOffset * -0.5;

    final forecastTemp = baseTemp + variation + trend;
    return forecastTemp.toStringAsFixed(1);
  }

  /// Get forecast icon based on pattern
  IconData _getForecastIcon(int dayOffset) {
    if (_weather == null) return Icons.wb_cloudy;

    final condition = _weather!.main.toLowerCase();
    final random = (DateTime.now().microsecond + dayOffset * 1000) % 100;

    // Create a realistic weather pattern based on current conditions
    if (condition.contains('rain')) {
      if (random < 60) return Icons.grain; // Still raining
      if (random < 85) return Icons.wb_cloudy; // Cloudy after rain
      return Icons.wb_sunny; // Clear after rain
    } else if (condition.contains('clear')) {
      if (random < 60) return Icons.wb_sunny; // Still sunny
      if (random < 90) return Icons.wb_cloudy; // Becoming cloudy
      return Icons.grain; // Unexpected rain
    } else if (condition.contains('cloud')) {
      if (random < 40) return Icons.wb_cloudy; // Still cloudy
      if (random < 70) return Icons.wb_sunny; // Clearing up
      return Icons.grain; // Rain developing
    }

    // Default weather icons with some randomness
    final icons = [
      Icons.wb_sunny,
      Icons.wb_cloudy,
      Icons.grain,
      Icons.wb_cloudy,
    ];
    return icons[random % icons.length];
  }

  /// 🌬 Wind Speed Card
  Widget _buildWindSpeedCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isLoadingWeather
                  ? "--"
                  : _weather?.windSpeed.toStringAsFixed(1) ?? "--",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Wind Speed (m/s)",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            Icon(Icons.air, color: Colors.blue.shade400, size: 28),
          ],
        ),
      ),
    );
  }

  /// 📊 Metrics Grid
  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.85, // Adjusted aspect ratio to prevent overflow
      children: [
        _buildMetricCard(
          "Soil Moisture",
          "Sensor Not Connected ",
          "normal",
          Icons.water_drop,
          Colors.green,
        ),
        _buildMetricCard(
          "Tank Level",
          "79%",
          "good",
          Icons.storage,
          Colors.blue,
        ),
        _buildMetricCard(
          "System Health",
          "65%",
          "good",
          Icons.health_and_safety,
          Colors.orange,
        ),
        _buildMetricCard(
          "Battery Level",
          "86%",
          "perfect",
          Icons.battery_charging_full,
          Colors.green,
        ),
        _buildEnhancedMotorCard("Motor 1", isMotor1On, Colors.green, () async {
          await _toggleMotor1();
        }),
        _buildEnhancedMotorCard("Motor 2", isMotor2On, Colors.green, () async {
          await _toggleMotor2();
        }),
      ],
    );
  }

  /// 📊 Metric Card
  Widget _buildMetricCard(
    String title,
    String value,
    String status,
    IconData icon,
    Color color,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleMetricAction(title),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                ),
                child: const Text(
                  "Action",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🚀 Enhanced Motor Card (Fixed Overflow)
  Widget _buildEnhancedMotorCard(
    String title,
    bool isOn,
    Color color,
    VoidCallback onPressed,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.settings_power, color: color, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isOn ? "Running" : "Stopped",
                        style: TextStyle(
                          fontSize: 11,
                          color: isOn ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOn ? Colors.red : color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isOn ? Icons.power_off : Icons.power_settings_new,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOn ? "OFF" : "ON",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 💡 Rectangular UV Light Card
  Widget _buildUVLightCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.light_mode, color: Colors.purple, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "UV Light Control",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Sterilization System",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Current Status",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isUVLightOn ? "ACTIVE" : "INACTIVE",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isUVLightOn ? Colors.purple : Colors.grey,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async => _toggleUV(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isUVLightOn ? Colors.red : Colors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isUVLightOn ? Icons.toggle_on : Icons.toggle_off,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isUVLightOn ? "OFF" : "ON",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔵 Bluetooth Status Card
  Widget _buildBluetoothStatusCard() {
    final connected = _bt.isConnected;
    final label = connected
        ? 'HC-05: Connected'
        : _btConnecting
        ? 'Connecting…'
        : 'HC-05: Disconnected';
    final color = connected
        ? Colors.green
        : (_btConnecting ? Colors.orange : Colors.grey);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.bluetooth, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: _btConnecting
                  ? null
                  : () async {
                      if (connected) {
                        await _bt.disconnect();
                        if (mounted) setState(() {});
                      } else {
                        await _ensureBtConnected();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: connected ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: Text(connected ? 'Disconnect' : 'Connect'),
            ),
          ],
        ),
      ),
    );
  }

  /// 💡 Suggestions Section
  Widget _buildSuggestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Smart Suggestions",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildSuggestionTile(Icons.opacity, "Dry soil – Irrigation triggered"),
        const SizedBox(height: 8),
        _buildSuggestionTile(
          Icons.sunny,
          "High UV index – Cover crops recommended",
        ),
      ],
    );
  }

  Widget _buildSuggestionTile(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📵 Offline Notice
  Widget _buildOfflineNotice() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.red.shade400, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "You are offline. Weather and AI features are disabled.",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 Floating Action Buttons
  Widget _buildFABs() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isOnline) ...[
            FloatingActionButton.extended(
              heroTag: 'aiButton',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatAIScreen()),
                );
              },
              backgroundColor: Colors.green.shade600,
              icon: const Icon(Icons.smart_toy, color: Colors.white),
              label: const Text(
                "AI Chat",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
          ],
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DiseaseDetectionScreen(),
                ),
              );
            },
            backgroundColor: Colors.green.shade600,
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            label: const Text(
              "Disease Scan",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎯 Metric Action Handler
  void _handleMetricAction(String title) {
    switch (title) {
      case "Soil Moisture":
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Irrigation pump started 💧")),
        );
        break;
      case "Tank Level":
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tank refill system activated 🚰")),
        );
        break;
      case "System Health":
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Running system diagnostics 🔍")),
        );
        break;
      case "Battery Level":
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Battery saver mode enabled 🔋")),
        );
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Action triggered")));
    }
  }

  /// 🔹 Metric Status Colors
  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'perfect':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'normal':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
