import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:medident/core/models/user-model.dart';
import 'package:medident/screens/widgets/avatar/global_avatar_widget.dart';

class Suggested_follow_Widget extends StatefulWidget {
  final List<UserModel> userModelList;
  final Function(String) onFollow;
  final Future<List<UserModel>> Function(String? query, int page)? onLoadMore;
  final bool isLoading;

  const Suggested_follow_Widget({
    super.key,
    required this.userModelList,
    required this.onFollow,
    this.onLoadMore,
    this.isLoading = false,
  });

  @override
  State<Suggested_follow_Widget> createState() => _Suggested_follow_WidgetState();
}

class _Suggested_follow_WidgetState extends State<Suggested_follow_Widget> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _filteredUsers = [];
  bool _isSearching = false;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _filteredUsers = widget.userModelList;
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant Suggested_follow_Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userModelList != widget.userModelList) {
      _filteredUsers = _isSearching ? _filterUsers(_searchController.text) : widget.userModelList;
    }
  }

  List<UserModel> _filterUsers(String query) {
    if (query.isEmpty) return widget.userModelList;
    final q = query.toLowerCase();
    return widget.userModelList.where((u) {
      final nameMatch = u.fullName.toLowerCase().contains(q);
      final specMatch = u.speciality != null && u.speciality!.toLowerCase().contains(q);
      final emailMatch = u.email.toLowerCase().contains(q);
      return nameMatch || specMatch || emailMatch;
    }).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      _filteredUsers = _filterUsers(query);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        widget.onLoadMore != null) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final newUsers = await widget.onLoadMore!(_isSearching ? _searchController.text : null, _currentPage + 1);
      if (newUsers.isNotEmpty) {
        setState(() {
          _currentPage++;
          if (_isSearching) {
            _filteredUsers = [..._filteredUsers, ...newUsers];
          }
        });
      }
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayUsers = _isSearching ? _filteredUsers : widget.userModelList;

    if (displayUsers.isEmpty && !widget.isLoading) {
      return _buildEmpty();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Título y barra de búsqueda
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.people, size: 18, color: const Color(0xFF1D4ED8)),
              const SizedBox(width: 8),
              const Text(
                'Profesionales recomendados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              if (!_isSearching)
                GestureDetector(
                  onTap: () => setState(() => _isSearching = true),
                  child: const Icon(Icons.search, size: 20, color: Color(0xFF1D4ED8)),
                ),
            ],
          ),
        ),
        if (_isSearching)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Buscar profesional...',
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      _isSearching = false;
                      _filteredUsers = widget.userModelList;
                    });
                  },
                  child: const Icon(Icons.close, size: 18),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: widget.isLoading
              ? _buildShimmer()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: displayUsers.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= displayUsers.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final user = displayUsers[index];
                    return _buildUserCard(user);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1D4ED8).withOpacity(0.3),
                      const Color(0xFF7C3AED).withOpacity(0.3),
                    ],
                  ),
                ),
                child: ClipOval(
                  child: Global_Avatar_Widget(
                    imageUrl: user.imageUrl,
                    width: 64,
                    height: 64,
                    errorWidget: Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.person, size: 28, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              user.fullName.isNotEmpty ? user.fullName : 'Usuario',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              user.speciality ?? 'General',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.onFollow(user.uid),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Seguir'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: 140,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      height: 180,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            _isSearching ? 'No se encontraron profesionales' : 'No hay profesionales recomendados',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }
}
