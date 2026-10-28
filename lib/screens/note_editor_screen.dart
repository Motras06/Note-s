import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:file_selector/file_selector.dart';

import '../widgets/editor/note_metadata_chips.dart';
import '../widgets/editor/note_editor_form.dart';
import '../widgets/editor/note_markdown_preview.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({
    super.key,
    required this.onSave,
    this.title = '',
    this.content = '',
    this.category,
    this.updatedAt,
    this.isNew = true,
  });

  final String title;
  final String content;
  final String? category;
  final DateTime? updatedAt;
  final bool isNew;

  final Future<void> Function(String title, String content, String? category)
  onSave;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _categoryController;

  late String _initialTitle;
  late String _initialContent;
  late String _initialCategory;

  bool _isEditing = false;
  bool _isSaving = false;
  bool _showPreview = false;

  bool get _hasChanges =>
      _titleController.text != _initialTitle ||
      _contentController.text != _initialContent ||
      _categoryController.text != _initialCategory;

  @override
  void initState() {
    super.initState();
    _initialTitle = widget.title;
    _initialContent = widget.content;
    _initialCategory = widget.category ?? '';

    _titleController = TextEditingController(text: _initialTitle);
    _contentController = TextEditingController(text: _initialContent);
    _categoryController = TextEditingController(text: _initialCategory);
    _isEditing = widget.isNew;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _togglePreview() {
    if (!_isEditing) return;
    setState(() => _showPreview = !_showPreview);
  }

  Future<void> _exportAsMarkdown() async {
    final title = _titleController.text.trim();
    final content = _contentController.text;
    final safeTitle = title.isEmpty
        ? 'Без_названия'
        : title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

    try {
      final FileSaveLocation? result = await getSaveLocation(
        suggestedName: '$safeTitle.md',
        acceptedTypeGroups: [
          const XTypeGroup(label: 'Markdown', extensions: ['md']),
        ],
      );

      if (result != null) {
        final mdContent = title.isEmpty ? content : '# $title\n\n$content';
        await File(result.path).writeAsString(mdContent);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Заметка экспортирована в MD!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка экспорта: $e')));
      }
    }
  }

  void _resetFields() {
    _titleController.text = _initialTitle;
    _contentController.text = _initialContent;
    _categoryController.text = _initialCategory;
  }

  Future<bool> _confirmDiscard() async {
    if (!_isEditing || !_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Несохранённые изменения'),
        content: const Text('Отменить изменения и вернуться к просмотру?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Продолжить'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Отменить изменения'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _handleBack() async {
    if (_isSaving) return;
    if (!await _confirmDiscard()) return;
    if (!mounted) return;

    if (_isEditing && !widget.isNew) {
      _resetFields();
      setState(() => _isEditing = false);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text;
    final category = _categoryController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите название заметки')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      await widget.onSave(title, content, category.isEmpty ? null : category);
      if (!mounted) return;

      _initialTitle = title;
      _initialContent = content;
      _initialCategory = category;

      setState(() {
        _isEditing = false;
        _isSaving = false;
      });

      if (widget.isNew) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка сохранения: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
          if (!_isSaving && _isEditing) _save();
        },
        const SingleActivator(LogicalKeyboardKey.keyP, control: true):
            _togglePreview,
        const SingleActivator(LogicalKeyboardKey.escape): _handleBack,
      },
      child: FocusScope(
        autofocus: true,
        child: PopScope(
          canPop: !_isEditing || !_hasChanges,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _handleBack();
          },
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                tooltip: 'Назад',
                onPressed: _handleBack,
                icon: const Icon(Icons.arrow_back),
              ),
              title: Text(
                _isEditing
                    ? (widget.isNew ? 'Новая заметка' : 'Редактирование')
                    : 'Заметка',
              ),
              actions: [
                if (_isEditing) ...[
                  IconButton(
                    tooltip: _showPreview
                        ? 'Редактировать текст'
                        : 'Предпросмотр Markdown',
                    onPressed: _togglePreview,
                    icon: Icon(
                      _showPreview
                          ? Icons.edit_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Экспорт в .md',
                    onPressed: _exportAsMarkdown,
                    icon: const Icon(Icons.download_outlined),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilledButton(
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Сохранить'),
                    ),
                  ),
                ] else
                  IconButton(
                    tooltip: 'Редактировать',
                    onPressed: () => setState(() => _isEditing = true),
                    icon: const Icon(Icons.edit_outlined),
                  ),
              ],
            ),
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!_isEditing)
                        NoteMetadataChips(
                          category: _categoryController.text.trim(),
                          updatedAt: widget.updatedAt,
                        ),
                      if (_isEditing && !_showPreview)
                        Expanded(
                          child: NoteEditorForm(
                            titleController: _titleController,
                            categoryController: _categoryController,
                            contentController: _contentController,
                          ),
                        )
                      else
                        Expanded(
                          child: NoteMarkdownPreview(
                            title: _titleController.text.trim(),
                            content: _contentController.text,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
