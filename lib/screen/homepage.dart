import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:timeline_sample/exceptions/exception.dart';
import 'package:timeline_sample/widgets/timeline.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String text = "";

  bool isSnackBarActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.grey[200],
          height: 200,
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  height: 50, width: 200, child: Text("Selected Time: $text")),
              const Icon(
                Icons.arrow_drop_down,
                size: 30,
              ),
              Expanded(
                child: CustomTimeLine(
                  onTimeSelected: (String time) {
                    setState(
                      () {
                        text = time;
                      },
                    );
                  },
                  onError: (dynamic e) {
                    if (e is DurationException) {
                      if (!isSnackBarActive) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.message),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                        isSnackBarActive = true;
                        Future.delayed(const Duration(seconds: 1), () {
                          isSnackBarActive = false;
                        });
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
