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
  try{
    const  String apiKey = 'AIzaSyDT8KFmc5QHXNdbHIpvQjzNlY_G1zs64MU'; // Replace with your Google Cloud API key
    const String apiUrl = 'https://language.googleapis.com/v1/documents:analyzeSentiment?key=$apiKey';

    final Map<String, dynamic> requestBody = {
      'document': {
        'type': 'PLAIN_TEXT',
        'content': text,
      },
    };

    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
      
    );
    if (response.statusCode == 200){
      final Map<String, dynamic> responseJson = json.decode(response.body);
      final double score = responseJson['documentSentiment']['score'].toDouble();
      final String scoreTag = getScoreTag(score);

      return scoreTag;
    } else {
      throw Exception('Failed to analyze sentiments. Status code: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Error analyzing sentiments: $error');
  }
}

String getScoreTag(double score) {
  if (score >= 0.25 && score <=0.5) {
    return 'The entry made is mostly positive.';
  } 
  else if (score >0.5){
    return 'The entry made is very positive.';
  }
  else if (score <= -0.25 && score >=-.5) {
    return 'NEGATIVE';
  } 
  else if(score < -0.5){
    return 'The entry made is very negative.';
  }
  else if(score<0.25 && score>-0.25){
    return 'The entry made is mostly neutral, with positive and negative aspects.';
  }
  else {
    return 'Try writing more about your feelings.';
  }
}
double score(String txt){
  try{
    if (txt == 'The entry made is very positive.'){
      return 1.0;
    }
    else if(txt == 'The entry made is very negative.'){
      return -1.0;
    }
    else if(txt == 'The entry made is mostly positive.'){
     return 0.5;
    }
    else if(txt == 'The entry made is mostly negative.'){
      return -0.5;
    }
    else{
      return 0.0001;
    }
  }
  catch(error){
    throw Exception('$error');
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
                    double emotionScore= score(response);
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
