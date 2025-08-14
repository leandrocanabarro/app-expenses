class AppConstants {
  static const String appName = 'App Expenses';
  static const String dbName = 'expenses.db';
  static const int dbVersion = 1;
  
  // Voice commands
  static const String createCategoryPattern = r'(?:criar|nova)\s+categoria\s+(.+)$';
  static const String addExpensePattern1 = r'(?:adicionar|lançar|inserir)\s+gasto\s+(.+)';
  static const String addExpensePattern2 = r'gastei\s+(.+)\s+em\s+(.+)';
  static const String categoryInlinePattern = r'\s+na\s+categoria\s+(.+)$';
  static const String valuePattern = r'((?:\d{1,3}(?:\.\d{3})*|\d+)(?:,\d{1,2})?)';
  
  // UI
  static const double minTouchTarget = 48.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
}