import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pomodoro/pomodoro_painter.dart';

void main() => runApp(PomodoroApp());

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro',
      theme: ThemeData(primarySwatch: Colors.red),
      home: PomodoroAppleTimer(),
    );
  }
}

class PomodoroAppleTimer extends StatefulWidget {
  const PomodoroAppleTimer({super.key});

  @override
  State<PomodoroAppleTimer> createState() => _PomodoroAppleTimerState();
}

class _PomodoroAppleTimerState extends State<PomodoroAppleTimer> {
  static const workDuration = Duration(minutes: 25);
  Duration remaining = workDuration;
  Timer? timer;
  bool isRunning = false;
  int cycle = 1;

  void startPause() {
    if (isRunning) {
      timer?.cancel();
    } else {
      timer = Timer.periodic(Duration(seconds: 1), (_) {
        if (remaining.inSeconds > 0) {
          setState(() => remaining -= Duration(seconds: 1));
        } else {
          timer?.cancel();
          setState(() {
            cycle++;
            remaining = workDuration;
            isRunning = false;
          });
        }
      });
    }
    setState(() => isRunning = !isRunning);
  }

  void reset() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      remaining = workDuration;
      cycle = 1;
    });
  }

  String formatTime(Duration d) =>
      d.toString().split('.').first.padLeft(8, "0").substring(3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pomodoro')),
      body: Stack(
        children: [
          Positioned.fill(
            child: PomodoroPainter(
              size: MediaQuery.of(context).size.width,
              tomatoColor: const Color(0xFFE53935),
              leafColor: const Color(0xFF4CAF50),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formatTime(remaining),
                  style: const TextStyle(
                    fontSize: 72,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Ciclo: $cycle',
                  style: const TextStyle(color: Colors.white, fontSize: 30),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: startPause,
                      child: Text(isRunning ? 'Pausar' : 'Iniciar'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: reset,
                      child: const Text('Resetar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
