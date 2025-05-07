import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateWithMonth(DateTime date) {
    return DateFormat('d MMMM yyyy', 'fr_FR').format(date);
  }

  static String formatDateWithTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // Retourne un texte convivial pour la date (Aujourd'hui, Demain, etc.)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return "Aujourd'hui, ${DateFormat('HH:mm').format(date)}";
    } else if (dateToCheck == tomorrow) {
      return "Demain, ${DateFormat('HH:mm').format(date)}";
    } else if (date.isBefore(today)) {
      // Si la date est dépassée
      return "En retard! ${DateFormat('d MMM', 'fr_FR').format(date)}";
    } else {
      // Si c'est dans la semaine prochaine
      final daysUntil = dateToCheck.difference(today).inDays;
      if (daysUntil < 7) {
        final weekdayName = DateFormat('EEEE', 'fr_FR').format(date);
        return "$weekdayName, ${DateFormat('HH:mm').format(date)}";
      } else {
        return formatDateWithMonth(date);
      }
    }
  }

  static String formatDueDate(DateTime? dueDate) {
    if (dueDate == null) {
      return 'Aucune échéance';
    }

    return formatRelativeDate(dueDate);
  }

  static String formatTimeRemaining(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.isNegative) {
      return 'En retard';
    }

    if (difference.inDays > 0) {
      return '${difference.inDays} jour${difference.inDays > 1 ? 's' : ''} restant${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} heure${difference.inHours > 1 ? 's' : ''} restante${difference.inHours > 1 ? 's' : ''}';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} restante${difference.inMinutes > 1 ? 's' : ''}';
    }
  }

  static bool isOverdue(DateTime dueDate) {
    final now = DateTime.now();
    return dueDate.isBefore(now) && !DateUtils.isSameDay(dueDate, now);
  }
}
