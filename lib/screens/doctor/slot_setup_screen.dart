import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SlotSetupScreen extends StatefulWidget {
  const SlotSetupScreen({super.key});

  @override
  State<SlotSetupScreen> createState() => _SlotSetupScreenState();
}

class _SlotSetupScreenState extends State<SlotSetupScreen> {
  // Loading/error state
  bool _loading = true;
  String? _loadError;

  final List<DayAvailability> _availableSlots = [
    DayAvailability(
      day: 'Monday',
      isAvailable: true,
      startTime: '9:00 AM',
      endTime: '5:00 PM',
    ),
    DayAvailability(
      day: 'Tuesday',
      isAvailable: true,
      startTime: '9:00 AM',
      endTime: '5:00 PM',
    ),
    DayAvailability(
      day: 'Wednesday',
      isAvailable: true,
      startTime: '10:00 AM',
      endTime: '4:00 PM',
    ),
    DayAvailability(
      day: 'Thursday',
      isAvailable: true,
      startTime: '9:00 AM',
      endTime: '6:00 PM',
    ),
    DayAvailability(
      day: 'Friday',
      isAvailable: true,
      startTime: '9:00 AM',
      endTime: '5:00 PM',
    ),
    DayAvailability(
      day: 'Saturday',
      isAvailable: true,
      startTime: '9:00 AM',
      endTime: '2:00 PM',
    ),
    DayAvailability(
      day: 'Sunday',
      isAvailable: false,
      startTime: '',
      endTime: '',
    ),
  ];
  // Days order for consistent UI and mapping
  static const List<String> _daysOrder = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _fetchWorkingHours();
  }

  // Convert 'HH:mm' -> 'h:mm AM/PM'
  String _to12Hour(String hhmm) {
    if (hhmm.isEmpty) return '';
    try {
      final parts = hhmm.split(':');
      int h = int.parse(parts[0]);
      int m = int.parse(parts[1]);
      final period = h >= 12 ? 'PM' : 'AM';
      h = h % 12;
      if (h == 0) h = 12;
      final mm = m.toString().padLeft(2, '0');
      return '$h:$mm $period';
    } catch (_) {
      return hhmm; // fallback
    }
  }

  // Convert 'h:mm AM/PM' -> 'HH:mm'
  String _to24Hour(String display) {
    if (display.isEmpty) return '';
    try {
      final parts = display.split(' ');
      final hm = parts[0].split(':');
      int h = int.parse(hm[0]);
      final m = int.parse(hm[1]);
      final period = parts.length > 1 ? parts[1].toUpperCase() : 'AM';
      if (period == 'PM' && h < 12) h += 12;
      if (period == 'AM' && h == 12) h = 0;
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    } catch (_) {
      return display; // fallback
    }
  }

  String _dayKeyFromName(String name) => name.toLowerCase();

  Future<void> _fetchWorkingHours() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      final doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        // Nothing in Firestore yet; leave defaults
        setState(() => _loading = false);
        return;
      }

  final data = doc.data();
      final working = (data?['workingHours'] ?? {}) as Map<String, dynamic>;

      // Build from Firestore into our display list (convert to 12h)
      final Map<String, DayAvailability> byDay = {
        for (final d in _availableSlots) d.day: d,
      };

      for (final dayName in _daysOrder) {
        final key = _dayKeyFromName(dayName);
        final entry = (working[key] ?? {}) as Map<String, dynamic>;
        final isAvail = entry['isAvailable'] == true;
        final start24 = (entry['startTime'] ?? '') as String;
        final end24 = (entry['endTime'] ?? '') as String;
        final startDisp = start24.isNotEmpty ? _to12Hour(start24) : '';
        final endDisp = end24.isNotEmpty ? _to12Hour(end24) : '';

        final existing = byDay[dayName];
        if (existing != null) {
          existing.isAvailable = isAvail;
          existing.startTime = startDisp.isNotEmpty ? startDisp : existing.startTime;
          existing.endTime = endDisp.isNotEmpty ? endDisp : existing.endTime;
        }
      }

      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _loading = false;
        _loadError = e.toString();
      });
    }
  }

  Future<void> _saveSchedule() async {
    // Validate that available days have both start and end times
    bool isValid = true;
    for (var day in _availableSlots) {
      if (day.isAvailable && (day.startTime.isEmpty || day.endTime.isEmpty)) {
        isValid = false;
        break;
      }
    }

    if (!isValid) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set both start and end times for available days'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user signed in');

      // Build Firestore payload in 24h format
      final Map<String, dynamic> working = {};
      for (final day in _availableSlots) {
        final key = _dayKeyFromName(day.day);
        working[key] = {
          'isAvailable': day.isAvailable,
          'startTime': day.isAvailable ? _to24Hour(day.startTime) : '',
          'endTime': day.isAvailable ? _to24Hour(day.endTime) : '',
        };
      }

      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(user.uid)
          .set(
        {
          'workingHours': working,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Availability schedule saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving schedule: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  final List<String> _timeOptions = [
    '8:00 AM',
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
    '6:00 PM',
    '7:00 PM',
    '8:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability Setup'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Colors.grey[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configure Available Hours',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set your working hours for each day of the week',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Days List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : (_loadError != null
                    ? Center(
                        child: Text(
                          'Error loading schedule:\n$_loadError',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _availableSlots.length,
              itemBuilder: (context, index) {
                final daySlot = _availableSlots[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              daySlot.day,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Switch(
                              value: daySlot.isAvailable,
                              onChanged: (bool value) {
                                setState(() {
                                  daySlot.isAvailable = value;
                                  if (!value) {
                                    daySlot.startTime = '';
                                    daySlot.endTime = '';
                                  } else if (daySlot.startTime.isEmpty) {
                                    daySlot.startTime = '9:00 AM';
                                    daySlot.endTime = '5:00 PM';
                                  }
                                });
                              },
                              activeThumbColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (daySlot.isAvailable) ...[
                          // Available Hours Display
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Available Hours',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${daySlot.startTime} - ${daySlot.endTime}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Time Selection Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Start Time',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value:
                                              daySlot.startTime.isEmpty
                                                  ? null
                                                  : daySlot.startTime,
                                          hint: const Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Text('Select start time'),
                                          ),
                                          isExpanded: true,
                                          items:
                                              _timeOptions.map<
                                                DropdownMenuItem<String>
                                              >((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                        ),
                                                    child: Text(value),
                                                  ),
                                                );
                                              }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              daySlot.startTime =
                                                  newValue ?? '';
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'End Time',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value:
                                              daySlot.endTime.isEmpty
                                                  ? null
                                                  : daySlot.endTime,
                                          hint: const Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Text('Select end time'),
                                          ),
                                          isExpanded: true,
                                          items:
                                              _timeOptions.map<
                                                DropdownMenuItem<String>
                                              >((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                        ),
                                                    child: Text(value),
                                                  ),
                                                );
                                              }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              daySlot.endTime = newValue ?? '';
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Unavailable Day Display
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  color: Colors.grey[500],
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Not Available',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'No consultations scheduled',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            )),
          ),

          // Save Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: _saveSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Save Schedule',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DayAvailability {
  final String day;
  bool isAvailable;
  String startTime;
  String endTime;

  DayAvailability({
    required this.day,
    required this.isAvailable,
    required this.startTime,
    required this.endTime,
  });
}
