import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';

import '../database/database_helper.dart';
import '../providers/theme_provider.dart';
import 'note_editor_screen.dart';

import '../widgets/home/home_sidebar.dart';
import '../widgets/home/notes_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _database = DatabaseHelper.instance;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _notes = [];
  List<String> _categories = [];

  bool _isLoading = true;
  bool _isSearchVisible = false;
  String _searchQuery = '';

  bool _isArchiveView = false;
  String? _selectedCategory;

  List<Map<String, dynamic>> get _filteredNotes {
    final query = _searchQuery.trim().toLowerCase();

    return _notes.where((note) {
      final title = (note['title'] as String? ?? '').toLowerCase();
      final content = (note['content'] as String? ?? '').toLowerCase();
      final noteCategory = note['category'] as String?;

      final matchesSearch =
          query.isEmpty ||
          title.contains(query) ||
          content.contains(query) ||
          (noteCategory?.toLowerCase().contains(query) ?? false);

      final matchesCategory =
          _selectedCategory == null || noteCategory == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    try {
      final notes = await _database.getNotesByStatus(
        isArchived: _isArchiveView,
      );
      final categories = await _database.getUniqueCategories();

      if (!mounted) return;

      setState(() {
        _notes = notes;
        _categories = categories;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Не удалось загрузить заметки');
    }
  }

  Future<void> _createNote() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => NoteEditorScreen(
          isNew: true,
          onSave: (title, content, category) async {
            await _database.insertNote({
              'title': title,
              'content': content,
              'category': category,
            });
          },
        ),
      ),
    );
    if (mounted) await _loadNotes();
  }

  Future<void> _openNote(Map<String, dynamic> note) async {
    final id = note['id'] as int;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => NoteEditorScreen(
          isNew: false,
          title: note['title'] as String? ?? '',
          content: note['content'] as String? ?? '',
          category: note['category'] as String?,
          updatedAt: DateTime.fromMillisecondsSinceEpoch(
            note['updated_at'] as int,
          ),
          onSave: (title, content, category) async {
            await _database.updateNote(id, {
              'title': title,
              'content': content,
              'category': category,
            });
          },
        ),
      ),
    );
    if (mounted) await _loadNotes();
  }

  Future<void> _togglePin(Map<String, dynamic> note) async {
    final id = note['id'] as int;
    final isPinned = note['is_pinned'] == 1;
    try {
      await _database.setPinned(id, !isPinned);
      await _loadNotes();
    } catch (error) {
      _showError('Не удалось изменить закрепление');
    }
  }

  Future<void> _archiveNote(Map<String, dynamic> note) async {
    final id = note['id'] as int;
    final isCurrentlyArchived = note['is_archived'] == 1;
    try {
      await _database.setArchived(id, !isCurrentlyArchived);
      await _loadNotes();
    } catch (error) {
      _showError('Не удалось изменить статус заметки');
    }
  }

  Future<void> _deleteNote(Map<String, dynamic> note) async {
    final colors = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.delete_outline, color: colors.error),
        title: const Text('Удалить заметку?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _database.deleteNote(note['id'] as int);
      await _loadNotes();
    } catch (error) {
      _showError('Не удалось удалить заметку');
    }
  }

  Future<void> _exportBackup() async {
    try {
      final notes = await _database.getAllNotes(includeArchived: true);
      final jsonString = jsonEncode(notes);

      final FileSaveLocation? result = await getSaveLocation(
        suggestedName: 'notes_backup.json',
        acceptedTypeGroups: [
          const XTypeGroup(label: 'JSON Data', extensions: ['json']),
        ],
      );

      if (result != null) {
        await File(result.path).writeAsString(jsonString);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Бэкап сохранен!')));
        }
      }
    } catch (e) {
      _showError('Ошибка при создании бэкапа: $e');
    }
  }

  Future<void> _importBackup() async {
    try {
      final XFile? file = await openFile(
        acceptedTypeGroups: [
          const XTypeGroup(label: 'JSON Data', extensions: ['json']),
        ],
      );

      if (file != null) {
        final jsonString = await file.readAsString();
        final List<dynamic> decoded = jsonDecode(jsonString);
        int importedCount = 0;

        for (var item in decoded) {
          if (item is Map<String, dynamic>) {
            final noteToImport = Map<String, dynamic>.from(item);
            noteToImport.remove('id');
            await _database.insertNote(noteToImport);
            importedCount++;
          }
        }
        await _loadNotes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Восстановлено: $importedCount')),
          );
        }
      }
    } catch (e) {
      _showError('Ошибка импорта: Файл поврежден');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  void _handleSidebarTap(VoidCallback action, bool isDesktop) {
    action();
    _loadNotes();
    if (!isDesktop) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    final isDark = context.watch<ThemeProvider>().themeMode == ThemeMode.dark;

    String titleText = _isArchiveView
        ? 'Архив'
        : (_selectedCategory ?? 'Note’s');

    final sidebar = HomeSidebar(
      categories: _categories,
      selectedCategory: _selectedCategory,
      isArchiveView: _isArchiveView,
      onAllNotesSelected: () => _handleSidebarTap(
        () => setState(() {
          _isArchiveView = false;
          _selectedCategory = null;
        }),
        isDesktop,
      ),
      onArchiveSelected: () => _handleSidebarTap(
        () => setState(() {
          _isArchiveView = true;
          _selectedCategory = null;
        }),
        isDesktop,
      ),
      onCategorySelected: (category) => _handleSidebarTap(
        () => setState(() {
          _isArchiveView = false;
          _selectedCategory = category;
        }),
        isDesktop,
      ),
      onBackup: () => _handleSidebarTap(_exportBackup, isDesktop),
      onRestore: () => _handleSidebarTap(_importBackup, isDesktop),
    );

    final mainContent = Column(
      children: [
        if (_isSearchVisible)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Поиск...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        Expanded(
          child: NotesGrid(
            notes: _filteredNotes,
            isLoading: _isLoading,
            searchQuery: _searchQuery,
            isArchiveView: _isArchiveView,
            onOpen: _openNote,
            onPinToggle: _togglePin,
            onArchiveToggle: _archiveNote,
            onDelete: _deleteNote,
          ),
        ),
      ],
    );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true):
            _createNote,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              titleText,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            actions: [
              IconButton(
                tooltip: 'Поиск',
                onPressed: _toggleSearch,
                icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
              ),
              IconButton(
                tooltip: isDark ? 'Светлая тема' : 'Темная тема',
                onPressed: () => context.read<ThemeProvider>().toggleTheme(),
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: FilledButton.icon(
                    onPressed: _createNote,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Новая заметка'),
                  ),
                ),
              ] else
                const SizedBox(width: 8),
            ],
          ),
          drawer: isDesktop
              ? null
              : Drawer(
                  backgroundColor: colors.surfaceContainerLow,
                  child: SafeArea(child: sidebar),
                ),
          floatingActionButton: isDesktop
              ? null
              : FloatingActionButton.extended(
                  onPressed: _createNote,
                  icon: const Icon(Icons.add),
                  label: const Text('Заметка'),
                ),
          body: isDesktop
              ? Row(
                  children: [
                    Container(
                      width: 250,
                      color: colors.surfaceContainerLow,
                      child: sidebar,
                    ),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: colors.outlineVariant.withValues(alpha: 0.2),
                    ),
                    Expanded(child: mainContent),
                  ],
                )
              : mainContent,
        ),
      ),
    );
  }
}
