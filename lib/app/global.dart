
int betweenDays(year, month, day) {

  final birthday = DateTime(year, month, day);
  final date2 = DateTime.now();
  final difference = date2.difference(birthday).inDays;
  
  return difference;
}