class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email required';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return 'Enter valid email';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password required';
    if (value.length < 6) return 'Min 6 characters';
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) return 'Include at least 1 uppercase';
    if (!RegExp(r'(?=.*\d)').hasMatch(value)) return 'Include at least 1 number';
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Name required';
    return null;
  }
}
