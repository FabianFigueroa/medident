import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:medident/screens/widgets/new-post/image_editor_screen.dart';

class VideoEditorResult {
  final double startTime;
  final double endTime;
  final double speed;
  final String? filterName;
  final String? textOverlay;

  VideoEditorResult({
    required this.startTime,
    required this.endTime,
    this.speed = 1.0,
    this.filterName,
    this.textOverlay,
  });
}

class VideoEditorScreen extends StatefulWidget {
  final String videoPath;
  final String? thumbnailPath;

  const VideoEditorScreen({
    super.key,
    required this.videoPath,
    this.thumbnailPath,
  });

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  late TabController _tabCtrl;
  bool _isInitialized = false;
  bool _isPlaying = false;

  double _startTrim = 0;
  double _endTrim = 0;
  double _currentPosition = 0;
  double _speed = 1.0;
  FilterPreset _selectedFilter = FilterPreset.original;
  String? _textOverlay;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _controller = VideoPlayerController.file(
      File(widget.videoPath),
    );
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
        _endTrim = _controller.value.duration.inMilliseconds / 1000;
      });
      _controller.addListener(_onVideoUpdate);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoUpdate);
    _controller.dispose();
    _tabCtrl.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onVideoUpdate() {
    if (!mounted) return;
    setState(() {
      _currentPosition = _controller.value.position.inMilliseconds / 1000;
      _isPlaying = _controller.value.isPlaying;
    });
    if (_currentPosition >= _endTrim) {
      _controller.pause();
    }
  }

  void _togglePlay() {
    if (_isPlaying) {
      _controller.pause();
    } else {
      _controller.seekTo(Duration(milliseconds: (_startTrim * 1000).round()));
      _controller.play();
    }
  }

  void _seekTo(double seconds) {
    _controller.seekTo(Duration(milliseconds: (seconds * 1000).round()));
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
        title: const Text('Editar video', style: TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, VideoEditorResult(
                startTime: _startTrim,
                endTime: _endTrim,
                speed: _speed,
                filterName: _selectedFilter.name == 'Normal' ? null : _selectedFilter.name,
                textOverlay: _textOverlay,
              ));
            },
            child: const Text('Aplicar', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 15)),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isInitialized) ...[
            Expanded(
              child: Center(
                child: ColorFiltered(
                  colorFilter: ColorFilter.matrix(_selectedFilter.matrix),
                  child: GestureDetector(
                    onTap: _togglePlay,
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          VideoPlayer(_controller),
                          if (!_isPlaying)
                            const Icon(Icons.play_circle, color: Colors.white70, size: 64),
                          if (_textOverlay != null)
                            Positioned(
                              bottom: 40,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _textOverlay!,
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _buildTrimBar(),
            const SizedBox(height: 8),
            _buildPlaybackControls(),
          ] else
            const Expanded(
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
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
                    Tab(text: 'Velocidad'),
                    Tab(text: 'Texto'),
                  ],
                ),
                SizedBox(
                  height: 160,
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _buildFiltersTab(),
                      _buildSpeedTab(),
                      _buildTextTab(),
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

  Widget _buildTrimBar() {
    final totalDuration = _controller.value.duration.inMilliseconds / 1000;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black87,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatTime(_startTrim), style: const TextStyle(color: Colors.white70, fontSize: 11)),
              Text(_formatTime(_endTrim), style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
          RangeSlider(
            values: RangeValues(_startTrim, _endTrim),
            min: 0,
            max: totalDuration,
            divisions: totalDuration.round(),
            activeColor: Colors.blue,
            inactiveColor: Colors.grey[700],
            onChanged: (values) {
              setState(() {
                _startTrim = values.start;
                _endTrim = values.end;
              });
              _seekTo(_startTrim);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Colors.black87,
      child: Row(
        children: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 28),
            onPressed: _togglePlay,
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Colors.blue,
                inactiveTrackColor: Colors.grey[700],
                thumbColor: Colors.white,
                trackHeight: 3,
              ),
              child: Slider(
                value: _currentPosition.clamp(_startTrim, _endTrim),
                min: _startTrim,
                max: _endTrim,
                onChanged: (v) {
                  _seekTo(v);
                  setState(() => _currentPosition = v);
                },
              ),
            ),
          ),
          Text(
            '${_formatTime(_currentPosition)} / ${_formatTime(_endTrim)}',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
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
                      color: Colors.grey[900],
                      border: Border.all(
                        color: selected ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: ColorFiltered(
                        colorFilter: ColorFilter.matrix(f.matrix),
                        child: Icon(Icons.movie, color: Colors.grey[300], size: 32),
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

  Widget _buildSpeedTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Text('Velocidad: ${_speed}x', style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.blue,
              inactiveTrackColor: Colors.grey[800],
              thumbColor: Colors.white,
              trackHeight: 3,
            ),
            child: Slider(
              value: _speed,
              min: 0.25,
              max: 4,
              divisions: 15,
              onChanged: (v) {
                setState(() {
                  _speed = v;
                });
                _controller.setPlaybackSpeed(v);
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _speedChip(0.25, '0.25x'),
              _speedChip(0.5, '0.5x'),
              _speedChip(1, '1x'),
              _speedChip(2, '2x'),
              _speedChip(4, '4x'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _speedChip(double speed, String label) {
    final selected = _speed == speed;
    return GestureDetector(
      onTap: () {
        setState(() => _speed = speed);
        _controller.setPlaybackSpeed(speed);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.grey[800],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTextTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Texto sobre el video...',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.check, color: Colors.blue, size: 20),
                onPressed: () {
                  setState(() {
                    _textOverlay = _textController.text.isNotEmpty ? _textController.text : null;
                  });
                },
              ),
              if (_textOverlay != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () {
                    setState(() {
                      _textOverlay = null;
                      _textController.clear();
                    });
                  },
                ),
            ],
          ),
          if (_textOverlay != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _textOverlay!,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(double seconds) {
    final dur = Duration(milliseconds: (seconds * 1000).round());
    final min = dur.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = dur.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }
}
