import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../core/models/event_model.dart';

class EventCalendar extends StatefulWidget {
  final List<EventModel> events;
  final Function(DateTime)? onDateSelected;
  final Function(List<EventModel>)? onEventsForDateChanged;

  const EventCalendar({
    super.key,
    required this.events,
    this.onDateSelected,
    this.onEventsForDateChanged,
  });

  @override
  State<EventCalendar> createState() => _EventCalendarState();
}

class _EventCalendarState extends State<EventCalendar> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late Map<DateTime, List<EventModel>> _eventsByDate;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _eventsByDate = _groupEventsByDate();
  }

  Map<DateTime, List<EventModel>> _groupEventsByDate() {
    final Map<DateTime, List<EventModel>> events = {};
    
    for (final event in widget.events) {
      final date = DateTime(
        event.startDate.year,
        event.startDate.month,
        event.startDate.day,
      );
      
      if (events[date] == null) {
        events[date] = [];
      }
      events[date]!.add(event);
    }
    
    return events;
  }

  List<EventModel> _getEventsForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _eventsByDate[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              
              widget.onDateSelected?.call(selectedDay);
              
              final eventsForDay = _getEventsForDay(selectedDay);
              widget.onEventsForDateChanged?.call(eventsForDay);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              todayDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(
                color: Colors.red.shade300,
              ),
              markersMaxCount: 1,
              markerDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: Theme.of(context).textTheme.titleLarge ?? 
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: Theme.of(context).primaryColor,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: Theme.of(context).primaryColor,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: Theme.of(context).textTheme.bodySmall ?? 
                const TextStyle(fontSize: 12),
              weekendStyle: TextStyle(
                fontSize: 12,
                color: Colors.red.shade300,
              ),
            ),
            eventLoader: _getEventsForDay,
          ),
        ),
        const SizedBox(height: 16),
        _buildEventsForSelectedDay(),
      ],
    );
  }

  Widget _buildEventsForSelectedDay() {
    final events = _getEventsForDay(_selectedDay);
    
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'No events on ${_formatDate(_selectedDay)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Events on ${_formatDate(_selectedDay)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(event.title),
                subtitle: Text(event.location),
                trailing: Text(
                  event.category,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
