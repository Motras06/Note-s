import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class NoteMarkdownPreview extends StatelessWidget {
  final String title;
  final String content;

  const NoteMarkdownPreview({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.isEmpty ? 'Без названия' : title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          MarkdownBody(
            data: content.isEmpty ? '_Заметка пока пуста._' : content,
            selectable: true,
            styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
              p: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
              h1: theme.textTheme.headlineMedium,
              h2: theme.textTheme.headlineSmall,
              h3: theme.textTheme.titleLarge,
              blockquoteDecoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(color: colors.primary, width: 3),
                ),
              ),
              blockquotePadding: const EdgeInsets.all(12),
              codeblockDecoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              codeblockPadding: const EdgeInsets.all(16),
              horizontalRuleDecoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.outlineVariant)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}