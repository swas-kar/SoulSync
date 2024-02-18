import 'package:flutter/material.dart';
import '../screens/journal/constants.dart';

import '../screens/journal/journal_entry_screen.dart';

class BackView extends StatefulWidget {
  final int monthIndex;

  const BackView({
    Key? key,
    required this.monthIndex,
  }) : super(key: key);

  @override
  _BackViewState createState() => _BackViewState();
}

class _BackViewState extends State<BackView> {
  int? selectedDay;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 8.0),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '${widget.monthIndex}',
                  textScaleFactor: 2.5,
                ),
                const SizedBox(height: 5.0),
                Text(
                  months[widget.monthIndex]!.keys.toList()[0],
                  textScaleFactor: 2.0,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20.0),
                // dates
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: months[widget.monthIndex]!.values.toList()[0],
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1 / 1,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemBuilder: (_, i) {
                    int day = i + 1;
                    String cDay = day < 10 ? '0$day' : '$day';
                    String cMonth =
                        widget.monthIndex < 10 ? '0${widget.monthIndex}' : '${widget.monthIndex}';
                    DateTime date = DateTime.parse('2024-$cMonth-$cDay');

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDay = day;
                        });
                      },
                      child: Tooltip(
                        message: 'Select Day $day',
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedDay == day ? Colors.blue : Colors.transparent,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Center(
                            child: Text(
                              '$day',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: date.weekday == DateTime.sunday
                                    ? Colors.red
                                    : date.weekday == DateTime.saturday
                                        ? Colors.blue
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (selectedDay != null)
                  SizedBox(
                    height: 100.0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JournalEntryScreen(
                              monthIndex: widget.monthIndex,
                              selectedDay: selectedDay,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 50.0,
                              height: 50.0,
                              decoration: const BoxDecoration(
                                color: Colors.black87,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.mode_edit_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const Text(
                  'Select a date to write',
                  textScaleFactor: 0.8,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
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
