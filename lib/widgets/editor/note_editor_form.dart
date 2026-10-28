import 'package:flutter/material.dart';

class NoteEditorForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController categoryController;
  final TextEditingController contentController;

  const NoteEditorForm({
    super.key,
    required this.titleController,
    required this.categoryController,
    required this.contentController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      children: [
        TextField(
          controller: titleController,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Название заметки',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: categoryController,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'Категория',
            prefixIcon: const Icon(Icons.folder_outlined),
            filled: true,
            fillColor: colors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Divider(color: colors.outlineVariant),
        const SizedBox(height: 12),
        TextField(
          controller: contentController,
          minLines: 12,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
          decoration: const InputDecoration(
            hintText: 'Начните писать...\n\n'
                'Поддерживается Markdown:\n'
                '# Заголовок\n'
                '**Жирный текст**\n'
                '- Список',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}