import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pomodoro/pomodoro_painter.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

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
  
  // Alarm related properties
  bool alarmEnabled = true;
  String alarmType = "alarm"; // "alarm", "notification", "ringtone"

  @override
  void dispose() {
    timer?.cancel();
    // Certifique-se de parar qualquer som ao fechar o app
    FlutterRingtonePlayer().stop();
    super.dispose();
  }

  void startPause() {
    if (isRunning) {
      timer?.cancel();
    } else {
      timer = Timer.periodic(Duration(seconds: 1), (_) {
        if (remaining.inSeconds > 0) {
          setState(() => remaining -= Duration(seconds: 1));
        } else {
          timer?.cancel();
          
          // Tocar o alarme quando o tempo acabar
          if (alarmEnabled) {
            _playSystemSound();
          }

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

  void _playSystemSound() async {
    try {
      switch (alarmType) {
        case "alarm":
          await FlutterRingtonePlayer().play(
            android: AndroidSounds.alarm,
            ios: IosSounds.alarm,
            looping: false,
            volume: 1.0,
            asAlarm: true,
          );
          break;
        case "notification":
          await FlutterRingtonePlayer().play(
            android: AndroidSounds.notification,
            ios: IosSounds.receivedMessage,
            looping: false,
            volume: 1.0,
          );
          break;
        case "ringtone":
          await FlutterRingtonePlayer().play(
            android: AndroidSounds.ringtone,
            ios: IosSounds.bell,
            looping: false,
            volume: 1.0,
          );
          break;
      }
      
      // Parar o som após 3 segundos
      Future.delayed(Duration(seconds: 3), () {
        FlutterRingtonePlayer().stop();
      });
    } catch (e) {
      print('Erro ao tocar o som: $e');
    }
  }

  void reset() {
    timer?.cancel();
    FlutterRingtonePlayer().stop();
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

    // Variáveis locais para o diálogo
    bool localAlarmEnabled = alarmEnabled;
    String localAlarmType = alarmType;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
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
                  SwitchListTile(
                    title: Text('Som ao finalizar'),
                    value: localAlarmEnabled,
                    onChanged: (value) {
                      setStateDialog(() {
                        localAlarmEnabled = value;
                      });
                    },
                  ),
                  if (localAlarmEnabled)
                    Column(
                      children: [
                        ListTile(
                          title: Text('Tipo de som'),
                          contentPadding: EdgeInsets.symmetric(horizontal: 0),
                        ),
                        RadioListTile<String>(
                          title: Text('Alarme'),
                          value: 'alarm',
                          groupValue: localAlarmType,
                          onChanged: (value) {
                            setStateDialog(() {
                              localAlarmType = value!;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: Text('Notificação'),
                          value: 'notification',
                          groupValue: localAlarmType,
                          onChanged: (value) {
                            setStateDialog(() {
                              localAlarmType = value!;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: Text('Toque'),
                          value: 'ringtone',
                          groupValue: localAlarmType,
                          onChanged: (value) {
                            setStateDialog(() {
                              localAlarmType = value!;
                            });
                          },
                        ),
                      ],
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
                    
                    // Atualizar configurações de som
                    alarmEnabled = localAlarmEnabled;
                    alarmType = localAlarmType;
                    
                    // Reset the timer
                    reset();
                  });
                  
                  Navigator.pop(context);
                },
                child: Text('Salvar'),
              ),
            ],
          );
        },
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

  String getAlarmTypeIcon() {
    switch (alarmType) {
      case "alarm":
        return "Alarme";
      case "notification":
        return "Notificação";
      case "ringtone":
        return "Toque";
      default:
        return "Alarme";
    }
  }

  IconData getAlarmIcon() {
    if (!alarmEnabled) return Icons.volume_off;
    
    switch (alarmType) {
      case "alarm":
        return Icons.access_alarm;
      case "notification":
        return Icons.notifications;
      case "ringtone":
        return Icons.ring_volume;
      default:
        return Icons.volume_up;
    }
  }

  void _testarSom() {
    if (alarmEnabled) {
      _playSystemSound();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Testando som (${getAlarmTypeIcon()})'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Som está desativado'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pomodoro'),
        actions: [
          IconButton(
            icon: Icon(getAlarmIcon()),
            onPressed: () {
              setState(() {
                alarmEnabled = !alarmEnabled;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(alarmEnabled 
                    ? 'Som ativado (${getAlarmTypeIcon()})' 
                    : 'Som desativado'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
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
                Text(
                  formatTime(remaining),
                  style: const TextStyle(
                    fontSize: 72,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Ciclo: $cycle / $targetCycles',
                  style: const TextStyle(color: Colors.white, fontSize: 30),
                ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: _openSettingsDialog,
                      icon: Icon(Icons.edit, color: Colors.white),
                      label: Text('Editar Configurações', 
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    // TextButton.icon(
                    //   onPressed: _testarSom,
                    //   icon: Icon(Icons.music_note, color: Colors.white),
                    //   label: Text('Testar Som', 
                    //     style: TextStyle(color: Colors.white),
                    //   ),
                    // ),
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