import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pomodoro/pomodoro_painter.dart';

void main() => runApp(PomodoroApp());

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro',
      debugShowCheckedModeBanner: false,
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
  // Default settings
  int workMinutes = 25;
  int breakMinutes = 5;
  int targetCycles = 4;

  Duration workDuration = Duration(minutes: 25);
  Duration breakDuration = Duration(minutes: 5);
  Duration remaining = Duration(minutes: 25);
  Timer? timer;
  bool isRunning = false;
  int cycle = 1;
  bool isWorkMode = true;

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
            if (isWorkMode) {
              isWorkMode = false;
              remaining = breakDuration;
            } else {
              isWorkMode = true;
              cycle++;
              remaining = workDuration;
            }
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
      isWorkMode = true;
      remaining = workDuration;
      cycle = 1;
    });
  }

  String formatTime(Duration d) =>
      d.toString().split('.').first.padLeft(8, "0").substring(3);

  void _openSettingsDialog() {
    // Create controllers for the text fields
    final workController = TextEditingController(text: workMinutes.toString());
    final breakController = TextEditingController(
      text: breakMinutes.toString(),
    );
    final cycleController = TextEditingController(
      text: targetCycles.toString(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Configurações do Pomodoro'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: workController,
                  decoration: InputDecoration(
                    labelText: 'Tempo de Trabalho (minutos)',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                TextField(
                  controller: breakController,
                  decoration: InputDecoration(
                    labelText: 'Tempo de Pausa (minutos)',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                TextField(
                  controller: cycleController,
                  decoration: InputDecoration(labelText: 'Ciclos Alvo'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  // Parse the input values
                  final newWorkMin =
                      int.tryParse(workController.text) ?? workMinutes;
                  final newBreakMin =
                      int.tryParse(breakController.text) ?? breakMinutes;
                  final newTargetCycles =
                      int.tryParse(cycleController.text) ?? targetCycles;

                  // Update the settings
                  setState(() {
                    workMinutes = newWorkMin > 0 ? newWorkMin : 1;
                    breakMinutes = newBreakMin > 0 ? newBreakMin : 1;
                    targetCycles = newTargetCycles > 0 ? newTargetCycles : 1;

                    workDuration = Duration(minutes: workMinutes);
                    breakDuration = Duration(minutes: breakMinutes);

                    // Reset the timer
                    reset();
                  });

                  Navigator.pop(context);
                },
                child: Text('Salvar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pomodoro'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _openSettingsDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: PomodoroPainter(
              size: MediaQuery.of(context).size.width,
              tomatoColor:
                  isWorkMode
                      ? const Color(0xFFE53935)
                      : const Color(0xFFE57373),
              leafColor: const Color(0xFF4CAF50),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isWorkMode ? 'Trabalho' : 'Pausa',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
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
                  'Ciclo: $cycle / $targetCycles',
                  style: const TextStyle(color: Colors.white, fontSize: 30),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: startPause,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(isRunning ? 'Pausar' : 'Iniciar'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: reset,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Resetar'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: _openSettingsDialog,
                  icon: Icon(Icons.edit, color: Colors.white),
                  label: Text(
                    'Editar Configurações',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
