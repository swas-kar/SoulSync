import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'constants.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JournalEntryScreen extends StatefulWidget {
  final int monthIndex;
  final int? selectedDay;

  const JournalEntryScreen({
    Key? key,
    required this.monthIndex,
    required this.selectedDay,
  }) : super(key: key);

  @override
  _JournalEntryScreenState createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final TextEditingController _journalController = TextEditingController();
  String _currentPrompt = '';
  String? _emotionScore;
  int? emotionScore;
  @override
  void initState() {
    super.initState();
    _generateRandomPrompt();
    _fetchExistingEntry();
  }

  void _generateRandomPrompt() {
    List<String> prompts = [
      'Write a thank you note to yourself.',
      'Express gratitude for five things you use daily.',
      'Are you an early bird or night owl? What do you like most about this part of the day?',
      'What makes you happy to be alive?',
      'How do you want to be remembered?',
      'What are the 3 things you love about yourself?',
      'How do you spend your time with your family on weekends?',
      'Describe your favorite memory with your friends.',
      'How have you seen yourself progress in the past week?',
      'What are you excited about doing this weekend?',
      'What are the five things you love about the world',
      'How can you make this week a better one that last?',
      'Appreciate a stranger that was helping someone in need',
      'Write about what you need in your life right now',
      'Write about something that you enjoy doing in your free time',
      'Write about a time you were brave to challenge yourself',
      'What do you think is your biggest personal success',
      'What is one part of your life that you will not trade for anything?',
      'Look around you and find something that you can feel grateful for',
    ];

    
    _currentPrompt = prompts[Random().nextInt(prompts.length)];
  }

  void _fetchExistingEntry() async {
    try {
      
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('journal_entries')
          .where('monthIndex', isEqualTo: widget.monthIndex)
          .where('selectedDay', isEqualTo: widget.selectedDay)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _journalController.text = querySnapshot.docs.first['entry'];
        });
      } else {
        _journalController.text = _currentPrompt;
      }
    } catch (error) {
      print('Error fetching existing entry: $error');
    }
  }

  Future<String> _analyzeSentiments(String text) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse("https://api.meaningcloud.com/sentiment-2.1"));
      request.fields.addAll({
        'key': 'bcf84fa1e219734bf743bdd3ef09fefc',
        'txt': text,
        'lang': 'en',
      });

      var response = await request.send();

      if (response.statusCode == 200) {
        final String rawResponse = await http.Response.fromStream(response).then((value) => value.body);

        final Map<String, dynamic> responseJson = json.decode(rawResponse);
        String scoreTag = responseJson['score_tag'];

        String result = '';
        if (scoreTag == 'P') {
          result = 'The response submitted is mostly positive.';
        } else if (scoreTag == 'N') {
          result = 'The response submitted is mostly negative.';
        } else if (scoreTag == 'NEU') {
          result = 'The response submitted is neutral, with both highs and lows.';
        } else if (scoreTag == 'P+') {
          result = 'The response submitted is very positive.';
        } else if (scoreTag == 'N+') {
          result = 'The response submitted is very negative.';
        } else {
          result = 'Please write a little bit more about your feelings.';
        }

        return result;
      } else {
        print('MeaningCloud API Error: ${response.reasonPhrase}');
        return '';
      }
    } catch (error) {
      print('Error analyzing sentiment: $error');
      return '';
    }
  }
  double mapSentimentValueToScore(String sentimentValue) {
    // You may customize this mapping based on your sentiment value interpretation
    if (sentimentValue == 'The response submitted is very positive.') {
      return 1.0;
    } else if (sentimentValue == 'The response submitted is very negative.') {
      return -1.0;
    }
    else if (sentimentValue == 'The response submitted is mostly positive.'){
      return 0.5;
    }
    else if (sentimentValue == 'The response submitted is mostly negative.'){
      return -0.5;
    }
     else {
      return 0.0001; 
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Journal Entry - ${months[widget.monthIndex]!.keys.toList()[0]} - ${widget.selectedDay}'),
      ),
      body: Stack(
        children: [
          
          Image.asset(
            'lib/assets/blur1.jpeg', 
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          
          Opacity(
            opacity: 0.8, 
            child: Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height * 0.75,
            ),
          ),
          Column(
            children: [
              
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _generateRandomPrompt();
                      _journalController.text = _currentPrompt;
                    });
                  },
                  child: const Text('Generate Prompt'),
                ),
              ),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _journalController,
                    maxLines: null, 
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Write your journal entry...',
                    ),
                  ),
                ),
              ),

              ElevatedButton(
                onPressed: () async {
                  try {
                    String journalEntry = _journalController.text;
                    String response = await _analyzeSentiments(journalEntry);
                    double emotionScore= mapSentimentValueToScore(response);
                    setState(() {
                      _emotionScore=response;
                    });
                    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
                        .collection('journal_entries')
                        .where('monthIndex', isEqualTo: widget.monthIndex)
                        .where('selectedDay', isEqualTo: widget.selectedDay)
                        .get();

                    if (querySnapshot.docs.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('journal_entries')
                          .doc(querySnapshot.docs.first.id)
                          .update({
                        'entry': journalEntry,
                        'sentimentScore': emotionScore,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                    } else {
                      
                      await FirebaseFirestore.instance.collection('journal_entries').add({
                        'monthIndex': widget.monthIndex,
                        'selectedDay': widget.selectedDay,
                        'entry': journalEntry,
                        'sentimentScore': emotionScore,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                    }

                    
                    

                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sentiment Analysis: $response'),
                        duration: const Duration(seconds: 2),
                      ),
                    );

                    
                    print('Submitted input: $journalEntry');
                  } catch (error) {
                    print('Error: $error');
                  }
                },
                child: const Text('Submit'),
              ),
              
              if (_emotionScore != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Overall feelings: $_emotionScore',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
