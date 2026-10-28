import 'package:flutter/material.dart';

class HomeSidebar extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final bool isArchiveView;
  final VoidCallback onAllNotesSelected;
  final VoidCallback onArchiveSelected;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onBackup;
  final VoidCallback onRestore;

  const HomeSidebar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.isArchiveView,
    required this.onAllNotesSelected,
    required this.onArchiveSelected,
    required this.onCategorySelected,
    required this.onBackup,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final selectedBgColor = colors.secondaryContainer.withValues(alpha: 0.6);
    final selectedIconColor = colors.onSecondaryContainer;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(
            'БИБЛИОТЕКА',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.primary.withValues(alpha: 0.8),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.notes),
          title: const Text('Все заметки'),
          selected: !isArchiveView && selectedCategory == null,
          selectedColor: selectedIconColor,
          selectedTileColor: selectedBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: onAllNotesSelected,
        ),
        const SizedBox(height: 4),
        ListTile(
          leading: const Icon(Icons.archive_outlined),
          title: const Text('Архив'),
          selected: isArchiveView,
          selectedColor: selectedIconColor,
          selectedTileColor: selectedBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: onArchiveSelected,
        ),

        if (categories.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Divider(
              height: 1,
              color: colors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              'КАТЕГОРИИ',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.primary.withValues(alpha: 0.8),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ...categories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                selected: !isArchiveView && selectedCategory == category,
                selectedColor: selectedIconColor,
                selectedTileColor: selectedBgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () => onCategorySelected(category),
              ),
            ),
          ),
        ],

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            'ДАННЫЕ',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.primary.withValues(alpha: 0.8),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.backup_outlined),
          title: const Text('Сделать бэкап'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: onBackup,
        ),
        ListTile(
          leading: const Icon(Icons.restore_outlined),
          title: const Text('Восстановить'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: onRestore,
        ),
      ],
    );
  }
}
