/// Attendance justification record — /api/attendance/justification/status.
/// Plain model (no codegen): Odoo sends `false` for empty fields, which
/// json_serializable would choke on.
class Justification {
  final int id;
  final int attendanceId;
  final String date;
  final String justificationType;
  final String reason;
  final String state; // pending | approved | rejected
  final bool escalatedToManager;
  final String reviewedBy;
  final String reviewedDate;
  final String reviewNote;
  final String submittedOn;

  Justification({
    required this.id,
    required this.attendanceId,
    required this.date,
    required this.justificationType,
    required this.reason,
    required this.state,
    required this.escalatedToManager,
    required this.reviewedBy,
    required this.reviewedDate,
    required this.reviewNote,
    required this.submittedOn,
  });

  static String _str(dynamic v) => v == null || v == false ? '' : v.toString();

  factory Justification.fromJson(Map<String, dynamic> json) {
    return Justification(
      id: int.tryParse(json['id'].toString()) ?? 0,
      attendanceId: json['attendance_id'] is int ? json['attendance_id'] : 0,
      date: _str(json['date']),
      justificationType: _str(json['justification_type']),
      reason: _str(json['reason']),
      state: _str(json['state']),
      escalatedToManager: json['escalated_to_manager'] == true,
      reviewedBy: _str(json['reviewed_by']),
      reviewedDate: _str(json['reviewed_date']),
      reviewNote: _str(json['review_note']),
      submittedOn: _str(json['submitted_on']),
    );
  }
}
