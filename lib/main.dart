// Import necessary packages and files
// ignore_for_file: must_be_immutable

import 'dart:io';
import 'package:provider/provider.dart'; // Provider package for state management

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiz/const/colors.dart';

import 'const/images.dart';
import 'const/text_style.dart';
import 'quiz_screen.dart';

// Main entry point of the application
main() {
  // Configure system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: blue),
  );

  // Run the app using the App widget as the root widget
  runApp(const App());
}

// ChangeNotifier class to manage and notify listeners of difficulty changes
class DifficultyNotifier extends ChangeNotifier {
  String _selectedDifficulty = 'easy';
  String get selectedDifficulty => _selectedDifficulty;

  // Update the difficulty and notify listeners
  void updateDifficulty(String newDifficulty) {
    _selectedDifficulty = newDifficulty;
    notifyListeners();
  }
}

// Root widget of the application
class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider(
        create: (_) =>
            DifficultyNotifier(), // Provide DifficultyNotifier to its descendants
        child: QuizApp(), // Root widget of the app
      ),
      theme: ThemeData(
        fontFamily: "quick", // Set the default font family for the entire app
      ),
      title: "Areno Quiz App",
    );
  }
}

// Widget representing the main content of the application
class QuizApp extends StatelessWidget {
  late String selectedDifficulty = 'easy';

  QuizApp({super.key}); // Default difficulty level

  // Method to close the application
  void _closeApp() {
    exit(0); // This will close the application
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var difficultyNotifier = context.watch<DifficultyNotifier>();

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [blue, darkBlue],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Close button
              GestureDetector(
                onTap: _closeApp,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                  margin: const EdgeInsets.all(10),
                  child: IconButton(
                    onPressed: _closeApp,
                    icon: const Icon(
                      CupertinoIcons.clear,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
              // App branding and information
              Image.asset(balloon2),
              const SizedBox(height: 20),
              normalText(
                color: lightgrey,
                size: 18,
                text: "Welcome to Areno Innovations",
              ),
              headingText(
                color: Colors.white,
                size: 32,
                text: "Komodo Trivia",
              ),
              const SizedBox(height: 20),
              normalText(
                color: lightgrey,
                size: 16,
                text:
                    "Do you feel confident? Here you'll face our most difficult questions!",
              ),
              const SizedBox(height: 20),
              // Dropdown menu for selecting difficulty level
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                margin: const EdgeInsets.only(bottom: 20),
                width: MediaQuery.of(context).size.width -
                    size.width * 0.7, // Adjust width responsively
                child: Center(
                  child: DropdownButton<String>(
                    value: difficultyNotifier.selectedDifficulty,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color:
                          Colors.deepPurple, // Changed dropdown menu icon color
                    ),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurple,
                    ),
                    onChanged: (String? newValue) {
                      difficultyNotifier.updateDifficulty(newValue ?? 'easy');
                    },
                    items: <String>['easy', 'medium', 'hard']
                        .map<DropdownMenuItem<String>>(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.deepPurple),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
              ),
              const Spacer(),
              // Start quiz button
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(selectedDifficulty),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    alignment: Alignment.center,
                    width: size.width - 100,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: headingText(
                      color: blue,
                      size: 18,
                      text: "Start the Quiz",
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
