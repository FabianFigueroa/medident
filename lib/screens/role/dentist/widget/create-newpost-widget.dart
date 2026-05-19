import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/core/models/roles/user_role.dart';
import 'package:medident/core/providers/dentist/dentist-home-provider.dart';

class CreateNewPostWidget extends StatefulWidget {
  final UserModel currentUser;

  const CreateNewPostWidget({super.key, required this.currentUser});

  @override
  State<CreateNewPostWidget> createState() => _CreateNewPostWidgetState();
}

class _CreateNewPostWidgetState extends State<CreateNewPostWidget> {
  final _postController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountedPriceController = TextEditingController();
  
  bool _isLoading = false;
  String? _selectedContentType;
  List<String> _selectedImages = [];

  @override
  void dispose() {
    _postController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountedPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con avatar y input
          Row(
            children: [
              Hero(
                tag: 'user_avatar_${widget.currentUser.uid}',
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(widget.currentUser.imageUrl!),
                  backgroundColor: Colors.grey.shade200,
                  child: widget.currentUser.imageUrl == null
                      ? Text(
                          widget.currentUser.userName!.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showContentTypeDialog(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedContentType ?? "¿Qué quieres compartir hoy?",
                            style: TextStyle(
                              color: _selectedContentType != null 
                                  ? Colors.blue.shade700 
                                  : Colors.grey.shade600, 
                              fontSize: 15,
                              fontWeight: _selectedContentType != null 
                                  ? FontWeight.w500 
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey.shade500,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          if (_selectedContentType != null) ...[
            const SizedBox(height: 16),
            _buildContentInput(),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
          
          const SizedBox(height: 12),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildContentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedContentType == 'Post' || _selectedContentType == 'Promoción') ...[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Título ${_selectedContentType!.toLowerCase()}',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey.shade500),
              ),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const Divider(height: 1),
          ],
          
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: _getHintText(),
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey.shade500),
            ),
          ),
          
          if (_selectedImages.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(_selectedImages[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImages.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
          
          if (_selectedContentType == 'Promoción') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Precio original',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _discountedPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Precio con descuento',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildIconButton(
          icon: Icons.image,
          color: Colors.purple,
          onTap: _selectImages,
          tooltip: 'Agregar imágenes',
        ),
        const SizedBox(width: 12),
        _buildIconButton(
          icon: Icons.location_on,
          color: Colors.green,
          onTap: _addLocation,
          tooltip: 'Agregar ubicación',
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: _isLoading ? null : _createContent,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Publicar ${_selectedContentType!}'),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickAction(
            icon: Icons.photo_camera,
            label: 'Foto',
            color: Colors.purple,
            onTap: () => _quickCreate('Post'),
          ),
          _buildQuickAction(
            icon: Icons.videocam,
            label: 'Reel',
            color: Colors.red,
            onTap: () => _quickCreate('Reel'),
          ),
          _buildQuickAction(
            icon: Icons.auto_awesome,
            label: 'Story',
            color: Colors.orange,
            onTap: () => _quickCreate('Story'),
          ),
          _buildQuickAction(
            icon: Icons.local_offer,
            label: 'Promo',
            color: Colors.teal,
            onTap: () => _quickCreate('Promoción'),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(icon, color: color),
          onPressed: onTap,
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContentTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Qué quieres crear?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption('Post', Icons.article, Colors.blue, 'Comparte una publicación'),
            _buildDialogOption('Story', Icons.auto_awesome, Colors.orange, 'Crea una historia de 24h'),
            _buildDialogOption('Reel', Icons.videocam, Colors.red, 'Comparte un video corto'),
            _buildDialogOption('Promoción', Icons.local_offer, Colors.teal, 'Publica una oferta especial'),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogOption(String type, IconData icon, Color color, String subtitle) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(type),
      subtitle: Text(subtitle),
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _selectedContentType = type;
          _clearInputs();
        });
      },
    );
  }

  void _quickCreate(String type) {
    setState(() {
      _selectedContentType = type;
    });
  }

  void _clearInputs() {
    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _discountedPriceController.clear();
    _selectedImages.clear();
  }

  String _getHintText() {
    switch (_selectedContentType) {
      case 'Post':
        return '¿Qué estás pensando? Comparte tus ideas...';
      case 'Story':
        return '¿Qué está pasando ahora?';
      case 'Reel':
        return 'Describe tu video...';
      case 'Promoción':
        return 'Describe tu oferta especial...';
      default:
        return 'Escribe algo...';
    }
  }

  Future<void> _selectImages() async {
    // Aquí implementarías la lógica para seleccionar imágenes
    // Por ahora, agregaremos URLs de ejemplo
    setState(() {
      _selectedImages.add('https://via.placeholder.com/150');
    });
  }

  void _addLocation() {
    // Implementar lógica de ubicación
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de ubicación próximamente')),
    );
  }

  Future<void> _createContent() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, escribe algo antes de publicar')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<DentistHomeProvider>();
      
      switch (_selectedContentType) {
        case 'Post':
          await provider.createPost(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            imageUrls: _selectedImages.isNotEmpty ? _selectedImages : null,
            city: '', // Podrías agregar ubicación aquí
          );
          break;
          
        case 'Story':
          if (_selectedImages.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Por favor, selecciona una imagen para tu story')),
            );
            return;
          }
          await provider.createStory(
            imageUrl: _selectedImages.first,
            text: _descriptionController.text.trim(),
          );
          break;
          
        case 'Reel':
          if (_selectedImages.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Por favor, selecciona un video para tu reel')),
            );
            return;
          }
          await provider.createReel(
            videoUrl: _selectedImages.first,
            description: _descriptionController.text.trim(),
          );
          break;
          
        case 'Promoción':
          if (_priceController.text.isEmpty || _discountedPriceController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Por favor, completa los precios de la promoción')),
            );
            return;
          }
          await provider.createPromotion(
            name: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            price: double.parse(_priceController.text),
            discount: double.parse(_discountedPriceController.text),
            scope: widget.currentUser.role == UserRole.admin ? 'global' : 'profile',
            images: _selectedImages.isNotEmpty ? _selectedImages : null, 
          );
          break;
      }

      // Limpiar y cerrar
      setState(() {
        _selectedContentType = null;
        _clearInputs();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_selectedContentType} publicado exitosamente')),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al publicar: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
