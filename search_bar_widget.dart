import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearch;
  final String? hintText;

  const SearchBarWidget({
    super.key,
    required this.onSearch,
    this.hintText,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _showClear = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onSearch,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Search patients by name or phone...',
          hintStyle: TextStyle(
            color: AppTheme.textHint,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.textSecondary,
          ),
          suffixIcon: _showClear
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    _controller.clear();
                    widget.onSearch('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
