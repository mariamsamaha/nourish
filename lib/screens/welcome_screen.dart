import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00A86B), Color(0xFF00784E)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App icon box
                Container(
                  height: height * 0.13,
                  width: height * 0.13,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.eco, color: Colors.green, size: height * 0.07),
                ),
                SizedBox(height: height * 0.02),

                // App name
                Text(
                  "Nourish",
                  style: TextStyle(
                    fontSize: height * 0.03,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: height * 0.01),

                // Tagline
                Text(
                  "Save money, rescue food,\nmake a real impact",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.yellowAccent,
                    fontSize: height * 0.022,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                SizedBox(height: height * 0.06),

                // Join savers
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.06,
                    vertical: height * 0.015,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: const [
                          CircleAvatar(radius: 12, backgroundColor: Colors.pink),
                          Positioned(
                            left: 15,
                            child: CircleAvatar(radius: 12, backgroundColor: Colors.blue),
                          ),
                          Positioned(
                            left: 30,
                            child: CircleAvatar(radius: 12, backgroundColor: Colors.purple),
                          ),
                        ],
                      ),
                      SizedBox(width: width * 0.15),
                      const Text(
                        "Join 50K+ savers",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: height * 0.06),

                // Get Started
                SizedBox(
                  width: width * 0.7,
                  height: height * 0.065,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.signup);

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Get Started →",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                SizedBox(height: height * 0.02),

                // I have account
                SizedBox(
                  width: width * 0.7,
                  height: height * 0.065,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "I have an account",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
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
