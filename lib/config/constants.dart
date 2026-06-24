/// CashewPro ERP — App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'CashewPro ERP';
  static const String appVersion = '0.1.0';
  static const String appTagline = 'Complete Cashew Factory Management';

  // API Configuration (overridden by environment)
  static const String defaultApiBaseUrl = 'http://localhost:4000/api';
  static const String defaultEncryptEngineUrl = 'http://localhost:3100/api/v1';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration socketReconnectDelay = Duration(seconds: 5);

  // Pagination
  static const int defaultPageSize = 20;

  // Session
  static const Duration sessionTimeout = Duration(minutes: 30);
  static const Duration tokenRefreshBuffer = Duration(minutes: 5);

  // Cashew Processing Stages
  static const List<String> processingStages = [
    'Cleaning & Sorting',
    'Calibration',
    'Steam Cooking / Roasting',
    'Cooling',
    'Shelling / Cutting',
    'Borma Drying',
    'Humidification',
    'Peeling',
    'Grading & Sorting',
    'Quality Check',
    'Packing & Sealing',
    'Storage / Dispatch',
  ];

  // Cashew Grades
  static const List<Map<String, dynamic>> cashewGrades = [
    {'code': 'W180', 'name': 'King / Super Premium', 'countPerLb': '170-180'},
    {'code': 'W210', 'name': 'Jumbo / Premium', 'countPerLb': '200-210'},
    {'code': 'W240', 'name': 'Popular Premium', 'countPerLb': '220-240'},
    {'code': 'W320', 'name': 'Most Traded', 'countPerLb': '300-320'},
    {'code': 'W450', 'name': 'Commercial', 'countPerLb': '400-450'},
    {'code': 'SW', 'name': 'Scorched Wholes', 'countPerLb': '-'},
    {'code': 'SSW', 'name': 'Scorched Splits', 'countPerLb': '-'},
    {'code': 'S', 'name': 'Splits', 'countPerLb': '-'},
    {'code': 'B', 'name': 'Butts', 'countPerLb': '-'},
    {'code': 'P', 'name': 'Pieces', 'countPerLb': '-'},
  ];

  // Employee Types
  static const List<String> employeeTypes = [
    'Sheller',
    'Peeler',
    'Grader',
    'Machine Operator',
    'Supervisor',
    'Driver',
    'Admin',
    'Security',
    'Cleaner',
  ];

  // Expense Categories
  static const List<String> expenseCategories = [
    'Labour',
    'Transport',
    'Fuel',
    'Electricity',
    'Repairs & Maintenance',
    'Rent',
    'Admin & Office',
    'Packaging',
    'Insurance',
    'Miscellaneous',
  ];

  // GST
  static const double gstRate = 5.0; // 5% on cashew nuts
  static const String hsnRCN = '08013100';
  static const String hsnKernels = '08013200';
}
