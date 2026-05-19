/// ───────────────────────────────────────────────────────────
///  MEDIA ITEM — Sistema unificado de archivos
/// ───────────────────────────────────────────────────────────
///  Soporta: imágenes, videos, documentos (PDF, DOC, etc.)
///  
///  📥 ESCRITURA: al crear un post/story, guardar:
///    "media": [{ "url": "...", "type": "image" }]
///    (el service createPost/createStory ya lo hace automáticamente)
///  
///  📤 LECTURA: MediaItem.fromFirestore() detecta:
///    - "media" (nuevo formato) 
///    - "imageUrls" / "imageUrl" (legacy, backward compat)
///  
///  🖥️ DISPLAY: usar MediaViewer o MediaGrid:
///    MediaGrid(items: post.media)
///    → 1 item: vista grande
///    → 2 items: lado a lado
///    → 3+ items: grid con badge +N
///  
///  🔧 SafeImage / SafeNetworkImage para casos simples:
///    SafeImage(imageUrl: url)  → fallback automático si URL vacía
/// ───────────────────────────────────────────────────────────
enum MediaType { image, video, document }

class MediaItem {
  final String url;
  final MediaType type;
  final String? thumbnailUrl;
  final String? name;
  final String? mimeType;
  final int? size;

  const MediaItem({
    required this.url,
    required this.type,
    this.thumbnailUrl,
    this.name,
    this.mimeType,
    this.size,
  });

  bool get isImage => type == MediaType.image;
  bool get isVideo => type == MediaType.video;
  bool get isDocument => type == MediaType.document;

  static MediaType detectType(String url, {String? mimeType}) {
    if (mimeType != null) {
      if (mimeType.startsWith('image/')) return MediaType.image;
      if (mimeType.startsWith('video/')) return MediaType.video;
      return MediaType.document;
    }
    final lower = url.toLowerCase();
    if (lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.avi') ||
        lower.endsWith('.mkv') || lower.endsWith('.webm') || lower.contains('youtube.com') ||
        lower.contains('youtu.be') || lower.contains('vimeo')) {
      return MediaType.video;
    }
    if (lower.endsWith('.pdf') || lower.endsWith('.doc') || lower.endsWith('.docx') ||
        lower.endsWith('.xls') || lower.endsWith('.xlsx') || lower.endsWith('.txt') ||
        lower.endsWith('.zip') || lower.endsWith('.rar')) {
      return MediaType.document;
    }
    return MediaType.image;
  }

  static String? extractThumbnail(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('youtube.com') || lower.contains('youtu.be')) {
      try {
        final uri = Uri.parse(url);
        String? videoId;
        if (lower.contains('youtu.be')) {
          videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
        } else {
          videoId = uri.queryParameters['v'];
        }
        if (videoId != null) return 'https://img.youtube.com/vi/$videoId/0.jpg';
      } catch (_) {}
    }
    return null;
  }

  Map<String, dynamic> toMap() => {
    'url': url,
    'type': type.name,
    if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    if (name != null) 'name': name,
    if (mimeType != null) 'mimeType': mimeType,
    if (size != null) 'size': size,
  };

  factory MediaItem.fromMap(Map<String, dynamic> map) => MediaItem(
    url: map['url'] as String? ?? '',
    type: MediaType.values.firstWhere(
      (e) => e.name == map['type'],
      orElse: () => MediaItem.detectType(map['url'] as String? ?? ''),
    ),
    thumbnailUrl: map['thumbnailUrl'] as String?,
    name: map['name'] as String?,
    mimeType: map['mimeType'] as String?,
    size: map['size'] as int?,
  );

  /// Crea un MediaItem desde una URL simple (detección automática de tipo)
  factory MediaItem.fromUrl(String url, {String? name}) => MediaItem(
    url: url,
    type: detectType(url),
    thumbnailUrl: extractThumbnail(url),
    name: name ?? url.split('/').last,
  );

  /// Convierte una lista legacy de URLs string a lista de MediaItem
  static List<MediaItem> fromLegacyUrls(List<String> urls) =>
      urls.map((u) => MediaItem.fromUrl(u)).toList();

  /// Convierte Firestore data mixta: puede venir 'media' (nuevo) o 'imageUrls' (legacy)
  static List<MediaItem> fromFirestore(Map<String, dynamic> data) {
    if (data['media'] is List) {
      return (data['media'] as List)
          .whereType<Map<String, dynamic>>()
          .map(MediaItem.fromMap)
          .toList();
    }
    // Legacy: imageUrls (List<String>)
    if (data['imageUrls'] is List) {
      return fromLegacyUrls(List<String>.from(data['imageUrls']));
    }
    // Legacy: imageUrl (String singular)
    if (data['imageUrl'] is String && (data['imageUrl'] as String).isNotEmpty) {
      return [MediaItem.fromUrl(data['imageUrl'] as String)];
    }
    return [];
  }
}
