import 'package:flutter/material.dart';

class SearchWidget extends StatefulWidget {
  final String hintText;
  final Function(String) onSearch;
  final Function()? onClear;
  final IconData? searchIcon;
  final bool enabled;

  const SearchWidget({
    super.key,
    this.hintText = 'Buscar...',
    required this.onSearch,
    this.onClear,
    this.searchIcon = Icons.search,
    this.enabled = true,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.isNotEmpty;
      if (hasText != _hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onClear() {
    _controller.clear();
    widget.onSearch('');
    if (widget.onClear != null) {
      widget.onClear!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _controller,
        enabled: widget.enabled,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(
            widget.searchIcon,
            color: Colors.grey[400],
          ),
          suffixIcon: _hasText
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[400],
                  ),
                  onPressed: _onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onChanged: widget.onSearch,
        onSubmitted: widget.onSearch,
      ),
    );
  }
}