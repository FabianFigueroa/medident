import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:medident/main_export.dart';

class SecurityTemperaturePage extends StatefulWidget {
  const SecurityTemperaturePage({Key? key}) : super(key: key);

  @override
  _SecurityTemperaturePageState createState() => _SecurityTemperaturePageState();
}

class _SecurityTemperaturePageState extends State<SecurityTemperaturePage> {
  double heating = 12;
  double fan = 15;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 18, left: 24, right: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //////////////////////////////////////// back
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.indigo,
                    ),
                  ),
                  ///////////////////////////////////////////////
                  const RotatedBox(
                    quarterTurns: 135,
                    child: Icon(
                      Icons.bar_chart_rounded,
                      color: Colors.indigo,
                      size: 28,
                    ),
                  )
                ],
              ),
              ///////////////////////////////////////////// list
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 20),
                    CircularPercentIndicator(
                      radius: 150,
                      lineWidth: 12,
                      percent: 0.75,
                      progressColor: Colors.indigo,
                      center: const Text(
                        '26\u00B0',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Center(
                      child: Text(
                        'TEMPERATURA',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ),
                    // const SizedBox(height: 32),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     _roundedButton(title: 'GENERAL', isActive: true),
                    //     _roundedButton(title: 'SERVICES'),
                    //   ],
                    // ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Aire acondicionado :',
                              style: TextStyle(
                                color: AppColors.grey800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Slider(
                            value: heating,
                            onChanged: (newHeating) {
                              setState(() => heating = newHeating);
                            },
                            max: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text('0\u00B0'),
                                Text('15\u00B0'),
                                Text('30\u00B0'),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ///////////////////////////////////////// slide 2
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Ventiladores:',
                              style: TextStyle(
                                color: AppColors.grey800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Slider(
                            value: fan,
                            onChanged: (newFan) {
                              setState(() => fan = newFan);
                            },
                            max: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text('Bajo'),
                                Text('Medio'),
                                Text('Alto'),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    /////////
                    const SizedBox(height: 22),
                    //////////////////////////////////////////
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _fan(title: 'Ventilador 1', isActive: true),
                        _fan(title: 'Ventilador 2', isActive: true),
                        _fan(title: 'Ventilador 3'),
                        _fan(title: 'Ventilador 4', isActive: true),
                        _fan(title: 'Ventilador 5'),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

///////////////////////////////////////////////////////////////// fans
  Widget _fan({
    required String title,
    bool isActive = false,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isActive ? AppColors.purpleColor : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset(
            width: 40,
            height: 40,
            isActive ? 'assets/icons/setting.png' : 'assets/icons/wifi.png',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.black87 : Colors.black54,
          ),
        ),
      ],
    );
  }

  
}
