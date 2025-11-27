import 'package:flutter/material.dart';
import 'package:equalizer_app/services/preset_store.dart';

class PresetListPage extends StatefulWidget {
  final PresetStore store;
  final void Function(List<double> values) onLoad;

  const PresetListPage({super.key, required this.store, required this.onLoad});

  @override
  State<PresetListPage> createState() => _PresetListPageState();
}

class _PresetListPageState extends State<PresetListPage> {
  late List<String> _names;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final names = await widget.store.getPresetNames();
    if (!mounted) return;
    setState(() {
      _names = names;
      _loading = false;
    });
  }

  Future<void> _delete(String name) async {
    await widget.store.deletePreset(name);
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted $name')),
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF050D1F),
        body: Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF050D1F),
      appBar: AppBar(title: const Text('🎚️ Presets')),
      body: ListView.builder(
        itemCount: _names.length,
        itemBuilder: (context, i) {
          final name = _names[i];
          return Card(
            color: const Color(0xFF0D2137),
            child: ListTile(
              title: Text(name, style: const TextStyle(color: Colors.cyanAccent)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _delete(name),
              ),
              onTap: () async {
                final values = await widget.store.loadPreset(name);
                widget.onLoad(values);
                // ignore: use_build_context_synchronously
                if (mounted) Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }
}
