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
  int longBreakMinutes = 15;
  int targetCycles = 4;
  int cyclesBeforeLongBreak = 4;
  
  Duration workDuration = Duration(minutes: 25);
  Duration breakDuration = Duration(minutes: 5);
  Duration longBreakDuration = Duration(minutes: 15);
  Duration remaining = Duration(minutes: 25);
  Timer? timer;
  bool isRunning = false;
  int cycle = 1;
  String currentMode = "work"; // "work", "break", "longBreak"

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
            if (currentMode == "work") {
              // Check if we need a long break
              if (cycle % cyclesBeforeLongBreak == 0) {
                currentMode = "longBreak";
                remaining = longBreakDuration;
              } else {
                currentMode = "break";
                remaining = breakDuration;
              }
            } else {
              // After any break, go back to work
              currentMode = "work";
              if (currentMode == "longBreak" || currentMode == "break") {
                cycle++;
              }
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
      currentMode = "work";
      remaining = workDuration;
      cycle = 1;
    });
  }

  String formatTime(Duration d) =>
      d.toString().split('.').first.padLeft(8, "0").substring(3);

  void _openSettingsDialog() {
    // Create controllers for the text fields
    final workController = TextEditingController(text: workMinutes.toString());
    final breakController = TextEditingController(text: breakMinutes.toString());
    final longBreakController = TextEditingController(text: longBreakMinutes.toString());
    final cycleController = TextEditingController(text: targetCycles.toString());
    final longBreakCycleController = TextEditingController(text: cyclesBeforeLongBreak.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configurações do Pomodoro'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: workController,
                decoration: InputDecoration(labelText: 'Tempo de Trabalho (minutos)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: breakController,
                decoration: InputDecoration(labelText: 'Tempo de Pausa Curta (minutos)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: longBreakController,
                decoration: InputDecoration(labelText: 'Tempo de Pausa Longa (minutos)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: longBreakCycleController,
                decoration: InputDecoration(labelText: 'Ciclos antes da Pausa Longa'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: cycleController,
                decoration: InputDecoration(labelText: 'Total de Ciclos Alvo'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Parse the input values
              final newWorkMin = int.tryParse(workController.text) ?? workMinutes;
              final newBreakMin = int.tryParse(breakController.text) ?? breakMinutes;
              final newLongBreakMin = int.tryParse(longBreakController.text) ?? longBreakMinutes;
              final newTargetCycles = int.tryParse(cycleController.text) ?? targetCycles;
              final newLongBreakCycles = int.tryParse(longBreakCycleController.text) ?? cyclesBeforeLongBreak;
              
              // Update the settings
              setState(() {
                workMinutes = newWorkMin > 0 ? newWorkMin : 1;
                breakMinutes = newBreakMin > 0 ? newBreakMin : 1;
                longBreakMinutes = newLongBreakMin > 0 ? newLongBreakMin : 1;
                targetCycles = newTargetCycles > 0 ? newTargetCycles : 1;
                cyclesBeforeLongBreak = newLongBreakCycles > 0 ? newLongBreakCycles : 1;
                
                workDuration = Duration(minutes: workMinutes);
                breakDuration = Duration(minutes: breakMinutes);
                longBreakDuration = Duration(minutes: longBreakMinutes);
                
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

  Color getTomatoColor() {
    switch (currentMode) {
      case "work":
        return const Color(0xFFE53935); // Vermelho forte para trabalho
      case "break":
        return const Color(0xFFE57373); // Vermelho claro para pausa curta
      case "longBreak":
        return const Color(0xFFEF9A9A); // Vermelho mais claro para pausa longa
      default:
        return const Color(0xFFE53935);
    }
  }

  String getModeText() {
    switch (currentMode) {
      case "work":
        return "Trabalho";
      case "break":
        return "Pausa Curta";
      case "longBreak":
        return "Pausa Longa";
      default:
        return "Trabalho";
    }
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
              tomatoColor: getTomatoColor(),
              leafColor: const Color(0xFF4CAF50),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  getModeText(),
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // const SizedBox(height: 5),
                Text(
                  formatTime(remaining),
                  style: const TextStyle(
                    fontSize: 72,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // const SizedBox(height: 5),
                Text(
                  'Ciclo: $cycle / $targetCycles',
                  style: const TextStyle(color: Colors.white, fontSize: 30),
                ),
                // const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: startPause,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(isRunning ? 'Pausar' : 'Iniciar'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: reset,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Resetar'),
                    ),
                  ],
                ),
                // const SizedBox(height: 5),
                TextButton.icon(
                  onPressed: _openSettingsDialog,
                  icon: Icon(Icons.edit, color: Colors.white),
                  label: Text('Editar Configurações', 
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