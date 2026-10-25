abstract class Agenda {
  final String agendaId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String agendaType;

  Agenda({
    required this.agendaId,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.agendaType,
  });

  int getDurationMinutes() {
    return endTime.difference(startTime).inMinutes;
  }

  bool checkConflict(Agenda otherAgenda) {
    return startTime.isBefore(otherAgenda.endTime) && endTime.isAfter(otherAgenda.startTime);
  }
}
