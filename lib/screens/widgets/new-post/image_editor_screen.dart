import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_cropper/image_cropper.dart';

class FilterPreset {
  final String name;
  final List<double> matrix;

  const FilterPreset(this.name, this.matrix);

  static const List<double> _identity = [
    1.0, 0.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 1.0, 0.0,
  ];

  static final original = FilterPreset('Normal', _identity);

  static final clarendon = FilterPreset('Clarendon', [
    1.2, 0, 0, 0, 0,
    0, 1.1, 0, 0, 0,
    0, 0, 1.0, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  static final gingham = FilterPreset('Gingham', [
    1.0, 0, 0, 0, 10,
    0, 0.95, 0, 0, 5,
    0, 0, 0.9, 0, 15,
    0, 0, 0, 1, 0,
  ]);

  static final juno = FilterPreset('Juno', [
    1.1, 0, 0, 0, 5,
    0, 1.0, 0, 0, 0,
    0, 0, 0.9, 0, 10,
    0, 0, 0, 1, 0,
  ]);

  static final lark = FilterPreset('Lark', [
    1.1, 0, 0, 0, 0,
    0, 1.05, 0, 0, 0,
    0, 0, 1.2, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  static final reyes = FilterPreset('Reyes', [
    0.9, 0, 0, 0, 15,
    0, 0.85, 0, 0, 10,
    0, 0, 0.8, 0, 20,
    0, 0, 0, 1, 0,
  ]);

  static final valencia = FilterPreset('Valencia', [
    1.1, 0, 0, 0, 5,
    0, 1.0, 0, 0, 0,
    0, 0, 0.85, 0, 10,
    0, 0, 0, 1, 0,
  ]);

  static final amaro = FilterPreset('Amaro', [
    1.2, 0, 0, 0, 0,
    0, 1.1, 0, 0, 5,
    0, 0, 1.0, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  static final hudson = FilterPreset('Hudson', [
    1.1, 0, 0, 0, 0,
    0, 1.0, 0, 0, 5,
    0, 0, 0.9, 0, 15,
    0, 0, 0, 1, 0,
  ]);

  static final xpro2 = FilterPreset('X-Pro II', [
    1.2, 0, 0, 0, 0,
    0, 1.1, 0, 0, 0,
    0, 0, 0.8, 0, 20,
    0, 0, 0, 1, 0,
  ]);

  static final lofi = FilterPreset('Lo-Fi', [
    1.3, 0, 0, 0, 0,
    0, 1.2, 0, 0, 0,
    0, 0, 1.1, 0, 0,
    0, 0, 0, 1, 5,
  ]);

  static final inkwell = FilterPreset('Inkwell', [
    0, 1, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  static final willow = FilterPreset('Willow', [
    0.9, 0, 0, 0, 10,
    0, 0.9, 0, 0, 10,
    0, 0, 0.9, 0, 10,
    0, 0, 0, 1, 0,
  ]);

  static final nashville = FilterPreset('Nashville', [
    1.1, 0, 0, 0, 5,
    0, 0.95, 0, 0, 5,
    0, 0, 0.85, 0, 15,
    0, 0, 0, 1, 0,
  ]);

  static final List<FilterPreset> all = [
    original, clarendon, gingham, juno, lark,
    reyes, valencia, amaro, hudson, xpro2,
    lofi, inkwell, willow, nashville,
  ];
}

class ImageEditorScreen extends StatefulWidget {
  final Uint8List imageBytes;

  const ImageEditorScreen({super.key, required this.imageBytes});

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _repaintKey = GlobalKey();

  FilterPreset _selectedFilter = FilterPreset.original;
  double _brightness = 0;
  double _contrast = 1;
  double _saturation = 1;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<double> get _combinedMatrix {
    final b = _brightness;
    final c = _contrast;
    final s = _saturation;

    final sr = (1 - s) * 0.2126;
    final sg = (1 - s) * 0.7152;
    final sb = (1 - s) * 0.0722;

    final brightnessOffset = b * 255;

    final base = _selectedFilter.matrix;

    return [
      (base[0] * c * (sr + s)) + (base[1] * c * sr) + (base[2] * c * sr), (base[0] * c * sg) + (base[1] * c * (sg + s)) + (base[2] * c * sg), (base[0] * c * sb) + (base[1] * c * sb) + (base[2] * c * (sb + s)), 0, base[4] * c + brightnessOffset,
      (base[5] * c * (sr + s)) + (base[6] * c * sr) + (base[7] * c * sr), (base[5] * c * sg) + (base[6] * c * (sg + s)) + (base[7] * c * sg), (base[5] * c * sb) + (base[6] * c * sb) + (base[7] * c * (sb + s)), 0, base[9] * c + brightnessOffset,
      (base[10] * c * (sr + s)) + (base[11] * c * sr) + (base[12] * c * sr), (base[10] * c * sg) + (base[11] * c * (sg + s)) + (base[12] * c * sg), (base[10] * c * sb) + (base[11] * c * sb) + (base[12] * c * (sb + s)), 0, base[14] * c + brightnessOffset,
      0, 0, 0, 1, 0,
    ];
  }

  Future<void> _apply() async {
    setState(() => _saving = true);
    try {
      final boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null && mounted) {
        Navigator.pop(context, byteData.buffer.asUint8List());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _crop() async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: widget.imageBytes as String? ?? '',
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recortar',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Recortar'),
      ],
    );
    if (cropped != null && mounted) {
      final bytes = await cropped.readAsBytes();
      Navigator.pop(context, bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Editar imagen', style: TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          TextButton(
            onPressed: _saving ? null : _apply,
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Aplicar', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 15)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _repaintKey,
              child: Center(
                child: ColorFiltered(
                  colorFilter: ColorFilter.matrix(_combinedMatrix),
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4,
                    child: Image.memory(widget.imageBytes, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: const Color(0xFF1C1C1E),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TabBar(
                  controller: _tabCtrl,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'Filtros'),
                    Tab(text: 'Ajustar'),
                    Tab(text: 'Recortar'),
                  ],
                ),
                SizedBox(
                  height: 180,
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _buildFiltersTab(),
                      _buildAdjustTab(),
                      _buildCropTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: FilterPreset.all.length,
        itemBuilder: (_, i) {
          final f = FilterPreset.all[i];
          final selected = _selectedFilter.name == f.name;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = f),
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.matrix(f.matrix),
                        child: Image.memory(widget.imageBytes, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    f.name,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.grey[400],
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdjustTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          _slider('Brillo', _brightness, -0.5, 0.5, (v) => setState(() => _brightness = v)),
          const SizedBox(height: 8),
          _slider('Contraste', _contrast, 0.5, 1.5, (v) => setState(() => _contrast = v)),
          const SizedBox(height: 8),
          _slider('Saturación', _saturation, 0, 2, (v) => setState(() => _saturation = v)),
        ],
      ),
    );
  }

  Widget _slider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.blue,
              inactiveTrackColor: Colors.grey[800],
              thumbColor: Colors.white,
              overlayColor: Colors.blue.withOpacity(0.1),
              trackHeight: 3,
            ),
            child: Slider(value: value, min: min, max: max, onChanged: onChanged),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            value.toStringAsFixed(1),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildCropTab() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.crop, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text('Ajusta el recorte de tu imagen', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _crop,
            icon: const Icon(Icons.crop, size: 18),
            label: const Text('Abrir recortador'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
