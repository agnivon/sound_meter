import 'package:flutter/material.dart';

class DbReference {
  final int db;
  final String description;
  final Color color;

  const DbReference(this.db, this.description, this.color);
}

const List<DbReference> dbReferences = [
  DbReference(10, 'Breathing', Color(0xFF1E88E5)),
  DbReference(20, 'Clock Ticking', Color(0xFF039BE5)),
  DbReference(30, 'Whisper', Color(0xFF00ACC1)),
  DbReference(40, 'Quiet Library', Color(0xFF00897B)),
  DbReference(50, 'Quiet Office', Color(0xFF43A047)),
  DbReference(60, 'Conversation', Color(0xFFFDD835)),
  DbReference(70, 'Restaurant', Color(0xFFFB8C00)),
  DbReference(80, 'Busy Traffic', Color(0xFF6D4C41)),
  DbReference(90, 'Motorcycle', Color(0xFF5D4037)),
  DbReference(100, 'Subway Train', Color(0xFF4E342E)),
  DbReference(110, 'Concerts', Color(0xFF3E2723)),
  DbReference(120, 'Thunder', Color(0xFFE53935)),
  DbReference(130, 'Ambulance', Color(0xFFD32F2F)),
  DbReference(140, 'Gun Shots', Color(0xFFB71C1C)),
];

String getEnvironmentDescription(double db) {
  if (db < 10) return '0dB : Silence';
  for (var i = dbReferences.length - 1; i >= 0; i--) {
    if (db >= dbReferences[i].db) {
      return '${dbReferences[i].db}dB : ${dbReferences[i].description}';
    }
  }
  return '0dB : Silence';
}
