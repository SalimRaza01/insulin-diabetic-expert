import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(const MyApp2());

class MyApp2 extends StatelessWidget {
  const MyApp2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basal Delivery',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const BasalDeliveryScreen(),
    );
  }
}

class DeliveryEntry {
  final DateTime time;
  final double dose;

  DeliveryEntry({required this.time, required this.dose});
}

class DeliverySchedule {
  final List<DeliveryEntry> entries;
  final String id;

  DeliverySchedule({required this.entries, required this.id});
}

class BasalDeliveryScreen extends StatefulWidget {
  const BasalDeliveryScreen({super.key});

  @override
  State<BasalDeliveryScreen> createState() => _BasalDeliveryScreenState();
}

class _BasalDeliveryScreenState extends State<BasalDeliveryScreen> {
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  final doseController = TextEditingController();
  final intervalController = TextEditingController(text: '15');
  final List<DeliverySchedule> deliverySchedules = [];

  Future<void> pickTime({required bool isStart}) async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (result != null) {
      setState(() {
        if (isStart) {
          startTime = result;
        } else {
          endTime = result;
        }
      });
    }
  }

  void calculateAndStartDelivery() {
    if (startTime == null || endTime == null || doseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields.")),
      );
      return;
    }

    final totalDose = double.tryParse(doseController.text);
    final intervalMinutes = int.tryParse(intervalController.text) ?? 15;

    if (totalDose == null || totalDose <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid dose.")),
      );
      return;
    }

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, startTime!.hour, startTime!.minute);
    var end = DateTime(now.year, now.month, now.day, endTime!.hour, endTime!.minute);

    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }

    final durationMinutes = end.difference(start).inMinutes;
    final intervals = (durationMinutes / intervalMinutes).floor();
    final dosePerPulse = totalDose / intervals;

    final entries = <DeliveryEntry>[];
    var current = start;

    while (current.isBefore(end)) {
      entries.add(DeliveryEntry(time: current, dose: dosePerPulse));
      current = current.add(Duration(minutes: intervalMinutes));
    }

    final schedule = DeliverySchedule(
      entries: entries,
      id: DateTime.now().toIso8601String(),
    );

    setState(() {
      deliverySchedules.add(schedule);
    });

    startRealTimeDelivery(schedule);
  }

  void startRealTimeDelivery(DeliverySchedule schedule) {
    for (int i = 0; i < schedule.entries.length; i++) {
      final entry = schedule.entries[i];
      final now = DateTime.now();
      final delay = entry.time.difference(now);

      if (delay.isNegative) continue; // Skip missed

      Future.delayed(delay, () {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "[${schedule.id.substring(11, 19)}] Delivered ${entry.dose.toStringAsFixed(5)} units at "
              "${entry.time.hour.toString().padLeft(2, '0')}:${entry.time.minute.toString().padLeft(2, '0')}",
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    doseController.dispose();
    intervalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basal Delivery')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => pickTime(isStart: true),
                    child: Text(startTime == null
                        ? "Select Start Time"
                        : "Start: ${startTime!.format(context)}"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => pickTime(isStart: false),
                    child: Text(endTime == null
                        ? "Select End Time"
                        : "End: ${endTime!.format(context)}"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: doseController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Total Dose (units)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: intervalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Interval (minutes)',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: calculateAndStartDelivery,
              icon: const Icon(Icons.add_alarm),
              label: const Text("Add Delivery Schedule"),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: deliverySchedules.length,
                itemBuilder: (context, i) {
                  final schedule = deliverySchedules[i];
                  return ExpansionTile(
                    title: Text("Schedule ${i + 1} [${schedule.id.substring(11, 19)}]"),
                    children: schedule.entries.map((entry) {
                      final formattedTime =
                          "${entry.time.hour.toString().padLeft(2, '0')}:${entry.time.minute.toString().padLeft(2, '0')}";
                      return ListTile(
                        title: Text("Time: $formattedTime"),
                        subtitle: Text("Dose: ${entry.dose.toStringAsFixed(5)} units"),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}