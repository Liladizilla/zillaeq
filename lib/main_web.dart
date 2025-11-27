import 'package:flutter/material.dart';

void main() {
  runApp(const EqualizerWebApp());
}

class EqualizerWebApp extends StatelessWidget {
  const EqualizerWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Adizilla Equalizer',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF050D1F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.blue[100],
        ),
      ),
      home: const WebEqualizerHome(),
    );
  }
}

class WebEqualizerHome extends StatefulWidget {
  const WebEqualizerHome({super.key});

  @override
  State<WebEqualizerHome> createState() => _WebEqualizerHomeState();
}

class _WebEqualizerHomeState extends State<WebEqualizerHome> {
  final List<double> frequencies = [60, 230, 910, 3600, 14000];
  late List<double> levels;

  @override
  void initState() {
    super.initState();
    levels = List<double>.filled(frequencies.length, 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚡ Adizilla Equalizer (Web Demo)'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'ZILLAEQ',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
            ),
            const SizedBox(height: 20),
            const Text(
              '5-Band Equalizer',
              style: TextStyle(fontSize: 18, color: Colors.blueAccent),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: List.generate(frequencies.length, (i) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${frequencies[i].toInt()} Hz',
                      style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 150,
                      width: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Slider(
                            value: levels[i],
                            min: -12,
                            max: 12,
                            divisions: 24,
                            label: '${levels[i].toStringAsFixed(1)} dB',
                            onChanged: (val) {
                              setState(() {
                                levels[i] = val;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${levels[i].toStringAsFixed(1)} dB',
                            style: TextStyle(color: Colors.cyanAccent.withAlpha((0.8 * 255).round())),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      levels = List<double>.filled(frequencies.length, 0.0);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Preset saved! (Web demo mode)')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                  ),
                  child: const Text('Save Preset'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1D2E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Web Demo Mode\nFull features available on mobile APK:\n• Real audio file playback\n• Actual DSP processing\n• Preset persistence\n• Low-power mode',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blueGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
