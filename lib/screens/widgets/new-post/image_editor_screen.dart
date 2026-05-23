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

  static final vintage = FilterPreset('Vintage', [
    0.9, 0, 0, 0, 20,
    0, 0.85, 0, 0, 15,
    0, 0, 0.75, 0, 25,
    0, 0, 0, 1, 0,
  ]);

  static final warm = FilterPreset('Warm', [
    1.15, 0, 0, 0, 8,
    0, 1.0, 0, 0, 3,
    0, 0, 0.85, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  static final cool = FilterPreset('Cool', [
    0.9, 0, 0, 0, 0,
    0, 1.0, 0, 0, 2,
    0, 0, 1.15, 0, 8,
    0, 0, 0, 1, 0,
  ]);

  static final dramatic = FilterPreset('Dramatic', [
    1.3, 0, 0, 0, -10,
    0, 1.2, 0, 0, -8,
    0, 0, 1.1, 0, -5,
    0, 0, 0, 1, 0,
  ]);

  static final noir = FilterPreset('Noir', [
    0.6, 0, 0, 0, 5,
    0, 0.6, 0, 0, 5,
    0, 0, 0.6, 0, 5,
    0, 0, 0, 1, 0,
  ]);

  static final sepia = FilterPreset('Sepia', [
    0.393, 0.769, 0.189, 0, 10,
    0.349, 0.686, 0.168, 0, 5,
    0.272, 0.534, 0.131, 0, 3,
    0, 0, 0, 1, 0,
  ]);

  static final vibrant = FilterPreset('Vibrant', [
    1.25, 0, 0, 0, 0,
    0, 1.15, 0, 0, 0,
    0, 0, 1.3, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  static final faded = FilterPreset('Faded', [
    1.0, 0, 0, 0, 0,
    0, 0.95, 0, 0, 0,
    0, 0, 0.9, 0, 0,
    0, 0, 0, 0.85, 15,
  ]);

  static final List<FilterPreset> all = [
    original, clarendon, gingham, juno, lark,
    reyes, valencia, amaro, hudson, xpro2,
    lofi, inkwell, willow, nashville,
    vintage, warm, cool, dramatic, noir,
    sepia, vibrant, faded,
  ];
}

class TextOverlay {
  String text;
  Color color;
  double fontSize;
  Offset position;
  double rotation;
  bool isEditing;

  TextOverlay({
    this.text = 'Texto',
    this.color = Colors.white,
    this.fontSize = 24,
    this.position = const Offset(0, 0),
    this.rotation = 0,
    this.isEditing = false,
  });
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
  late AnimationController _filterAnimCtrl;

  double _brightness = 0;
  double _contrast = 1;
  double _saturation = 1;
  double _highlights = 0;
  double _shadows = 0;
  double _warmth = 0;
  double _vignette = 0;
  bool _saving = false;

  final List<TextOverlay> _textOverlays = [];
  final _textController = TextEditingController();
  Color _textColor = Colors.white;
  double _textFontSize = 24;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _filterAnimCtrl = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _filterAnimCtrl.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _changeFilter(FilterPreset filter) {
    if (_selectedFilter.name == filter.name) return;
    setState(() => _selectedFilter = filter);
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

    final h = _highlights * 0.3;
    final sh = _shadows * 0.2;

    return [
      (base[0] * c * (sr + s + h)) + (base[1] * c * sr) + (base[2] * c * sr), (base[0] * c * sg) + (base[1] * c * (sg + s + h)) + (base[2] * c * sg), (base[0] * c * sb) + (base[1] * c * sb) + (base[2] * c * (sb + s + h)), 0, base[4] * c + brightnessOffset + sh,
      (base[5] * c * (sr + s + h)) + (base[6] * c * sr) + (base[7] * c * sr), (base[5] * c * sg) + (base[6] * c * (sg + s + h)) + (base[7] * c * sg), (base[5] * c * sb) + (base[6] * c * sb) + (base[7] * c * (sb + s + h)), 0, base[9] * c + brightnessOffset + sh,
      (base[10] * c * (sr + s + h)) + (base[11] * c * sr) + (base[12] * c * sr), (base[10] * c * sg) + (base[11] * c * (sg + s + h)) + (base[12] * c * sg), (base[10] * c * sb) + (base[11] * c * sb) + (base[12] * c * (sb + s + h)), 0, base[14] * c + brightnessOffset + sh,
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

  void _removeTextOverlay(int index) {
    setState(() {
      _textOverlays.removeAt(index);
    });
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
              child: Stack(
                children: [
                  Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: ColorFiltered(
                        key: ValueKey('${_selectedFilter.name}_${_brightness}_${_contrast}_$_saturation'),
                        colorFilter: ColorFilter.matrix(_combinedMatrix),
                        child: InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 4,
                          child: Image.memory(widget.imageBytes, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  ),
                  if (_vignette > 0)
                    IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: _vignette),
                            ],
                            radius: 0.75,
                          ),
                        ),
                      ),
                    ),
                  ..._buildTextOverlayWidgets(),
                ],
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
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'Filtros'),
                    Tab(text: 'Ajustar'),
                    Tab(text: 'Texto'),
                    Tab(text: 'Recortar'),
                  ],
                ),
                SizedBox(
                  height: 200,
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _buildFiltersTab(),
                      _buildAdjustTab(),
                      _buildTextTab(),
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

  List<Widget> _buildTextOverlayWidgets() {
    return _textOverlays.asMap().entries.map((entry) {
      final i = entry.key;
      final overlay = entry.value;
      return Positioned(
        left: overlay.position.dx,
        top: overlay.position.dy,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _textOverlays[i] = TextOverlay(
                text: overlay.text,
                color: overlay.color,
                fontSize: overlay.fontSize,
                position: Offset(
                  overlay.position.dx + details.delta.dx,
                  overlay.position.dy + details.delta.dy,
                ),
                rotation: overlay.rotation,
              );
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              overlay.text,
              style: TextStyle(
                color: overlay.color,
                fontSize: overlay.fontSize,
                fontWeight: FontWeight.bold,
                shadows: const [
                  Shadow(blurRadius: 4, color: Colors.black54),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
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
            onTap: () => _changeFilter(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          _slider('Brillo', _brightness, -0.5, 0.5, (v) => setState(() => _brightness = v)),
          _slider('Contraste', _contrast, 0.5, 1.5, (v) => setState(() => _contrast = v)),
          _slider('Saturación', _saturation, 0, 2, (v) => setState(() => _saturation = v)),
          _slider('Luces', _highlights, -0.5, 0.5, (v) => setState(() => _highlights = v)),
          _slider('Sombras', _shadows, -0.5, 0.5, (v) => setState(() => _shadows = v)),
          _slider('Calidez', _warmth, -0.5, 0.5, (v) => setState(() => _warmth = v)),
          _slider('Viñeta', _vignette, 0, 0.6, (v) => setState(() => _vignette = v)),
        ],
      ),
    );
  }

  Widget _buildTextTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_textOverlays.isNotEmpty) ...[
            Expanded(
              child: ListView.builder(
                itemCount: _textOverlays.length,
                itemBuilder: (_, i) {
                  final o = _textOverlays[i];
                  return ListTile(
                    dense: true,
                    leading: Icon(Icons.text_fields, color: Colors.white70, size: 20),
                    title: Text(o.text, style: const TextStyle(color: Colors.white, fontSize: 14), maxLines: 1),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                      onPressed: () => _removeTextOverlay(i),
                    ),
                  );
                },
              ),
            ),
          ],
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Escribe tu texto...',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onSubmitted: (_) {
                    if (_textController.text.isNotEmpty) {
                      setState(() {
                        if (_textOverlays.isNotEmpty && _textOverlays.last.isEditing) {
                          _textOverlays.last.text = _textController.text;
                        } else {
                          _textOverlays.add(TextOverlay(text: _textController.text, color: _textColor, fontSize: _textFontSize));
                        }
                        _textController.clear();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue, size: 20),
                onPressed: () {
                  if (_textController.text.isNotEmpty) {
                    setState(() {
                      if (_textOverlays.isNotEmpty && _textOverlays.last.isEditing) {
                        _textOverlays.last.text = _textController.text;
                      } else {
                        _textOverlays.add(TextOverlay(text: _textController.text, color: _textColor, fontSize: _textFontSize));
                      }
                      _textController.clear();
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Color:', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(width: 8),
              ...['#FFFFFF', '#FF0000', '#00FF00', '#0000FF', '#FFFF00', '#FF00FF', '#00FFFF'].map((c) {
                final color = Color(int.parse(c.replaceFirst('#', '0xFF')));
                return GestureDetector(
                  onTap: () => setState(() => _textColor = color),
                  child: Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: _textColor == color ? Colors.white : Colors.transparent, width: 2),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _slider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
            style: const TextStyle(color: Colors.white54, fontSize: 11),
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
