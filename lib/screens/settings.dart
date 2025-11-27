import 'package:flutter/material.dart';
import 'package:equalizer_app/services/preset_store.dart';
import 'package:equalizer_app/services/debouncer.dart';

class SettingsPage extends StatefulWidget {
  final PresetStore store;
  const SettingsPage({super.key, required this.store});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _bgEnabled;
  late bool _lowPower;
  final _deb = Debouncer(const Duration(milliseconds: 600));

  @override
  void initState() {
    super.initState();
    _bgEnabled = widget.store.loadBgEnabled();
    _lowPower = widget.store.loadLowPower();
  }

  @override
  void dispose() {
    _deb.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          SwitchListTile(
            value: _bgEnabled,
            title: const Text('Animated background'),
            onChanged: (v) {
              setState(() => _bgEnabled = v);
              _deb.run(() => widget.store.saveBgEnabled(v));
            },
          ),
          SwitchListTile(
            value: _lowPower,
            title: const Text('Low power mode'),
            subtitle: const Text('Disables animations and reduces update rates'),
            onChanged: (v) {
              setState(() => _lowPower = v);
              _deb.run(() => widget.store.saveLowPower(v));
            },
          ),
        ],
      ),
    );
  }
}
