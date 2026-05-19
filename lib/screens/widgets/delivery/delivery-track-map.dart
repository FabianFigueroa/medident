import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:medident/core/config/maps-config.dart';
import 'package:medident/core/models/delivery/delivery-model.dart';
import 'package:medident/core/models/delivery/delivery-track-model.dart';

class DeliveryTrackMap extends StatefulWidget {
  final DeliveryModel delivery;
  final DeliveryTrack? track;
  final double vehicleSize;

  const DeliveryTrackMap({
    super.key,
    required this.delivery,
    this.track,
    this.vehicleSize = 40,
  });

  @override
  State<DeliveryTrackMap> createState() => _DeliveryTrackMapState();
}

class _DeliveryTrackMapState extends State<DeliveryTrackMap>
    with TickerProviderStateMixin {
  final MapController _mapCtrl = MapController();
  late AnimationController _moveCtrl;
  Animation<LatLng>? _moveAnim;
  LatLng? _animatedPos;
  double _vehicleRotation = 0;

  @override
  void initState() {
    super.initState();
    _moveCtrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..addListener(_onMoveTick);
  }

  @override
  void didUpdateWidget(DeliveryTrackMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.track != oldWidget.track && widget.track != null) {
      _onTrackUpdate(widget.track!);
    }
  }

  void _onTrackUpdate(DeliveryTrack track) {
    if (track.route.isEmpty) return;
    if (track.currentIndex < track.route.length - 1) {
      _animateToIndex(track, track.currentIndex);
    } else if (track.currentLocation != null) {
      setState(() {
        _animatedPos = LatLng(
          track.currentLocation!.latitude,
          track.currentLocation!.longitude,
        );
      });
      _fitMarkers();
    }
  }

  void _animateToIndex(DeliveryTrack track, int fromIndex) {
    if (fromIndex >= track.route.length - 1) return;

    final from = track.route[fromIndex];
    final to = track.route[fromIndex + 1];

    final fromLatLng = LatLng(from.latitude, from.longitude);
    final toLatLng = LatLng(to.latitude, to.longitude);

    _vehicleRotation = _calcBearing(fromLatLng, toLatLng);

    setState(() {
      _animatedPos = fromLatLng;
    });

    _moveCtrl.duration = Duration(
      milliseconds: (from.timestamp.difference(to.timestamp).abs().inMilliseconds)
          .clamp(500, 5000),
    );
    _moveCtrl.reset();

    final anim = _createMoveAnimation(fromLatLng, toLatLng);
    _moveAnim = anim;
    _moveCtrl.forward();
  }

  Animation<LatLng> _createMoveAnimation(LatLng from, LatLng to) {
    return LatLngTween(begin: from, end: to).animate(
      CurvedAnimation(parent: _moveCtrl, curve: Curves.easeInOut),
    );
  }

  void _onMoveTick() {
    if (_moveAnim == null) return;
    setState(() {
      _animatedPos = _moveAnim!.value;
    });
  }

  double _calcBearing(LatLng from, LatLng to) {
    final dLon = (to.longitude - from.longitude) * math.pi / 180;
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    return (math.atan2(y, x) * 180 / math.pi).toDouble();
  }

  void _fitMarkers() {
    final bounds = _buildBounds();
    if (bounds != null) {
      _mapCtrl.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(80),
        ),
      );
    }
  }

  LatLngBounds? _buildBounds() {
    final points = <LatLng>[
      LatLng(widget.delivery.originLocation.latitude, widget.delivery.originLocation.longitude),
      LatLng(widget.delivery.destinationLocation.latitude, widget.delivery.destinationLocation.longitude),
    ];
    if (_animatedPos != null) points.add(_animatedPos!);
    if (points.isEmpty) return null;

    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  List<Polyline> _buildPolylines() {
    if (widget.track?.route.isEmpty ?? true) return [];
    return [
      Polyline(
        points: widget.track!.route.map((p) => LatLng(p.latitude, p.longitude)).toList(),
        color: const Color(0xFF1565C0),
        strokeWidth: 4,
      ),
    ];
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    markers.add(Marker(
      point: LatLng(
        widget.delivery.originLocation.latitude,
        widget.delivery.originLocation.longitude,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('Origen', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
          ),
          const Icon(Icons.location_on, color: Colors.green, size: 36),
        ],
      ),
    ));

    markers.add(Marker(
      point: LatLng(
        widget.delivery.destinationLocation.latitude,
        widget.delivery.destinationLocation.longitude,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.delivery.patientName.length > 10
                  ? '${widget.delivery.patientName.substring(0, 10)}...'
                  : widget.delivery.patientName,
              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.location_on, color: Colors.red, size: 36),
        ],
      ),
    ));

    if (_animatedPos != null) {
      markers.add(Marker(
        point: _animatedPos!,
        child: Transform.rotate(
          angle: _vehicleRotation * math.pi / 180,
          child: Icon(
            Icons.directions_car_rounded,
            color: const Color(0xFF1565C0),
            size: widget.vehicleSize,
          ),
        ),
      ));
    }

    return markers;
  }

  @override
  void dispose() {
    _moveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final origin = widget.delivery.originLocation;
    final dest = widget.delivery.destinationLocation;

    return FlutterMap(
      mapController: _mapCtrl,
      options: MapOptions(
        initialCenter: LatLng(
          (origin.latitude + dest.latitude) / 2,
          (origin.longitude + dest.longitude) / 2,
        ),
        initialZoom: MapsConfig.defaultZoom,
        onMapReady: () {
          _fitMarkers();
          if (widget.track != null) _onTrackUpdate(widget.track!);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: MapsConfig.tileUrl,
          userAgentPackageName: 'com.medident.app',
        ),
        PolylineLayer(polylines: _buildPolylines()),
        MarkerLayer(markers: _buildMarkers()),
      ],
    );
  }
}

class LatLngTween extends Tween<LatLng> {
  LatLngTween({LatLng? begin, LatLng? end}) : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) => LatLng(
    begin!.latitude + (end!.latitude - begin!.latitude) * t,
    begin!.longitude + (end!.longitude - begin!.longitude) * t,
  );
}
