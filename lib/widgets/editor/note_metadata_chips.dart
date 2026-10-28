import 'package:flutter/material.dart';

class NoteMetadataChips extends StatelessWidget {
  final String category;
  final DateTime? updatedAt;

  const NoteMetadataChips({super.key, required this.category, this.updatedAt});

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (category.isNotEmpty)
            Chip(
              avatar: const Icon(Icons.folder_outlined, size: 18),
              label: Text(category),
              visualDensity: VisualDensity.compact,
            ),
          if (updatedAt != null)
            Chip(
              avatar: const Icon(Icons.schedule, size: 16),
              label: Text(_formatDate(updatedAt!)),
              visualDensity: VisualDensity.compact,
              backgroundColor: colors.surfaceContainerLow,
            ),
        ],
      ),
    );
  }
}
