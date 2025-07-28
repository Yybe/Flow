import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/journal_provider.dart';
import '../models/journal_entry.dart';
import 'journal_writing_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {

  void showJournalWritingScreen() {
    final journalProvider = Provider.of<JournalProvider>(context, listen: false);
    // Check if there's already an entry for today
    final todayEntry = journalProvider.todayEntries.isNotEmpty
        ? journalProvider.todayEntries.first
        : null;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalWritingScreen(existingEntry: todayEntry),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JournalProvider>(
      builder: (context, journalProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFAFAFA),
            elevation: 0,
            title: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_stories,
                        color: AppColors.teal,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Journal',
                      style: TextStyle(
                        color: AppColors.darkGray,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMM d, yyyy - h:mm a').format(DateTime.now()),
                  style: const TextStyle(
                    color: AppColors.gray,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          body: journalProvider.entries.isEmpty
              ? _buildEmptyState()
              : _buildEntriesListWithStats(journalProvider),

        );
      },
    );
  }

  Widget _buildStatsRow(JournalProvider journalProvider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: _buildModernStatCard(
              '${journalProvider.entriesThisYear}',
              'Entries',
              Icons.book,
              AppColors.teal,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildModernStatCard(
              '${(journalProvider.wordsThisYear / 1000).toStringAsFixed(1)}k',
              'Words',
              Icons.edit,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildModernStatCard(
              '${journalProvider.daysJournaledThisYear}',
              'Days',
              Icons.calendar_today,
              Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.darkGray,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.gray,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.auto_stories,
                size: 64,
                color: AppColors.teal,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Begin Your Story',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Every great story starts with a single word.\nCapture your thoughts, dreams, and daily moments.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.gray,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.teal.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit,
                    color: AppColors.teal,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tap the "Write" button to start journaling',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntriesListWithStats(JournalProvider journalProvider) {
    // Group entries by date
    final Map<String, List<JournalEntry>> entriesByDate = {};
    for (final entry in journalProvider.entries) {
      final dateKey = '${entry.createdAt.year}-${entry.createdAt.month}-${entry.createdAt.day}';
      if (!entriesByDate.containsKey(dateKey)) {
        entriesByDate[dateKey] = [];
      }
      entriesByDate[dateKey]!.add(entry);
    }

    // Sort dates (newest first)
    final sortedDates = entriesByDate.keys.toList()
      ..sort((a, b) {
        final partsA = a.split('-');
        final partsB = b.split('-');
        final dateA = DateTime(int.parse(partsA[0]), int.parse(partsA[1]), int.parse(partsA[2]));
        final dateB = DateTime(int.parse(partsB[0]), int.parse(partsB[1]), int.parse(partsB[2]));
        return dateB.compareTo(dateA);
      });

    // Flatten all entries with date context
    final List<MapEntry<JournalEntry, String>> allEntries = [];
    for (final dateKey in sortedDates) {
      final entries = entriesByDate[dateKey]!;
      for (final entry in entries) {
        allEntries.add(MapEntry(entry, dateKey));
      }
    }

    return CustomScrollView(
      slivers: [
        // Stats cards as part of the scrollable content
        SliverToBoxAdapter(
          child: _buildStatsRow(journalProvider),
        ),

        // Journal entries
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final entryData = allEntries[index];
              final entry = entryData.key;
              final dateKey = entryData.value;

              // Check if this is the first entry of a new date
              final isFirstOfDate = index == 0 || allEntries[index - 1].value != dateKey;

              return Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: index == allEntries.length - 1 ? 100 : 12, // Reduced spacing
                ),
                child: _ModernJournalEntryCard(
                  entry: entry,
                  showDateHeader: isFirstOfDate,
                  isFirstEntry: index == 0,
                ),
              );
            },
            childCount: allEntries.length,
          ),
        ),
      ],
    );
  }
}

// Modern Journal Entry Card with better spacing and journaling aesthetics
class _ModernJournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final bool showDateHeader;
  final bool isFirstEntry;

  const _ModernJournalEntryCard({
    required this.entry,
    this.showDateHeader = false,
    this.isFirstEntry = false,
  });

  @override
  Widget build(BuildContext context) {
    // Split content into title and body
    final lines = entry.content.split('\n');
    final title = lines.first;
    final body = lines.length > 1 ? lines.skip(1).join('\n').trim() : '';

    // Format date label for header
    final now = DateTime.now();
    String? dateLabel;
    if (showDateHeader) {
      if (entry.createdAt.year == now.year && entry.createdAt.month == now.month && entry.createdAt.day == now.day) {
        dateLabel = 'Today';
      } else if (entry.createdAt.year == now.year && entry.createdAt.month == now.month && entry.createdAt.day == now.day - 1) {
        dateLabel = 'Yesterday';
      } else {
        dateLabel = DateFormat('EEEE, MMM d').format(entry.createdAt);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header with modern styling
        if (dateLabel != null) ...[
          if (!isFirstEntry) const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  dateLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],

        // Modern journal entry card
        Dismissible(
          key: Key(entry.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Delete Entry'),
                  content: const Text('Are you sure you want to delete this journal entry?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) {
            Provider.of<JournalProvider>(context, listen: false).deleteEntry(entry.id);
          },
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JournalWritingScreen(existingEntry: entry),
                ),
              );
            },
            onLongPress: () {
              _showEntryOptions(context);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with time, mood, and three-dot menu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.teal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              DateFormat('h:mm a').format(entry.createdAt),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.teal,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (entry.mood != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                entry.mood!.emoji,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Three-dot menu
                      GestureDetector(
                        onTap: () => _showEntryOptions(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.more_vert,
                            size: 16,
                            color: AppColors.gray,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Content preview with journal-like styling
                  if (title.isNotEmpty) ...[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGray,
                        fontSize: 16,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (body.isNotEmpty) const SizedBox(height: 6),
                  ],

                  if (body.isNotEmpty)
                    Text(
                      body,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray,
                        height: 1.4,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 12),

                  // Footer with word count and reading time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.text_fields, size: 12, color: AppColors.gray),
                            const SizedBox(width: 4),
                            Text(
                              '${entry.wordCount} words',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.gray,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule, size: 12, color: AppColors.gray),
                            const SizedBox(width: 4),
                            Text(
                              '${(entry.wordCount / 200).ceil()} min read',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.gray,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEntryOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Entry'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JournalWritingScreen(existingEntry: entry),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete Entry', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this journal entry? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<JournalProvider>(context, listen: false).deleteEntry(entry.id);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}