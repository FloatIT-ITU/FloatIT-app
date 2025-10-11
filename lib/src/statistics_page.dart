import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floatit/src/user_profile_provider.dart';
import 'package:floatit/src/widgets/banners.dart';
import 'package:floatit/src/layout_widgets.dart';
import 'package:floatit/src/widgets/statistics_card.dart';
import 'user_statistics_service.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String _monthlyRank = '--';
  String _semesterRank = '--';
  String _allTimeRank = '--';
  bool _loadingRanks = true;

  int _monthlyEvents = 0;
  int _semesterEvents = 0;
  int _allTimeEvents = 0;
  bool _loadingEvents = true;

  List<Map<String, dynamic>> _leaderboard = [];
  bool _loadingLeaderboard = true;
  String _leaderboardPeriod = 'monthly'; // 'allTime', 'monthly', 'semester'

  @override
  void initState() {
    super.initState();
    _calculateRankings();
    _calculateEventCounts();
    _loadLeaderboard();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recalculate when the page comes back into focus
    _calculateRankings();
    _calculateEventCounts();
    _loadLeaderboard();
  }

  Future<void> _calculateRankings() async {
    setState(() {
      _loadingRanks = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Calculate all rankings in parallel
      final results = await Future.wait([
        UserStatisticsService.calculateUserRank(user.uid, 'allTime'),
        UserStatisticsService.calculateUserRank(user.uid, 'monthly'),
        UserStatisticsService.calculateUserRank(user.uid, 'semester'),
      ]);

      setState(() {
        _allTimeRank = results[0];
        _monthlyRank = results[1];
        _semesterRank = results[2];
      });
    } catch (e) {
      // On error, keep default values
      setState(() {
        _allTimeRank = '--';
        _monthlyRank = '--';
        _semesterRank = '--';
      });
    } finally {
      setState(() {
        _loadingRanks = false;
      });
    }
  }

  Future<void> _calculateEventCounts() async {
    setState(() {
      _loadingEvents = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final now = DateTime.now();
      final currentYear = now.year;
      final currentMonth = now.month;

      // Define date ranges for different periods
      DateTime? monthlySince;
      DateTime? semesterSince;

      // Monthly: Current month
      monthlySince = DateTime(currentYear, currentMonth, 1);

      // Semester: Current semester
      if (currentMonth >= 8 || currentMonth <= 1) {
        // Autumn Semester: Aug 1 to Jan 31
        semesterSince = DateTime(currentYear - (currentMonth <= 1 ? 1 : 0), 8, 1);
      } else {
        // Spring Semester: Feb 1 to Jul 31
        semesterSince = DateTime(currentYear, 2, 1);
      }

      // Calculate all event counts in parallel
      final results = await Future.wait([
        UserStatisticsService.getUserEventsJoinedCount(user.uid), // All time
        UserStatisticsService.getUserEventsJoinedCount(user.uid, since: monthlySince), // Monthly
        UserStatisticsService.getUserEventsJoinedCount(user.uid, since: semesterSince), // Semester
      ]);

      setState(() {
        _allTimeEvents = results[0];
        _monthlyEvents = results[1];
        _semesterEvents = results[2];
      });
    } catch (e) {
      // On error, keep default values
      setState(() {
        _allTimeEvents = 0;
        _monthlyEvents = 0;
        _semesterEvents = 0;
      });
    } finally {
      setState(() {
        _loadingEvents = false;
      });
    }
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _loadingLeaderboard = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final leaderboard = await UserStatisticsService.getLeaderboard(_leaderboardPeriod, currentUserId: user?.uid);
      
      setState(() {
        _leaderboard = leaderboard;
      });
    } catch (e) {
      setState(() {
        _leaderboard = [];
      });
    } finally {
      setState(() {
        _loadingLeaderboard = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profile, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StandardPageBanner(title: 'Statistics', showBackArrow: true),
              Expanded(
                child: SingleChildScrollView(
                  child: ConstrainedContent(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        // Testing notice
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'This feature is currently being tested. Your feedback is appreciated!',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Events joined section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: StatisticsCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Events Joined',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildEventCard('This Month', _loadingEvents ? '...' : _monthlyEvents.toString(), Icons.calendar_today),
                                    Container(
                                      height: 60,
                                      width: 1,
                                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                    ),
                                    _buildEventCard('This Semester', _loadingEvents ? '...' : _semesterEvents.toString(), Icons.school),
                                    Container(
                                      height: 60,
                                      width: 1,
                                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                    ),
                                    _buildEventCard('All Time', _loadingEvents ? '...' : _allTimeEvents.toString(), Icons.timeline),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Current stats
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: StatisticsCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Rankings',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildRankCard('This Month', _loadingRanks ? '...' : _monthlyRank, Icons.calendar_today),
                                    Container(
                                      height: 60,
                                      width: 1,
                                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                    ),
                                    _buildRankCard('This Semester', _loadingRanks ? '...' : _semesterRank, Icons.school),
                                    Container(
                                      height: 60,
                                      width: 1,
                                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                    ),
                                    _buildRankCard('All Time', _loadingRanks ? '...' : _allTimeRank, Icons.timeline),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Leaderboard
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: StatisticsCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Leaderboard',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    // Period filter dropdown
                                    DropdownButton<String>(
                                      value: _leaderboardPeriod,
                                      items: const [
                                        DropdownMenuItem(value: 'monthly', child: Text('This Month')),
                                        DropdownMenuItem(value: 'semester', child: Text('This Semester')),
                                        DropdownMenuItem(value: 'allTime', child: Text('All Time')),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() {
                                            _leaderboardPeriod = value;
                                          });
                                          _loadLeaderboard();
                                        }
                                      },
                                      underline: const SizedBox(),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                      icon: Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 16,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (_loadingLeaderboard)
                                  const Center(child: CircularProgressIndicator())
                                else if (_leaderboard.isEmpty)
                                  Center(
                                    child: Text(
                                      'No data available',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  )
                                else
                                  Column(
                                    children: _leaderboard.map((entry) {
                                      final isCurrentUser = entry['isCurrentUser'] as bool;
                                      final rank = entry['rank'] as int;
                                      final displayName = entry['displayName'] as String;
                                      final eventCount = entry['eventCount'] as int;
                                      
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isCurrentUser 
                                            ? Theme.of(context).colorScheme.primaryContainer
                                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(8),
                                          border: isCurrentUser 
                                            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                                            : null,
                                        ),
                                        child: Row(
                                          children: [
                                            // Rank
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: rank <= 3 
                                                  ? Theme.of(context).colorScheme.primary
                                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '#$rank',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: rank <= 3 
                                                      ? Theme.of(context).colorScheme.onPrimary
                                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // User info
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    displayName,
                                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    '$eventCount event${eventCount != 1 ? 's' : ''} joined',
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Trophy icon for top 3
                                            if (rank <= 3)
                                              Icon(
                                                rank == 1 ? Icons.emoji_events : 
                                                rank == 2 ? Icons.emoji_events_outlined : 
                                                Icons.military_tech,
                                                color: Theme.of(context).colorScheme.primary,
                                                size: 24,
                                              ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRankCard(String period, String rank, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  period,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: rank != '--' && rank != '...'
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    rank,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: rank != '--' && rank != '...'
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(String period, String count, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  period,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    count,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}