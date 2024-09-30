import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

void main() => runApp(TimeManagementApp());

class TimeManagementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TimeBlocksPage(),
    );
  }
}

class TimeBlocksPage extends StatefulWidget {
  @override
  _TimeBlocksPageState createState() => _TimeBlocksPageState();
}

class _TimeBlocksPageState extends State<TimeBlocksPage> {
  List<Map<String, dynamic>> timeBlocks = [];
  List<Map<String, dynamic>> completedActivities = [];
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final Map<String, Timer?> _timers = {};
  final Map<String, int> _remainingTimes = {};
  final Map<String, bool> _isTimerRunning = {};

  @override
  void initState() {
    super.initState();
    _loadCompletedActivities();
  }

  Future<void> _loadCompletedActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? activities = prefs.getStringList('completedActivities');
    if (activities != null) {
      setState(() {
        completedActivities = activities.map((activity) {
          final parts = activity.split('|');
          return {
            'activity': parts[0],
            'time': int.parse(parts[1]),
            'actualTime': int.parse(parts[2]),
            'dateTime': DateTime.parse(parts[3]),
          };
        }).toList();
      });
    }
  }

  Future<void> _saveCompletedActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final activities = completedActivities.map((activity) {
      return '${activity['activity']}|${activity['time']}|${activity['actualTime']}|${activity['dateTime']}';
    }).toList();
    await prefs.setStringList('completedActivities', activities);
  }

  void _addTimeBlock(String activity, int time) {
    setState(() {
      timeBlocks.add({'activity': activity, 'time': time});
      _remainingTimes[activity] = time;
      _isTimerRunning[activity] = false;
    });
    _activityController.clear();
    _timeController.clear();
  }

  void _startTimer(String activity) {
    if (_isTimerRunning[activity] == true) return;

    setState(() {
      _isTimerRunning[activity] = true;
    });

    _timers[activity] = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTimes[activity]! > 0) {
        setState(() {
          _remainingTimes[activity] = _remainingTimes[activity]! - 1;
        });
      } else {
        _showNotification(activity);
        _markActivityAsCompleted(activity);
        _stopTimer(activity);
      }
    });
  }

  void _markActivityAsCompleted(String activity) {
    final completedTime = _remainingTimes[activity];
    final actualTime = timeBlocks.firstWhere((block) => block['activity'] == activity)['time'] - completedTime!;
    final dateTime = DateTime.now();
    final newActivity = {
      'activity': activity,
      'time': timeBlocks.firstWhere((block) => block['activity'] == activity)['time'],
      'actualTime': actualTime,
      'dateTime': dateTime,
    };

    setState(() {
      completedActivities.add(newActivity);
      _saveCompletedActivities();
    });
  }

  void _pauseTimer(String activity) {
    if (_timers[activity] != null && _isTimerRunning[activity] == true) {
      _timers[activity]?.cancel();
      setState(() {
        _isTimerRunning[activity] = false;
      });
    }
  }

  void _stopTimer(String activity) {
    _timers[activity]?.cancel();
    setState(() {
      _isTimerRunning[activity] = false;
    });
  }

  void _showNotification(String activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Atividade Concluída'),
        content: Text('A atividade "$activity" foi concluída!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Atividade'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryPage(completedActivities: completedActivities),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _activityController,
                  decoration: InputDecoration(labelText: 'Atividade'),
                ),
                TextField(
                  controller: _timeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Tempo (min)'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final activity = _activityController.text;
                    final timeString = _timeController.text;
                    final time = int.tryParse(timeString);
                    if (activity.isNotEmpty && time != null && time > 0) {
                      _addTimeBlock(activity, time * 60);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5c65c0),
                  ),
                  child: Text('Adicionar',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),)
                  ,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: timeBlocks.length,
              itemBuilder: (context, index) {
                final block = timeBlocks[index];
                final activity = block['activity'];
                final remainingTime = _remainingTimes[activity] ?? 0;

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(activity),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tempo restante: ${formatTime(remainingTime)}'),
                        LinearProgressIndicator(
                          value: remainingTime / block['time'],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        _isTimerRunning[activity] == true
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      onPressed: () {
                        if (_isTimerRunning[activity] == true) {
                          _pauseTimer(activity);
                        } else {
                          _startTimer(activity);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '$minutes min e $remainingSeconds seg';
  }

  @override
  void dispose() {
    _timers.forEach((_, timer) {
      timer?.cancel();
    });
    _activityController.dispose();
    _timeController.dispose();
    super.dispose();
  }
}

class HistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> completedActivities;

  HistoryPage({required this.completedActivities});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Atividades'),
      ),
      body: ListView.builder(
        itemCount: completedActivities.length,
        itemBuilder: (context, index) {
          final activity = completedActivities[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(activity['activity']),
              subtitle: Text(
                'Tempo Planejado: ${formatTime(activity['time'])}\n'
                    'Tempo Real: ${formatTime(activity['actualTime'])}\n'
                    'Concluído em: ${formatDateTime(activity['dateTime'])}',
              ),
            ),
          );
        },
      ),
    );
  }

  String formatTime(int? seconds) {
    if (seconds == null) return '0 seg';
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '$minutes min e $remainingSeconds seg';
  }

  String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
