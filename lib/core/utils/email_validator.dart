bool isValidEmail(String email) {
  final studentEmailPattern = RegExp(r'^\d{10}@lamduan\.mfu\.ac\.th$');
  return studentEmailPattern.hasMatch(email);
}