// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attendance _$AttendanceFromJson(Map<String, dynamic> json) => Attendance(
      json['attendanceId'] as int?,
      json['name'] as String?,
      json['employee_id'] as int?,
      json['user_id'] as int?,
      json['date'] as String?,
      json['check_in_datetime'] as String?,
      json['check_out_datetime'] as String?,
      json['check_in_time'] as String?,
      json['check_out_time'] as String?,
      json['working_hr'] as String?,
      (json['in_latitude'] as num?)?.toDouble(),
      (json['in_longitude'] as num?)?.toDouble(),
      (json['out_latitude'] as num?)?.toDouble(),
      (json['out_longitude'] as num?)?.toDouble(),
      json['in_location'] as String?,
      json['out_location'] as String?,
      json['device_id'] as String?,
      json['reason'] as String?,
      json['write_date'] as String?,
      json['att_type'] as String?,
      json['checkInSelfie'] as String?,
      json['checkOutSelfie'] as String?,
      id: json['id'] as int?,
      work_mode: json['work_mode'] as String?,
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      check_in_mode: json['check_in_mode'] as String?,
      check_out_mode: json['check_out_mode'] as String?,
      check_in_address: json['check_in_address'] as String?,
      check_out_address: json['check_out_address'] as String?,
      is_auto_checkout: json['is_auto_checkout'] as int?,
    );

Map<String, dynamic> _$AttendanceToJson(Attendance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'attendanceId': instance.attendanceId,
      'name': instance.name,
      'employee_id': instance.employee_id,
      'user_id': instance.user_id,
      'date': instance.date,
      'check_in_datetime': instance.check_in_datetime,
      'check_out_datetime': instance.check_out_datetime,
      'check_in_time': instance.check_in_time,
      'check_out_time': instance.check_out_time,
      'working_hr': instance.working_hr,
      'in_latitude': instance.in_latitude,
      'in_longitude': instance.in_longitude,
      'out_latitude': instance.out_latitude,
      'out_longitude': instance.out_longitude,
      'in_location': instance.in_location,
      'out_location': instance.out_location,
      'device_id': instance.device_id,
      'reason': instance.reason,
      'write_date': instance.write_date,
      'att_type': instance.att_type,
      'checkInSelfie': instance.checkInSelfie,
      'checkOutSelfie': instance.checkOutSelfie,
      'work_mode': instance.work_mode,
      'accuracy': instance.accuracy,
      'check_in_mode': instance.check_in_mode,
      'check_out_mode': instance.check_out_mode,
      'check_in_address': instance.check_in_address,
      'check_out_address': instance.check_out_address,
      'is_auto_checkout': instance.is_auto_checkout,
    };
