import 'package:flutter/material.dart';
import 'dart:async';

class MeditationPage extends StatefulWidget {
  
  const MeditationPage({Key? key}) : super(key: key);
  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {
  int _seconds = 0;
  String _instruction = '';
  late Timer _timer;
  int dir=0;
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneSecond, (timer) {
      if (_seconds == 0) {
        // Switch between breathe in and breathe out
        setState(() {
          if (_instruction == '') {
            _instruction = 'Exhale, part your lips, make a whooshing sound';
            _seconds = 6;
          } else if (_instruction == 'Exhale, part your lips, make a whooshing sound') {
            _instruction = 'Inhale silently through your left nostril, count to four';
            _seconds= 1;
            _seconds = 4;
          } else if (_instruction == 'Inhale silently through your left nostril, count to four') {
            _instruction = 'Hold your breath for seven seconds';
              dir=1;
             _seconds= 1;
            _seconds = 7;
          } else if (_instruction == 'Hold your breath for seven seconds' ) {
            _instruction = 'Exhale through your mouth, make a whooshing sound, count to eight';
            _seconds = 1;
            _seconds = 8;
          } else if (_instruction == 'Exhale through your mouth, make a whooshing sound, count to eight' && dir==1) {
            _instruction = 'Inhale silently through your right nostril, count to four';
            _seconds= 1;
            _seconds = 4;
          }
          else if (_instruction == 'Inhale silently through your right nostril, count to four') {
            _instruction = 'Hold your breath for seven seconds';
            dir=0;
            _seconds= 1;
            _seconds = 7;
          }
          else if (_instruction == 'Hold your breath for seven seconds' ) {
            _instruction = 'Exhale through your mouth, make a whooshing sound, count to eight';
            _seconds = 1;
            _seconds = 8;
          }
          else if (_instruction == 'Exhale through your mouth, make a whooshing sound, count to eight' && dir==0) {
            _instruction = 'Inhale silently through your left nostril, count to four';
            _seconds= 1;
            _seconds = 4;
          }
        });
      } else {
        setState(() {
          _seconds--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation Timer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blue,
                  width: 8.0,
                ),
              ),
              child: Center(
                child: Text(
                  '$_seconds',
                  style: const TextStyle(fontSize: 40,
                  color: Colors.yellow,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _instruction,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18,color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}