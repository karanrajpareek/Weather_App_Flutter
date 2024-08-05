import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additonal_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;


class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  
 @override
  void initState(){
    super.initState();
    getCurrentWeather();
  }

  Future<Map<String,dynamic>> getCurrentWeather() async {

    try {
      String cityname = 'london';
    final res = await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityname,uk&APPID=2f5b0b1176966ab363198f97ac0f4893',
      ),
    );
    final data = jsonDecode(res.body);
    if (data['cod']!='200'){
      throw 'an error occurred';
    }
    
    return data;
    
       
    }
     catch (e) {
      throw e.toString();
    }
    
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title:const Text('Weather App',style: TextStyle(
          fontWeight: FontWeight.bold
                       ),
                        ),
        centerTitle: true,
        actions: [
            IconButton(
              onPressed: (){
                setState(() {
                  
                });
              },
             icon: const Icon(Icons.refresh),
            ) ,
        ],
      ), 
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context,snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child:  CircularProgressIndicator());
          }
          if(snapshot.hasError){
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;

          final currentWeatherData = data['list'][0];
          final currentTemp = (currentWeatherData['main']['temp']);
          final currentSky = (currentWeatherData['weather'][0]['main']);
          final currentPressure = (currentWeatherData['main']['pressure']);
          final currentWindSpeed = (currentWeatherData['wind']['speed']);
          final currentHumidity = (currentWeatherData['main']['humidity']);




          return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // maincard
            SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)
                  ),
                  
                child:ClipRRect(
                  borderRadius:BorderRadius.circular(16) ,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10,sigmaY: 10),
                    child:  Padding(
                      padding: const  EdgeInsets.all(16.0),
                      child: Column(children: [
                        Text('$currentTemp K',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                        ),
                       const  SizedBox(height: 16),
                         Icon(
                          currentSky=='Clouds' || currentSky=='Rain'?
                            Icons.cloud
                          : Icons.sunny,
                          size: 64
                          ),
                        const  SizedBox(height: 16),
                         Text('$currentSky',
                         style:const TextStyle(
                          fontSize: 20
                        ),
                        )
                      ],
                      ),
                    ),
                  ),
                ),
              ),
            ), 
            const SizedBox(height: 20),
            const Text('Weather Forecast', style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              ),

              SizedBox(
                height: 120,
                child: ListView.builder(
                  itemCount: 5,
                   scrollDirection: Axis.horizontal,
                   itemBuilder:(context , index){
                    final hourlyForecast = data['list'][index + 1];
                    final hourlySky = data['list'][index+1]['weather'][0]['main'];
                    final hourlyTemp = hourlyForecast['main']['temp'].toString();
                    final time =  DateTime.parse(hourlyForecast['dt_txt']);
                    return HourlyForecastItem(
                      time:DateFormat.j().format(time) , 
                      icon: hourlySky=='Clouds' || hourlySky=='Rain'?
                              Icons.cloud
                            : Icons.sunny,
                      temp: hourlyTemp
                      );
                   },
                   ),
              ),
            
          const SizedBox(height: 20),
            const Text('Additional Information',
                style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              ),
        
            const SizedBox(height: 16),
             Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                      AdditionalInfoItem(
                       icon: Icons.water_drop,
                        label: 'Humidity',
                        value: currentHumidity.toString(),
                      ),
                      AdditionalInfoItem(
                        icon: Icons.air,
                        label: 'Wind Speed',
                        value: currentWindSpeed.toString(),
                        
                      ),
                      AdditionalInfoItem(
                        icon: Icons.beach_access,
                        value: currentPressure.toString() ,
                        label:'Pressure',
                      ),
                  ],
                    ),
          
            ]
          ),
        );
        },
      ),
    );
  }
}



