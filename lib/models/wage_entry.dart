import 'package:equatable/equatable.dart';

class WageEntry extends Equatable {
  const WageEntry({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.partType,
    required this.piecesCount,
    required this.pricePerPiece,
    required this.totalAmount,
    required this.date,
    this.notes,
  });

  final String id;
  final String workerId;
  final String workerName;
  final String partType;
  final int piecesCount;
  final double pricePerPiece;
  final double totalAmount;
  final DateTime date;
  final String? notes;

  factory WageEntry.fromMap(String id, Map<String, dynamic> map) {
    return WageEntry(
      id: id,
      workerId: map['workerId'] ?? '',
      workerName: map['workerName'] ?? '',
      partType: map['partType'] ?? '',
      piecesCount: (map['piecesCount'] ?? 0).toInt(),
      pricePerPiece: (map['pricePerPiece'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workerId': workerId,
      'workerName': workerName,
      'partType': partType,
      'piecesCount': piecesCount,
      'pricePerPiece': pricePerPiece,
      'totalAmount': totalAmount,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [
        id,
        workerId,
        workerName,
        partType,
        piecesCount,
        pricePerPiece,
        totalAmount,
        date,
        notes,
      ];
}
