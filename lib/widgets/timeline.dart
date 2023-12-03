import 'dart:math';

import 'package:flutter/material.dart';
import 'package:list_wheel_scroll_view_nls/list_wheel_scroll_view_nls.dart';

class Booking {
  final String startTime;
  final String endTime;

  Booking({required this.startTime, required this.endTime});
}

class CustomTimeLine extends StatefulWidget {
  CustomTimeLine({super.key, required this.onTimeSelected});

  Function(String time) onTimeSelected;

  @override
  State<CustomTimeLine> createState() => _CustomTimeLineState();
}

class _CustomTimeLineState extends State<CustomTimeLine> {
  late FixedExtentScrollController scrollController =
      FixedExtentScrollController(
    initialItem: 0,
  );

  int currentScale = 1;

  List<Booking> booked = [
    Booking(startTime: "00:00", endTime: "01:00"),
    Booking(startTime: "01:00", endTime: "02:00"),
    Booking(startTime: "08:00", endTime: "09:00"),
  ] as List<Booking>;

  List<String> _list_to_display = [];

  int currentIndex = 0;
  int numberOfSubdivision = 1;

  double totalWidth = 100;

  double width = 80;

  @override
  void initState() {
    super.initState();

    // width = totalWidth / (numberOfSubdivision + 1);

    totalWidth = (numberOfSubdivision + 1) * width;

    print("width: $width");

    scrollController.addListener(() {});

    _list_to_display = getTimes();
    // finding first available slot
    int firstAvailableSlot = getNextAvailableTime(0, _list_to_display.length);

    scrollController =
        FixedExtentScrollController(initialItem: firstAvailableSlot);
  }

  List<String> getTimes() {
    List<String> timeStrings = [];

    String startTime = "00:00";

    int totalTime = 25;

    int totalDivision =
        (totalTime * (numberOfSubdivision + 1)) - numberOfSubdivision;

    for (int i = 0; i < totalDivision; i++) {
      String time = startTime;
      timeStrings.add(time);

      int hour = int.parse(time.split(":")[0]);
      int minute = int.parse(time.split(":")[1]);

      int newMinute = minute + 60 ~/ (numberOfSubdivision + 1);

      if (newMinute >= 60) {
        hour += 1;
        minute = newMinute - 60;
      } else {
        minute = newMinute;
      }

      startTime =
          "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
    }

    return timeStrings;
  }

  String getTimeText(String time) {
    int hour = int.parse(time.split(":")[0]);
    int minute = int.parse(time.split(":")[1]);

    String ampm = "AM";

    if (hour == 24) {
      ampm = "AM";
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
      ampm = "PM";
    } else if (hour == 12) {
      ampm = "PM";
    } else if (hour == 0) {
      hour = 12;
    }

    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $ampm";
  }

  int getNextAvailableTime(int start, int end) {
    print("start: $start end: $end");

    List<String> _availableTimes = [];

    for (int i = start; i < end; i++) {
      _availableTimes.add(_list_to_display[i]);
    }

    for (int i = start; i < end; i++) {
      String time = _list_to_display[i];

      List<Booking> _booked = booked;

      if (_booked.isNotEmpty) {
        _booked.forEach((element) {
          // getting range of time between start and end time
          int startIndex = _list_to_display.indexOf(element.startTime);
          int endIndex = _list_to_display.indexOf(element.endTime);

          print("startIndex: $startIndex endIndex: $endIndex");

          for (int i = startIndex; i < endIndex; i++) {
            print("i: ${_list_to_display[i]}");
            _availableTimes.remove(_list_to_display[i]);
          }
        });
      }
    }

    int firstAvailableSlot = _list_to_display.indexOf(_availableTimes.first);

    setState(() {
      currentIndex = firstAvailableSlot;
    });

    return firstAvailableSlot;
  }

  int getBarHeight(int i) {
    // Checking if the time is the correctBar
    String time = _list_to_display[i];

    if (time.split(":")[1] == "00") {
      return 25;
    } else {
      if (isAlternateBars(i)) {
        return 25;
      } else {
        return 15;
      }
    }
  }

  bool isAlternateBars(int i) {
    // Checking if the time is the correctBar
    String time = _list_to_display[i];

    if (time.split(":")[1] == "00") {
      return true;
    } else {
      if (numberOfSubdivision % 2 == 0) {
        return false;
      } else {
        // Checking if the time is the alternate bar
        int minute = int.parse(time.split(":")[1]);

        for (int i = 1; i <= numberOfSubdivision; i++) {
          if (i % 2 == 0) {
            if (minute == (60 ~/ (numberOfSubdivision + 1)) * i) {
              return true;
            }
          }
        }

        return false;
      }
    }
  }

  Widget getTimeline(Color firstColor, Color secondColor, int i) {
    Widget timelineContainer;
    if (i == 0) {
      timelineContainer = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 5,
            width: (width / 2) + 1,
            color: secondColor,
          )
        ],
      );
    } else if (i == _list_to_display.length - 1) {
      timelineContainer = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 5,
            width: (width / 2) + 1,
            color: secondColor,
          )
        ],
      );
    } else {
      timelineContainer = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 5,
            width: (width / 2),
            color: firstColor,
          ),
          Container(
            height: 5,
            width: (width / 2),
            color: secondColor,
          )
        ],
      );
    }
    Widget widget = Container(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          timelineContainer,
          Container(
            width: 2,
            height: getBarHeight(i).toDouble(),
            color: i == currentIndex ? Colors.black : Colors.grey,
          ),
          Text(
            getTimeText(_list_to_display[i]),
            style: TextStyle(
              fontWeight:
                  i == currentIndex ? FontWeight.bold : FontWeight.normal,
              color: (_list_to_display[i].split(":")[1] == "00") ||
                      isAlternateBars(i)
                  ? Colors.black
                  : Colors.transparent,
              fontSize: (_list_to_display[i].split(":")[1] == "00") ||
                      (isAlternateBars(i))
                  ? 15
                  : 0,
            ),
          ),
        ],
      ),
    );

    return widget;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _list = [];

    Map<String, Widget> _map = {};

    for (var element in booked) {
      String startTime = element.startTime;
      String endTime = element.endTime;

      int startIndex = _list_to_display.indexOf(startTime);
      int endIndex = _list_to_display.indexOf(endTime);

      // print("startIndex: $startIndex endIndex: $endIndex");
      for (int i = startIndex + 1; i < endIndex; i++) {
        _map[_list_to_display[i]] = getTimeline(Colors.red, Colors.red, i);
      }

      // Checking if start time is already end time of some other booking
      List<Booking> _booked =
          booked.where((element) => element.endTime == startTime).toList();

      if (_booked.isNotEmpty) {
        _map[startTime] = getTimeline(Colors.red, Colors.red, startIndex);
      } else {
        _map[startTime] = getTimeline(Colors.grey, Colors.red, startIndex);
      }

      // Checking if end time is already start time of some other booking
      _booked =
          booked.where((element) => element.startTime == endTime).toList();

      if (_booked.isNotEmpty) {
        _map[endTime] = getTimeline(Colors.red, Colors.red, endIndex);
      } else {
        _map[endTime] = getTimeline(Colors.red, Colors.grey, endIndex);
      }
    }

    _list = _list_to_display.map(
      (e) {
        if (_map.containsKey(e)) {
          return _map[e]!;
        } else {
          return getTimeline(
              Colors.grey, Colors.grey, _list_to_display.indexOf(e));
        }
      },
    ).toList();

    return Container(
      width: double.infinity,
      child: GestureDetector(
        onScaleUpdate: (details) {
          setState(
            () {
              currentScale = details.scale.toInt();
              if (currentScale % 2 == 0) {
                return;
              }
              if (currentScale > 0) {
                numberOfSubdivision = min(5, currentScale);
              } else {
                numberOfSubdivision = 1;
              }
              totalWidth = (numberOfSubdivision + 1) * width;
              _list_to_display = getTimes();

              widget
                  .onTimeSelected(getTimeText(_list_to_display[currentIndex]));
            },
          );
        },
        child: ListWheelScrollViewX(
          controller: scrollController,
          physics: const FixedExtentScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemExtent: totalWidth / (numberOfSubdivision + 1),
          diameterRatio: 100,
          perspective: 0.01,
          onSelectedItemChanged: (index) {
            setState(() {
              currentIndex = index;
              widget.onTimeSelected(getTimeText(_list_to_display[index]));
            });
          },
          children: _list,
        ),
      ),
    );
  }
}
