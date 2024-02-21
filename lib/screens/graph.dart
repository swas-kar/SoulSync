import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(const GraphPage());

class GraphPage extends StatefulWidget {
  const GraphPage({Key? key}) : super(key: key);

  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  int x = 7; // Default value for x

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Sentiment Graph Example'),
        ),
        body: FutureBuilder<Map<String, List<double>>>(
          future: fetchSentimentValuesForWeek(
              DateTime.now().subtract(const Duration(days: 6)), DateTime.now(), x),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return GraphWidget(data: snapshot.data ?? {});
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showDialog(); // Show dialog to choose x value
          },
          child: Icon(Icons.settings),
        ),
      ),
    );
  }

  Future<void> _showDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Choose the value of x'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 7);
              },
              child: const Text('7'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 14);
              },
              child: const Text('14'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 30);
              },
              child: const Text('30'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          x = value;
        });
      }
    });
  }

  Future<Map<String, List<double>>> fetchSentimentValuesForWeek(
      DateTime startDate, DateTime endDate, int x) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('journal_entries')
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: endDate)
          .orderBy('timestamp', descending: true)
          .limit(x)
          .get();

      Map<String, List<double>> sentimentValues = {};

      for (QueryDocumentSnapshot<Map<String, dynamic>> document in querySnapshot.docs) {
        DateTime timestamp = DateTime(DateTime.now().year, document['monthIndex'], document['selectedDay']);
        String key = '${timestamp.day}/${timestamp.month}';
        double sentimentScore = document['sentimentScore'].toDouble();

        if (sentimentValues.containsKey(key)) {
          sentimentValues[key]!.add(sentimentScore);
        } else {
          sentimentValues[key] = [sentimentScore];
        }
      }

      Map<String, List<double>> sortedSentimentValues = Map.fromEntries(
        sentimentValues.entries.toList()
          ..sort((b, a) {
            var aParts = a.key.split('/');
            var bParts = b.key.split('/');
            var aDate = DateTime(DateTime.now().year, int.parse(aParts[1]), int.parse(aParts[0]));
            var bDate = DateTime(DateTime.now().year, int.parse(bParts[1]), int.parse(bParts[0]));
            return bDate.compareTo(aDate);
          }),
      );

      return sortedSentimentValues;
    } catch (error) {
      throw Exception('Error fetching data: $error');
    }
  }
}

class GraphWidget extends StatelessWidget {
  final Map<String, List<double>> data;

  const GraphWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          barGroups: _generateBars(),
          titlesData: FlTitlesData(
            leftTitles: SideTitles(showTitles: false),
            bottomTitles: SideTitles(
              showTitles: false,
            ),
            rightTitles: SideTitles(showTitles: false),
            topTitles: SideTitles(showTitles: false),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBars() {
    return List.generate(data.length, (index) {
      List<double> scores = data.values.elementAt(index);
      double averageScore = scores.reduce((a, b) => a + b) / scores.length;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            y: averageScore,
            colors: [Colors.blue],
          ),
        ],
      );
    });
  }
}
