import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// Date picker personalizado que muestra las abreviaturas de días: L M M J V S D
/// y retorna la fecha seleccionada al cerrar.
class CustomDatePicker {
  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    Color? primaryColor,
  }) async {
    DateTime focused = initialDate;
    DateTime selected = initialDate;

    return showDialog<DateTime>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final color = primaryColor ?? theme.colorScheme.primary;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${selected.day}/${selected.month}/${selected.year}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Hoy',
                          icon: const Icon(Icons.my_location, size: 20),
                          onPressed: () {
                            setState(() {
                              focused = DateTime.now();
                              selected = focused;
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  Flexible(
                    child: TableCalendar(
                      firstDay: firstDate,
                      lastDay: lastDate,
                      focusedDay: focused,
                      currentDay: DateTime.now(),
                      locale: 'es',
                      selectedDayPredicate: (d) => _isSameDay(d, selected),
                      calendarFormat: CalendarFormat.month,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: color,
                        ),
                        leftChevronIcon: Icon(Icons.chevron_left, color: color),
                        rightChevronIcon: Icon(Icons.chevron_right, color: color),
                      ),
                      daysOfWeekHeight: 28,
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(fontWeight: FontWeight.w600),
                        weekendStyle: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      calendarBuilders: CalendarBuilders(
                        dowBuilder: (context, day) {
                          const labels = ['L','M','M','J','V','S','D'];
                          return Center(
                            child: Text(
                              labels[day.weekday - 1],
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          );
                        },
                      ),
                      calendarStyle: CalendarStyle(
                        isTodayHighlighted: true,
                        todayDecoration: BoxDecoration(
                          color: color.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        todayTextStyle: TextStyle(color: color, fontWeight: FontWeight.w700),
                      ),
                      onDaySelected: (sel, foc) {
                        setState(() {
                          selected = sel;
                          focused = foc;
                        });
                      },
                      onPageChanged: (foc) => focused = foc,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.of(context).pop(selected),
                        child: const Text('Aceptar'),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
        );
      },
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
