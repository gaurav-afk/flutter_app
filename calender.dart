import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_clean_calendar/flutter_clean_calendar.dart';
import 'package:intl/intl.dart';

class Calender extends StatefulWidget {
  const Calender({Key? key}) : super(key: key);

  @override
  State<Calender> createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  late Map<DateTime, List<CleanCalendarEvent>> events;

  @override
  void initState() {
    getEvents();
    // selectedEvent = events[selectedDay] ?? [];
    super.initState();
  }

  final DateFormat formatter = DateFormat('d');
  final DateFormat formatterMonth = DateFormat('MMM');
  List<DateTime> eventsDateTime = [];
  List<CleanCalendarEvent> eventsCCE = [];
  List<Map<DateTime, List<CleanCalendarEvent>>> eventsL = [];

  Map<String, int> monthCode = {
    'Jan': 1,
    'Feb': 2,
    'Mar': 3,
    'Apr': 4,
    'May': 5,
    'Jun': 6,
    'Jul': 7,
    'Aug': 8,
    'Sep': 9,
    'Oct': 10,
    'Nov': 11,
    'Dec': 12
  };

  Future<Map<DateTime, List<CleanCalendarEvent>>> eventsMap() async {
    final eventsList = await getEvents();
    final DateTime now = DateTime.now();
    // print(DateFormat('MMM')
    //     .format(DateTime.parse(eventsList[0].FullDate))
    //     .runtimeType);

    // for (var i in eventsList) {
    //   eventsDateTime.add(DateTime(
    //       now.year,
    //       monthCode[formatterMonth.format(DateTime.parse(i.FullDate))]!,
    //       now.day));
    // }
    //
    // for (var j in eventsList) {
    //   eventsCCE.add(
    //     CleanCalendarEvent(j.BookingText,
    //         startTime: DateTime(now.year, now.month, now.day + 1, 10, 0),
    //         endTime: DateTime(now.year, now.month, now.day + 1, 12, 0),
    //         description: 'A special event',
    //         color: Colors.orangeAccent),
    //   );
    //   // eventsList.forEach((events) => eventsDateTime = eventsCCE);
    // }
    events = {
      DateTime(now.year, now.month, now.day): [
        CleanCalendarEvent(eventsList[0].BookingText,
            startTime: DateTime(now.year, now.month, now.day + 1, 10, 0),
            endTime: DateTime(now.year, now.month, now.day + 1, 12, 0),
            description: 'A special event',
            color: Colors.orangeAccent),
      ],
      DateTime(now.year, now.month, now.day + 2): [
        CleanCalendarEvent(eventsList[1].BookingText,
            startTime: DateTime(now.year, now.month, now.day + 2, 10, 0),
            endTime: DateTime(now.year, now.month, now.day + 2, 12, 0),
            color: Colors.orange),
        CleanCalendarEvent(eventsList[2].BookingText,
            startTime: DateTime(now.year, now.month, now.day + 2, 14, 30),
            endTime: DateTime(now.year, now.month, now.day + 2, 17, 0),
            color: Colors.pink),
      ],
    };
    return events;
  }

  DateTime? selectedDay;
  late List<CleanCalendarEvent> selectedEvent;

  @override
  Widget build(BuildContext context) {
    void _handleData(date) {
      setState(() {
        selectedDay = date;
        selectedEvent = events[selectedDay] ?? [];
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text('Calendar'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<DateTime, List<CleanCalendarEvent>>>(
        future: eventsMap(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data == null) {
            return Center(
              child: Text('done but with null'),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Has error - ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Calendar(
                  startOnMonday: false,
                  selectedColor: Colors.blue,
                  todayColor: Colors.red,
                  eventColor: Colors.green,
                  eventDoneColor: Colors.amber,
                  bottomBarColor: Colors.deepOrange,
                  onDateSelected: (date) {
                    return _handleData(formatter);
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
                  weekDays: const [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun'
                  ],
                ),
              ),
            );
          } else {
            return Center(
              child: Text('Has error - ${snapshot.error}'),
            );
          }
        },
      ),
    );
  }

  Future<List<Event>> getEvents() async {
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
    return events;
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
