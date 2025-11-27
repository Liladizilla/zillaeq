import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'services/preset_store.dart';
import 'services/equalizer_engine.dart';
import 'services/app_globals.dart';
import 'widgets/knob.dart';
import 'widgets/app_logo.dart';
import 'widgets/waveform.dart';
import 'screens/preset_list.dart';
import 'screens/settings.dart';

void main() {
  runApp(const EqualizerApp());
}


class EqualizerApp extends StatelessWidget {
  const EqualizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Adizilla Equalizer',
      theme: base.copyWith(
        scaffoldBackgroundColor: const Color(0xFF050D1F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        textTheme: base.textTheme.apply(
          bodyColor: Colors.blue[100],
          fontFamily: 'RobotoMono',
        ),
        colorScheme: base.colorScheme.copyWith(
          primary: Colors.cyanAccent,
          secondary: Colors.blueAccent,
        ),
      ),
      home: const EqualizerHome(),
    );
  }
}

// PresetListPage is implemented in `lib/screens/preset_list.dart` and imported above.

class EqualizerHome extends StatefulWidget {
  const EqualizerHome({super.key});

  @override
  State<EqualizerHome> createState() => _EqualizerHomeState();
}

class _EqualizerHomeState extends State<EqualizerHome> with SingleTickerProviderStateMixin {
  final List<double> frequencies = [60, 230, 910, 3600, 14000];
  late List<double> levels;
  double _amplitude = 0.0;

  late final AudioPlayer _player;
  late final EqualizerEngine _engine;
  PresetStore? _store;
  String? currentSongName;
  String? filePath;
  bool isPlaying = false;

  bool isLoading = true;
  late final AnimationController _bgController;
  bool _bgEnabled = true;
  bool _lowPower = false;

  @override
  void initState() {
    super.initState();
    levels = List<double>.filled(frequencies.length, 0.0);
    _player = AudioPlayer();
  _engine = EqualizerEngine(_player);
  _engine.setSampleRate(44100.0);
  // default, will be replaced once store loads
  _bgEnabled = true;
  _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    _initStore();
  }

  Future<void> _initStore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _store = PresetStore(prefs);
      final loaded = _store!.loadCurrent(frequencies.length);
      final bg = _store!.loadBgEnabled();
      if (!mounted) return;
      setState(() {
        levels = loaded;
        isLoading = false;
  _bgEnabled = bg;
  _lowPower = _store?.loadLowPower() ?? false;
      });
      _engine.applyBands(levels);
      if (!_bgEnabled) {
        _bgController.stop();
      }
    } catch (e) {
      debugPrint("Error initializing store: $e");
    }
  }
  Future<void> _pickAudioFile() async {
    final ok = await _requestStoragePermission();
    if (!ok) return;

    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null && result.files.single.path != null) {
      filePath = result.files.single.path!;
      currentSongName = result.files.single.name;

        try {
          // capture messenger before awaiting to avoid using context across async gaps
          final messenger = ScaffoldMessenger.of(context);
          await _player.setFilePath(filePath!);
          await _player.play();
          if (!mounted) return;
          setState(() {
            isPlaying = true;
          });
          messenger.showSnackBar(SnackBar(content: Text('Playing: ${result.files.single.name}')));
        } catch (e) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
        }
    } else {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(const SnackBar(content: Text('No file selected')));
    }
  }

  Future<bool> _requestStoragePermission() async {
    try {
  final messenger = ScaffoldMessenger.of(context);
  final status = await Permission.storage.request();
  if (status.isGranted) return true;
  messenger.showSnackBar(const SnackBar(content: Text('Storage permission is required to load local files')));
      return false;
    } catch (e) {
      debugPrint('Permission request error: $e');
      return false;
    }
  }

  @override
  void dispose() {
  _bgController.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _playSample() async {
    try {
  final _ = ScaffoldMessenger.of(context);
  await _player.setUrl('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
  await _player.play();
    } catch (e) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(SnackBar(content: Text('Error playing sample: $e')));
    }
  }
  Future<void> requestPermissions() async {
  await [
    Permission.storage,
    Permission.microphone,
  ].request();
}

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF050D1F),
        body: Center(
          child: CircularProgressIndicator(color: Colors.cyanAccent),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚡ Adizilla Equalizer'),
        actions: [
            IconButton(
              icon: Icon(_bgEnabled ? Icons.blur_on : Icons.blur_off, color: Colors.cyanAccent),
              onPressed: () async {
                setState(() {
                  _bgEnabled = !_bgEnabled;
                  if (_bgEnabled) {
                    _bgController.repeat();
                  } else {
                    _bgController.stop();
                  }
                });
                await _store?.saveBgEnabled(_bgEnabled);
              },
            ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.cyanAccent),
            onPressed: () {
              if (_store == null) return;
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingsPage(store: _store!)));
            },
          ),
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SizedBox(width: 8),
                Text('ZILLAEQ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color.fromARGB(255, 88, 158, 158))),
                Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            const Align(alignment: Alignment.centerRight, child: AppLogo(size: 40)),
            const SizedBox(height: 12),
            _buildPresetRow(),
            const SizedBox(height: 20),
            Expanded(child: _buildKnobPanel()),
            const SizedBox(height: 20),
            Waveform(amplitude: _amplitude, bars: 28, color: Colors.cyanAccent, rmsStream: _engine.rmsStream),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _neonButton("Presets", Colors.purpleAccent, () {
                  if (_store == null) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PresetListPage(
                        store: _store!,
                        onLoad: (values) async {
                          setState(() => levels = values);
                          _engine.applyBands(levels);
                          await _store?.saveCurrent(values);
                        },
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 12),
                _neonButton("📁 Load File", Colors.amberAccent, _pickAudioFile),
              ],
            ),

            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _neonButton("💾 Save", Colors.cyanAccent, () async {
          final name = 'Preset ${DateTime.now().toIso8601String()}';
          final messenger = ScaffoldMessenger.of(context);
          await _store?.savePreset(name, levels);
          messenger.showSnackBar(
            const SnackBar(content: Text('Preset saved successfully!')),
          );
        }),
        _neonButton("🔁 Reset", Colors.redAccent, () async {
          setState(() {
            levels = List<double>.filled(frequencies.length, 0.0);
          });
          _engine.applyBands(levels);
          await _store?.saveCurrent(levels);
        }),
        _neonButton("▶️ Play", Colors.greenAccent, _playSample),
      ],
    );
  }

  Widget _buildKnobPanel() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF061322), Color(0xFF0D2137)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withAlpha((0.3 * 255).round()),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: Stack(
        children: [
          // animated subtle background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _bgController.value * 2 * 3.14159,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [Colors.cyanAccent.withAlpha(18), Colors.transparent],
                        center: Alignment(-0.6, -0.4),
                        radius: 0.9,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // knobs row
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(frequencies.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: LayoutBuilder(builder: (ctx, cons) {
                        final width = MediaQuery.of(context).size.width;
                        final knobSize = (width / (frequencies.length + 1)).clamp(64.0, 120.0);
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Knob(
                              size: knobSize,
                              min: -12,
                              max: 12,
                              value: levels[i],
                              color: Colors.cyanAccent,
                              glow: !_lowPower,
                              onChanged: (v) async {
                                setState(() {
                                  levels[i] = v;
                                  // update amplitude visual: map average absolute dB to 0..1
                                  final avgDb = levels.map((e) => e.abs()).fold<double>(0.0, (a, b) => a + b) / levels.length;
                                  _amplitude = (avgDb / 18.0).clamp(0.0, 1.0);
                                });
                                _engine.applyBands(levels);
                                await _store?.saveCurrent(levels);
                              },
                            ),
                            const SizedBox(height: 8),
                            // numeric readout
                            Text(
                              '${levels[i].toStringAsFixed(1)} dB',
                              style: TextStyle(color: Colors.cyanAccent.withAlpha((0.95 * 255).round()), fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${frequencies[i].toInt()} Hz',
                              style: TextStyle(color: Colors.cyanAccent.withAlpha((0.85 * 255).round()), fontWeight: FontWeight.w600),
                            ),
                          ],
                        );
                      }),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
Widget _buildFooter() {
  return Column(
    children: [
      const SizedBox(height: 12),
      if (currentSongName != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1D2E),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.3 * 255).round()),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  currentSongName!,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 131, 128, 128),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: Colors.blueAccent,
                      size: 34,
                    ),
                    onPressed: () async {
                      if (isPlaying) {
                        await _player.pause();
                      } else {
                        await _player.play();
                      }
                      setState(() {
                        isPlaying = !isPlaying;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.stop_circle,
                      color: Colors.redAccent,
                      size: 30,
                    ),
                    onPressed: () async {
                      await _player.stop();
                      setState(() {
                        isPlaying = false;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      const SizedBox(height: 12),
      Text(
        'Dark Futuristic Equalizer',
  style: TextStyle(color: Colors.blueGrey[200]),
      ),
    ],
  );
}
  Widget _neonButton(String label, Color color, Function? handler) {
    return ElevatedButton(
      onPressed: handler == null
          ? null
          : () {
              try {
                final messenger = ScaffoldMessenger.of(context);
                final r = handler();
                if (r is Future) {
                  r.catchError((e) => messenger.showSnackBar(SnackBar(content: Text('Error: $e'))));
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
      style: ElevatedButton.styleFrom(
  backgroundColor: Colors.black.withAlpha((0.6 * 255).round()),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 6,
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class knobWidget {
  const knobWidget();
}