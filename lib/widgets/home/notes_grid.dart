import 'package:flutter/material.dart';
import '../note_card.dart';

class NotesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> notes;
  final bool isLoading;
  final String searchQuery;
  final bool isArchiveView;
  final ValueChanged<Map<String, dynamic>> onOpen;
  final ValueChanged<Map<String, dynamic>> onPinToggle;
  final ValueChanged<Map<String, dynamic>> onArchiveToggle;
  final ValueChanged<Map<String, dynamic>> onDelete;

  const NotesGrid({
    super.key,
    required this.notes,
    required this.isLoading,
    required this.searchQuery,
    required this.isArchiveView,
    required this.onOpen,
    required this.onPinToggle,
    required this.onArchiveToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notes.isEmpty) {
      final hasQuery = searchQuery.trim().isNotEmpty;

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasQuery
                    ? Icons.search_off
                    : (isArchiveView
                          ? Icons.archive_outlined
                          : Icons.note_add_outlined),
                size: 48,
                color: colors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              Text(
                hasQuery
                    ? 'Ничего не найдено'
                    : (isArchiveView ? 'Архив пуст' : 'Пока здесь пусто'),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                hasQuery
                    ? 'Попробуйте изменить поисковый запрос.'
                    : (isArchiveView
                          ? 'Сюда попадают скрытые заметки.'
                          : 'Создайте первую заметку, чтобы начать.'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 390,
        mainAxisExtent: 230,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];

        return NoteCard(
          title: note['title'] as String? ?? '',
          content: note['content'] as String? ?? '',
          category: note['category'] as String?,
          updatedAt: DateTime.fromMillisecondsSinceEpoch(
            note['updated_at'] as int,
          ),
          isPinned: note['is_pinned'] == 1,
          isArchived: note['is_archived'] == 1,
          onTap: () => onOpen(note),
          onPinToggle: () => onPinToggle(note),
          onArchiveToggle: () => onArchiveToggle(note),
          onDelete: () => onDelete(note),
        );
      },
    );
  }
}
