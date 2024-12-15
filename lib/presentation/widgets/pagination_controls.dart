import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.first_page),
          onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 50),
          child: Text(
            '$currentPage / $totalPages',
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: currentPage < totalPages ? () => onPageChanged(totalPages) : null,
        ),
      ],
    );
  }
}
