import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'api_services.dart';
import 'const/colors.dart';
import 'const/images.dart';
import 'const/text_style.dart';
import 'result_page.dart';

// Widget to display the quiz screen
class QuizScreen extends StatefulWidget {
  final String difficulty;

  // Constructor to initialize the quiz screen with a specified difficulty level
  const QuizScreen(this.difficulty, {Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

// State class for the quiz screen widget
class _QuizScreenState extends State<QuizScreen> {
  var currentQuestionIndex = 0;
  int seconds = 60;
  Timer? timer;
  late Future quiz;

  int points = 0;

  var isLoaded = false;

  var optionsList = [];

  var optionsColor = [
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    quiz = getQuiz(widget.difficulty); // Fetch quiz data based on difficulty
    startTimer();
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  // Reset option colors to default
  resetColors() {
    optionsColor = List.filled(5, Colors.white);
  }

  // Start the timer
  startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (seconds > 0) {
          seconds--;
        } else {
          gotoNextQuestion();
        }
      });
    });
  }

  // Move to the next question
  gotoNextQuestion() {
    isLoaded = false;
    currentQuestionIndex++;
    resetColors();
    timer!.cancel();
    seconds = 60;
    startTimer();
  }

  // Navigate to the result screen
  void navigateToResultScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(score: points),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
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
          child: FutureBuilder(
            future: quiz,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data["results"];

                if (isLoaded == false) {
                  optionsList = data[currentQuestionIndex]["incorrect_answers"];
                  optionsList.add(data[currentQuestionIndex]["correct_answer"]);

                  optionsList.shuffle();
                  isLoaded = true;
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Widgets to display timer, score, and question number
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Close button
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(color: lightgrey, width: 2),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                CupertinoIcons.xmark,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          // Timer
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              normalText(
                                color: Colors.white,
                                size: 25,
                                text: "$seconds",
                              ),
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator(
                                  value: seconds / 60,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                ),
                              ),
                            ],
                          ),
                          // Score display
                          Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: lightgrey, width: 4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                normalText(
                                  color: Colors.white,
                                  size: 10,
                                  text: "Score: $points",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Image.asset(ideas, width: 200),
                      const SizedBox(height: 20),
                      // Display question number
                      Align(
                        alignment: Alignment.centerLeft,
                        child: normalText(
                          color: lightgrey,
                          size: 18,
                          text:
                              "Question ${currentQuestionIndex + 1} of ${data.length}",
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Display question text
                      normalText(
                        color: Colors.white,
                        size: 20,
                        text: data[currentQuestionIndex]["question"],
                      ),
                      const SizedBox(height: 20),
                      // Display options for the current question
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: optionsList.length,
                        itemBuilder: (BuildContext context, int index) {
                          var answer =
                              data[currentQuestionIndex]["correct_answer"];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (answer.toString() ==
                                    optionsList[index].toString()) {
                                  optionsColor[index] = Colors.green;
                                  points += 10;
                                } else {
                                  optionsColor[index] = Colors.red;
                                }

                                if (currentQuestionIndex < data.length - 1) {
                                  Future.delayed(const Duration(seconds: 1),
                                      () {
                                    gotoNextQuestion();
                                  });
                                } else {
                                  timer!.cancel();
                                  navigateToResultScreen();
                                }
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              alignment: Alignment.center,
                              width: size.width - 100,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: optionsColor[index],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: headingText(
                                color: blue,
                                size: 18,
                                text: optionsList[index].toString(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              } else {
                // Display a loading indicator while fetching data
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
