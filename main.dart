import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_clean_calendar/flutter_clean_calendar.dart';

void main() async {
  runApp(const MaterialApp(
    home: Calender(),
  ));
}

class Calender extends StatefulWidget {
  const Calender({Key? key}) : super(key: key);

  @override
  State<Calender> createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  DateTime? selectedDay;
  late List<CleanCalendarEvent> selectedEvent;

  final Map<DateTime, List<CleanCalendarEvent>> events = {
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day): [
      CleanCalendarEvent('Event A',
          startTime: DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day, 10, 0),
          endTime: DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day, 12, 0),
          description: 'A special event',
          color: Colors.orangeAccent),
    ],
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 2):
        [
      CleanCalendarEvent('Event B',
          startTime: DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day + 2, 10, 0),
          endTime: DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day + 2, 12, 0),
          color: Colors.orange),
      CleanCalendarEvent('Event C',
          startTime: DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day + 2, 14, 30),
          endTime: DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day + 2, 17, 0),
          color: Colors.pink),
    ],
  };

  void _handleData(date) {
    setState(() {
      selectedDay = date;
      selectedEvent = events[selectedDay] ?? [];
    });
    print(selectedDay);
  }

  @override
  void initState() {
    // TODO: implement initState
    getPayments();
    selectedEvent = events[selectedDay] ?? [];
    super.initState();
  }

  Future<List<Event>> getPayments() async {
    final response = await http.post(
      Uri.parse("http://api.sportsb.co.in/api/CustomerCalendar"),
      headers: <String, String>{
        'customer-key': 'EQYGf84gWWMJsi8Bz/73ufdftIdOKyta1YohLogAL5U=',
        'ContentType': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {"Month": "12", "Year": "2021"},
      ),
    );
    var json = jsonDecode(response
        .body); //jsonDecode() returns a _InternalLinkedHashMap<String, dynamic>

    var e1 = json;
    var D = e1["Data"];
    var payList = D["DateList"];
    // print(payList);
    print(payList.runtimeType);
    List<Event> events = [];
    for (var p in (payList as List)) {
      Event E = Event(
          p["Date"],
          p["FullDate"],
          p["BookinkStatus"],
          p["BookinkStatusId"],
          p["BookingColorHEX"],
          p["BookingText"],
          p["SecondText"],
          p["OnlyDate"],
          p["IsFee"]);
      events.add(E);
    }
    print(events);
    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text('Calendar'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Calendar(
              startOnMonday: true,
              selectedColor: Colors.blue,
              todayColor: Colors.red,
              eventColor: Colors.green,
              eventDoneColor: Colors.amber,
              bottomBarColor: Colors.deepOrange,
              onRangeSelected: (range) {
                print('selected Day ${range.from},${range.to}');
              },
              onDateSelected: (date) {
                return _handleData(date);
              },
              events: events,
              isExpanded: true,
              dayOfWeekStyle: TextStyle(
                fontSize: 12,
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
              ),
              bottomBarTextStyle: TextStyle(
                color: Colors.white,
              ),
              hideBottomBar: false,
              hideArrows: false,
              weekDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            ),
          ),
        ),
      ),
    );
  }
}

class Event {
  String Date;
  String FullDate;
  String BookinkStatus;
  String BookinkStatusId;
  String BookingColorHEX;
  String BookingText;
  String SecondText;
  String OnlyDate;
  bool IsFee;

  Event(
      this.Date,
      this.FullDate,
      this.BookinkStatus,
      this.BookinkStatusId,
      this.BookingColorHEX,
      this.BookingText,
      this.SecondText,
      this.OnlyDate,
      this.IsFee);
}
