import 'package:flutter/material.dart';

enum MoldType { type1K, type2K }
enum InsertBlockType { single, double }

class InsertChange {
  final DateTime date;
  final String insertId;
  final String reason;

  InsertChange({
    required this.date,
    required this.insertId,
    required this.reason,
  });
}

class InsertPosition {
  final String id; // Unique ID for this position in the mold
  final String initialInsertId;
  String currentInsertId;
  List<InsertChange> history;

  InsertPosition({
    required this.id,
    required this.initialInsertId,
    required this.currentInsertId,
    List<InsertChange>? history,
  }) : history = history ?? [];

  bool get isChanged => initialInsertId != currentInsertId;

  void replaceInsert(String newInsertId, String reason) {
    history.add(InsertChange(
      date: DateTime.now(),
      insertId: currentInsertId, // Record the one being removed or the previous state? 
      // Requirement: "History must contain the date of the change, the insert ID and the reason of the change."
      // Usually history logs what was put in or what happened. 
      // Let's log the NEW insert being installed.
      reason: reason,
    ));
    currentInsertId = newInsertId;
  }
  
  // Helper to get history of what was installed
  // Actually, let's store the change log. 
  // When we replace A with B. We log: Date, New ID: B, Reason.
  // The initial one is implicit as the start.
}

class MoldSide {
  final String name;
  final int rows;
  final int columns;
  final List<InsertPosition> positions;

  MoldSide({
    required this.name,
    required this.rows,
    required this.columns,
    required this.positions,
  });
}

class Mold {
  final String id;
  final String name;
  final MoldType type;
  final InsertBlockType insertType;
  final List<MoldSide> sides;

  Mold({
    required this.id,
    required this.name,
    required this.type,
    required this.insertType,
    required this.sides,
  });
}

// Simple in-memory storage for the demo
class MoldRepository {
  static final MoldRepository _instance = MoldRepository._internal();
  factory MoldRepository() => _instance;
  MoldRepository._internal();

  final List<Mold> _molds = [];

  List<Mold> get molds => _molds;

  void addMold(Mold mold) {
    _molds.add(mold);
  }
  
  // Helper to generate initial positions
  static List<InsertPosition> generatePositions(String sideName, int rows, int cols) {
    List<InsertPosition> positions = [];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        String id = "${sideName}_${r}_${c}";
        // Initial insert ID is just a placeholder or generated ID
        String initialId = "INS-${id}"; 
        positions.add(InsertPosition(
          id: id,
          initialInsertId: initialId,
          currentInsertId: initialId,
        ));
      }
    }
    return positions;
  }
}
