import 'package:flutter/material.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.title,
    required this.content,
    required this.updatedAt,
    this.category,
    this.isPinned = false,
    this.isArchived = false,
    this.onTap,
    this.onPinToggle,
    this.onArchiveToggle,
    this.onDelete,
  });

  final String title;
  final String content;
  final DateTime updatedAt;
  final String? category;

  final bool isPinned;
  final bool isArchived;

  final VoidCallback? onTap;
  final VoidCallback? onPinToggle;
  final VoidCallback? onArchiveToggle;
  final VoidCallback? onDelete;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);

    final time =
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';

    if (day == today) {
      return 'Сегодня, $time';
    }

    if (day == today.subtract(const Duration(days: 1))) {
      return 'Вчера, $time';
    }

    final dateString =
        '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';

    return '$dateString, $time';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: isArchived ? colors.surfaceContainerLow : colors.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 1.2),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category and actions.
              Row(
                children: [
                  if (category != null && category!.trim().isNotEmpty)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: colors.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.folder_outlined,
                              size: 15,
                              color: colors.onSecondaryContainer,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                category!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelMedium?.copyWith(
                                  color: colors.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (isPinned)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.push_pin,
                        size: 19,
                        color: colors.primary,
                      ),
                    ),
                  _buildMenu(context),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                title.trim().isEmpty ? 'Без названия' : title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isArchived
                      ? colors.onSurfaceVariant
                      : colors.onSurface,
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    content.trim().isEmpty ? 'Нет содержимого' : content.trim(),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 16,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _formatDate(updatedAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (isArchived) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.archive_outlined,
                      size: 17,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    if (onPinToggle == null && onArchiveToggle == null && onDelete == null) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      tooltip: 'Действия с заметкой',
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'pin':
            onPinToggle?.call();
          case 'archive':
            onArchiveToggle?.call();
          case 'delete':
            onDelete?.call();
        }
      },
      itemBuilder: (context) => [
        if (onPinToggle != null)
          PopupMenuItem(
            value: 'pin',
            child: ListTile(
              leading: Icon(
                isPinned ? Icons.push_pin_outlined : Icons.push_pin,
              ),
              title: Text(isPinned ? 'Открепить' : 'Закрепить'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (onArchiveToggle != null)
          PopupMenuItem(
            value: 'archive',
            child: ListTile(
              leading: Icon(
                isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
              ),
              title: Text(isArchived ? 'Восстановить' : 'В архив'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (onDelete != null)
          PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: const Text('Удалить'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
      ],
    );
  }
}
