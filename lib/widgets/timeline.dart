import 'dart:math';

import 'package:flutter/material.dart';
import 'package:timeline_sample/exceptions/exception.dart';
import 'package:timeline_sample/widgets/horizontal_wheel_scroll.dart';

class Booking {
  final String startTime;
  final String endTime;

  Booking({required this.startTime, required this.endTime});
}

class CustomTimeLine extends StatefulWidget {
  const CustomTimeLine({
    super.key,
    required this.onTimeSelected,
    required this.onError,
  });

  final Function(String time) onTimeSelected;
  final Function(dynamic e) onError;

  @override
  State<CustomTimeLine> createState() => _CustomTimeLineState();
}

class _CustomTimeLineState extends State<CustomTimeLine> {
  late FixedExtentScrollController scrollController =
      FixedExtentScrollController(
    initialItem: 0,
  );

  final Color bookedColor = Colors.red;
  final Color availableColor = Colors.green;

  int currentScale = 1;

  List<Booking> booked = [
    Booking(startTime: "00:00", endTime: "01:00"),
    Booking(startTime: "01:00", endTime: "02:00"),
    Booking(startTime: "08:00", endTime: "09:30"),
    Booking(startTime: "23:00", endTime: "24:00"),
  ];

  List<String> _list_to_display = [];

  int currentIndex = 0;
  int prevIndex = 0;
  int numberOfSubdivision = 1;

  double totalWidth = 100;
  double width = 80;

  double eventBarHeight = 8;

  double durationInHours = 1;

  bool isCurrentStateBooked = false;

  @override
  void initState() {
    super.initState();

    // width = totalWidth / (numberOfSubdivision + 1);

    totalWidth = (numberOfSubdivision + 1) * width;

    _list_to_display = getTimes();

    // finding first available slot
    int firstAvailableSlot = getNextAvailableTime(0, _list_to_display.length);

    setState(() {
      currentIndex = firstAvailableSlot;
    });

    scrollController =
        FixedExtentScrollController(initialItem: firstAvailableSlot);
  }

  void jumpToNextPrevSlot() {
    // finding first available slot
    int firstAvailableSlot =
        getNextAvailableTime(currentIndex, _list_to_display.length);
    int prevAvailableSlot = getPrevAvailableTime(0, currentIndex);

    // Checking scroll direction
    if (currentIndex > prevIndex) {
      if (currentIndex != firstAvailableSlot) {
        widget
            .onTimeSelected(getTimeText(_list_to_display[firstAvailableSlot]));
        scrollController.jumpToItem(firstAvailableSlot);
        setState(() {
          currentIndex = firstAvailableSlot;
        });
      }
    } else {
      if (currentIndex != prevAvailableSlot) {
        widget.onTimeSelected(getTimeText(_list_to_display[prevAvailableSlot]));
        scrollController.jumpToItem(prevAvailableSlot);
        setState(() {
          currentIndex = prevAvailableSlot;
        });
      }
    }
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
    List<String> _availableTimes = [];

    for (int i = start; i < end; i++) {
      _availableTimes.add(_list_to_display[i]);
    }

    for (int i = start; i < end; i++) {
      List<Booking> _booked = booked;

      if (_booked.isNotEmpty) {
        _booked.forEach((element) {
          // getting range of time between start and end time
          int startIndex = _list_to_display.indexOf(element.startTime);
          int endIndex = _list_to_display.indexOf(element.endTime);

          for (int i = startIndex; i < endIndex; i++) {
            _availableTimes.remove(_list_to_display[i]);
          }
        });
      }
    }

    int firstAvailableSlot = _list_to_display.indexOf(_availableTimes.first);

    return firstAvailableSlot;
  }

  int getPrevAvailableTime(int start, int end) {
    List<String> _availableTimes = [];

    for (int i = start; i <= end; i++) {
      _availableTimes.add(_list_to_display[i]);
    }

    for (int i = start; i < end; i++) {
      List<Booking> _booked = booked;

      if (_booked.isNotEmpty) {
        _booked.forEach((element) {
          // getting range of time between start and end time
          int startIndex = _list_to_display.indexOf(element.startTime);
          int endIndex = _list_to_display.indexOf(element.endTime);

          for (int i = startIndex + 1; i <= endIndex; i++) {
            _availableTimes.remove(_list_to_display[i]);
          }
        });
      }
    }

    int lastAvailableSlot = _list_to_display.indexOf(_availableTimes.last);

    return lastAvailableSlot;
  }

  int getBarHeight(int i) {
    // Checking if the time is the correctBar
    String time = _list_to_display[i];

    if (time.split(":")[1] == "00") {
      return 20;
    } else {
      if (isAlternateBars(i)) {
        return 20;
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
            height: eventBarHeight,
            width: (width / 2) + 5,
            decoration: BoxDecoration(
              color: secondColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
            ),
          )
        ],
      );
    } else if (i == _list_to_display.length - 1) {
      timelineContainer = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: eventBarHeight,
            width: (width / 2) + 5,
            decoration: BoxDecoration(
              color: firstColor,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
          )
        ],
      );
    } else {
      timelineContainer = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: eventBarHeight,
            width: (width / 2),
            color: firstColor,
          ),
          Container(
            height: eventBarHeight,
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
            margin: const EdgeInsets.all(5),
            width: 3,
            height: getBarHeight(i).toDouble(),
            decoration: BoxDecoration(
              color: i == currentIndex ? Colors.black : Colors.grey,
              borderRadius: BorderRadius.circular(5),
            ),
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

  bool checkIfNextXDurationBooked() {
    int startIndex = currentIndex;

    String endTime = calculateEndTimeWithDuration();

    int endIndex = _list_to_display.indexOf(endTime);

    List<String> _availableTimes = [];

    for (int i = startIndex; i <= endIndex; i++) {
      _availableTimes.add(_list_to_display[i]);
    }

    int numberOfSlots = _availableTimes.length;

    for (int i = startIndex; i < endIndex; i++) {
      List<Booking> _booked = booked;

      if (_booked.isNotEmpty) {
        _booked.forEach((element) {
          // getting range of time between start and end time
          int startIndex = _list_to_display.indexOf(element.startTime);
          int endIndex = _list_to_display.indexOf(element.endTime);

          for (int i = startIndex + 1; i < endIndex; i++) {
            _availableTimes.remove(_list_to_display[i]);
          }
        });
      }
    }

    print("availableTimes: $_availableTimes");

    if (_availableTimes.length < numberOfSlots || _availableTimes.isEmpty) {
      return true;
    }

    return false;
  }

  String calculateEndTimeWithDuration() {
    int startIndex = currentIndex;

    String startTime = _list_to_display[startIndex];

    String endTime = "";

    if (int.parse(durationInHours.toString().split(".")[1]) == 0) {
      int hour = int.parse(startTime.split(":")[0]) + durationInHours.toInt();
      int minute = int.parse(startTime.split(":")[1]);

      endTime =
          "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
    } else {
      int hour = int.parse(startTime.split(":")[0]) + durationInHours.toInt();
      int minute = int.parse(startTime.split(":")[1]);

      int newMinute = minute + 60 ~/ (numberOfSubdivision + 1);

      if (newMinute >= 60) {
        hour += 1;
        minute = newMinute - 60;
      } else {
        minute = newMinute;
      }

      endTime =
          "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
    }

    return endTime;
  }

  void errorCallback() {
    widget.onError(
        DurationException("Next $durationInHours hours are not available"));
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

      for (int i = startIndex + 1; i < endIndex; i++) {
        _map[_list_to_display[i]] = getTimeline(bookedColor, bookedColor, i);
      }

      // Checking if start time is already end time of some other booking
      List<Booking> _booked =
          booked.where((element) => element.endTime == startTime).toList();

      if (_booked.isNotEmpty) {
        _map[startTime] = getTimeline(bookedColor, bookedColor, startIndex);
      } else {
        _map[startTime] = getTimeline(availableColor, bookedColor, startIndex);
      }

      // Checking if end time is already start time of some other booking
      _booked =
          booked.where((element) => element.startTime == endTime).toList();

      if (_booked.isNotEmpty) {
        _map[endTime] = getTimeline(bookedColor, bookedColor, endIndex);
      } else {
        _map[endTime] = getTimeline(bookedColor, availableColor, endIndex);
      }
    }

    if (isCurrentStateBooked) {
      if (!checkIfNextXDurationBooked()) {
        print("Next $durationInHours hours are available");

        String startTime = _list_to_display[currentIndex];
        String endTime = calculateEndTimeWithDuration();

        if (!_list_to_display.contains(endTime)) {
          endTime = _list_to_display.last;
        }

        print("startTime: $startTime endTime: $endTime");

        int startIndex = _list_to_display.indexOf(startTime);
        int endIndex = _list_to_display.indexOf(endTime);

        print("startIndex: $startIndex endIndex: $endIndex");

        for (int i = startIndex + 1; i < endIndex; i++) {
          _map[_list_to_display[i]] =
              getTimeline(Colors.yellow, Colors.yellow, i);
        }

        // Checking if start time is already end time of some other booking
        List<Booking> _booked =
            booked.where((element) => element.endTime == startTime).toList();

        if (_booked.isNotEmpty) {
          _map[startTime] = getTimeline(bookedColor, Colors.yellow, startIndex);
        } else {
          _map[startTime] =
              getTimeline(availableColor, Colors.yellow, startIndex);
        }

        // Checking if end time is already start time of some other booking

        _booked =
            booked.where((element) => element.startTime == endTime).toList();

        if (_booked.isNotEmpty) {
          _map[endTime] = getTimeline(Colors.yellow, bookedColor, endIndex);
        } else {
          _map[endTime] = getTimeline(Colors.yellow, availableColor, endIndex);
        }
      }
    }
    _list = _list_to_display.map(
      (e) {
        if (_map.containsKey(e)) {
          return _map[e]!;
        } else {
          return getTimeline(
              availableColor, availableColor, _list_to_display.indexOf(e));
        }
      },
    ).toList();

    return SizedBox(
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
        child: HorizontalListWheelScrollView(
          controller: scrollController,
          physics: const FixedExtentScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemExtent: totalWidth / (numberOfSubdivision + 1),
          diameterRatio: 100,
          perspective: 0.01,
          onSelectedItemChanged: (index) {
            setState(() {
              if (prevIndex != currentIndex) {
                prevIndex = currentIndex;
                currentIndex = index;
              }
              jumpToNextPrevSlot();
              widget
                  .onTimeSelected(getTimeText(_list_to_display[currentIndex]));
              final bool isBooked = checkIfNextXDurationBooked();
              if (isBooked) {
                errorCallback();
              }
            });
          },
          children: _list,
        ),
      ),
    );
  }
}
