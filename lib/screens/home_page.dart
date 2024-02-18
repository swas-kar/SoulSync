import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_soul_sync/screens/bot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'journal/calendar.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'lib/assets/worskspace.jpeg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AppBar(
                title: const Text(
                  "SoulSync"),
                centerTitle: true,
                elevation: 0,
                backgroundColor: const Color.fromARGB(0, 246, 241, 241),
              ),
              const SizedBox(height: 30),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: const Text(
                        "What task do you want to perform today?",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    OptionBox(
                      label: 'Meditate',
                      onTap: () {
                        // Handle 'Meditate' button tap
                      },
                    ),
                    OptionBox(
                      label: 'Journaling',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CalendarPage(),
                          ),
                        );
                      },
                    ),
                    OptionBox(
                      label: 'Insights',
                      onTap: () {
                        // Handle 'Insights' button tap
                      },
                    ),
                    OptionBox(
                      label: 'SoulSync Buddy',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
           Positioned(
            bottom: 10,
            right: 10,
            child: LogoutButton(),
          ),
        ],
      ),
    );
  }
}

class OptionBox extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const OptionBox({
    Key? key,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 50, 29, 47),
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 100.0,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Increase the opacity by adjusting the alpha value (0-255)
    Color buttonColor = const Color.fromARGB(200, 0, 0, 0);

    return ElevatedButton(
      onPressed: () {
        _logout(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        shadowColor: Colors.transparent,
      ),
      child: const Text(
        'Sign Out',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await _auth.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', false); // Update login status to false
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      // Handle sign-out error
      print(e.toString());
    }
  }
}
