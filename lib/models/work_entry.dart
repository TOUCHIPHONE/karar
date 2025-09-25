import 'package:equatable/equatable.dart';

class WorkEntry extends Equatable {
  const WorkEntry({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.pieceType,
    required this.piecesCount,
    required this.unitPrice,
    required this.totalAmount,
    required this.workDate,
    this.notes,
    this.createdBy,
  });

  final String id;
  final String workerId;
  final String workerName;
  final String pieceType;
  final int piecesCount;
  final double unitPrice;
  final double totalAmount;
  final DateTime workDate;
  final String? notes;
  final String? createdBy;

  WorkEntry copyWith({
    String? workerId,
    String? workerName,
    String? pieceType,
    int? piecesCount,
    double? unitPrice,
    double? totalAmount,
    DateTime? workDate,
    String? notes,
    String? createdBy,
  }) {
    return WorkEntry(
      id: id,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      pieceType: pieceType ?? this.pieceType,
      piecesCount: piecesCount ?? this.piecesCount,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      workDate: workDate ?? this.workDate,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workerId': workerId,
      'workerName': workerName,
      'pieceType': pieceType,
      'piecesCount': piecesCount,
      'unitPrice': unitPrice,
      'totalAmount': totalAmount,
      'workDate': workDate.toIso8601String(),
      'notes': notes,
      'createdBy': createdBy,
    };
  }

  factory WorkEntry.fromFirestore(String id, Map<String, dynamic> data) {
    return WorkEntry(
      id: id,
      workerId: data['workerId'] as String? ?? '',
      workerName: data['workerName'] as String? ?? '',
      pieceType: data['pieceType'] as String? ?? '',
      piecesCount: (data['piecesCount'] as num?)?.toInt() ?? 0,
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0,
      workDate: DateTime.tryParse(data['workDate'] as String? ?? '') ?? DateTime.now(),
      notes: data['notes'] as String?,
      createdBy: data['createdBy'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workerId,
        workerName,
        pieceType,
        piecesCount,
        unitPrice,
        totalAmount,
        workDate,
        notes,
        createdBy,
      ];
}
