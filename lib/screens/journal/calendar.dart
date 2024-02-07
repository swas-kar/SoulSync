import 'dart:math';
import 'package:flutter/material.dart';
import '../../widgets/front_view.dart';
import '../../widgets/back_view.dart';
import '../../widgets/action_buttons.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> with TickerProviderStateMixin {
  bool isFrontView = true;

  late AnimationController controller;

  switchView() {
    setState(() {
      if (isFrontView) {
        controller.forward();
      } else {
        controller.reverse();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/blur1.jpeg', 
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: const Text('Write your entry for today!'),
                  centerTitle: true,
                  backgroundColor: Colors.transparent, 
                  elevation: 0, 
                  actions: [

                    IconButton(
                      icon: Icon(Icons.home),
                      onPressed: () {
                        Navigator.popUntil(context, ModalRoute.withName('/'));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),

                DropdownButton(
                  value: '2024',
                  items: const [
                    DropdownMenuItem(value: '2024', child: Text('2024'))
                  ],
                  onChanged: (value) {},
                ),
                const SizedBox(height: 30.0),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 22.0),
                    child: PageView.builder(
                      controller: PageController(
                        initialPage: 0,
                        viewportFraction: 0.78,
                      ),
                      scrollDirection: Axis.horizontal,
                      itemCount: 12, 
                      itemBuilder: (_, i) => AnimatedBuilder(
                        animation: controller,
                        builder: (_, child) {
                          if (controller.value >= 0.5) {
                            isFrontView = false;
                          } else {
                            isFrontView = true;
                          }

                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(controller.value * pi),
                            alignment: Alignment.center,
                            child: isFrontView
                                ? FrontView(monthIndex: i + 1)
                                : Transform(
                                    transform: Matrix4.rotationY(pi),
                                    alignment: Alignment.center,
                                    child: BackView(
                                      monthIndex: i + 1,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                ActionButtons(change: switchView),
                const SizedBox(height: 75.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
