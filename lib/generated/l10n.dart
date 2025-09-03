// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Account`
  String get account {
    return Intl.message('Account', name: 'account', desc: '', args: []);
  }

  /// `Manage your account settings`
  String get manageAccount {
    return Intl.message(
      'Manage your account settings',
      name: 'manageAccount',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Set your notification preferences`
  String get manageNotifications {
    return Intl.message(
      'Set your notification preferences',
      name: 'manageNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Privacy`
  String get privacy {
    return Intl.message('Privacy', name: 'privacy', desc: '', args: []);
  }

  /// `Manage data and privacy settings`
  String get managePrivacy {
    return Intl.message(
      'Manage data and privacy settings',
      name: 'managePrivacy',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Choose Language`
  String get chooseLanguage {
    return Intl.message(
      'Choose Language',
      name: 'chooseLanguage',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `Hindi`
  String get hindi {
    return Intl.message('Hindi', name: 'hindi', desc: '', args: []);
  }

  /// `Dark Mode`
  String get darkMode {
    return Intl.message('Dark Mode', name: 'darkMode', desc: '', args: []);
  }

  /// `Enable or disable dark mode`
  String get darkModeSubtitle {
    return Intl.message(
      'Enable or disable dark mode',
      name: 'darkModeSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Afternoon, {name} 👋`
  String greetingAfternoon(Object name) {
    return Intl.message(
      'Afternoon, $name 👋',
      name: 'greetingAfternoon',
      desc: '',
      args: [name],
    );
  }

  /// `Today's Attendance`
  String get todaysAttendance {
    return Intl.message(
      'Today\'s Attendance',
      name: 'todaysAttendance',
      desc: '',
      args: [],
    );
  }

  /// `Check In`
  String get checkIn {
    return Intl.message('Check In', name: 'checkIn', desc: '', args: []);
  }

  /// `Check Out`
  String get checkOut {
    return Intl.message('Check Out', name: 'checkOut', desc: '', args: []);
  }

  /// `Last Out`
  String get lastOut {
    return Intl.message('Last Out', name: 'lastOut', desc: '', args: []);
  }

  /// `First In`
  String get firstIn {
    return Intl.message('First In', name: 'firstIn', desc: '', args: []);
  }

  /// `Date`
  String get date {
    return Intl.message('Date', name: 'date', desc: '', args: []);
  }

  /// `No Data`
  String get noData {
    return Intl.message('No Data', name: 'noData', desc: '', args: []);
  }

  /// `Server is Busy`
  String get serverBusy {
    return Intl.message(
      'Server is Busy',
      name: 'serverBusy',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refresh {
    return Intl.message('Refresh', name: 'refresh', desc: '', args: []);
  }

  /// `Select Month`
  String get selectMonth {
    return Intl.message(
      'Select Month',
      name: 'selectMonth',
      desc: '',
      args: [],
    );
  }

  /// `Select Year`
  String get selectYear {
    return Intl.message('Select Year', name: 'selectYear', desc: '', args: []);
  }

  /// `Attendance Summary`
  String get attendanceSummary {
    return Intl.message(
      'Attendance Summary',
      name: 'attendanceSummary',
      desc: '',
      args: [],
    );
  }

  /// `Yesterday's Attendance`
  String get yesterdaysAttendance {
    return Intl.message(
      'Yesterday\'s Attendance',
      name: 'yesterdaysAttendance',
      desc: '',
      args: [],
    );
  }

  /// `Attendance`
  String get attendance {
    return Intl.message('Attendance', name: 'attendance', desc: '', args: []);
  }

  /// `Fetching live data...`
  String get fetchingData {
    return Intl.message(
      'Fetching live data...',
      name: 'fetchingData',
      desc: '',
      args: [],
    );
  }

  /// `N/A`
  String get na {
    return Intl.message('N/A', name: 'na', desc: '', args: []);
  }

  /// `Loading...`
  String get loading {
    return Intl.message('Loading...', name: 'loading', desc: '', args: []);
  }

  /// `Good Morning, {name} 👋`
  String goodMorning(Object name) {
    return Intl.message(
      'Good Morning, $name 👋',
      name: 'goodMorning',
      desc: '',
      args: [name],
    );
  }

  /// `Good Afternoon, {name} 👋`
  String goodAfternoon(Object name) {
    return Intl.message(
      'Good Afternoon, $name 👋',
      name: 'goodAfternoon',
      desc: '',
      args: [name],
    );
  }

  /// `Good Evening, {name} 👋`
  String goodEvening(Object name) {
    return Intl.message(
      'Good Evening, $name 👋',
      name: 'goodEvening',
      desc: '',
      args: [name],
    );
  }

  /// `January`
  String get monthJan {
    return Intl.message('January', name: 'monthJan', desc: '', args: []);
  }

  /// `February`
  String get monthFeb {
    return Intl.message('February', name: 'monthFeb', desc: '', args: []);
  }

  /// `March`
  String get monthMar {
    return Intl.message('March', name: 'monthMar', desc: '', args: []);
  }

  /// `April`
  String get monthApr {
    return Intl.message('April', name: 'monthApr', desc: '', args: []);
  }

  /// `May`
  String get monthMay {
    return Intl.message('May', name: 'monthMay', desc: '', args: []);
  }

  /// `June`
  String get monthJun {
    return Intl.message('June', name: 'monthJun', desc: '', args: []);
  }

  /// `July`
  String get monthJul {
    return Intl.message('July', name: 'monthJul', desc: '', args: []);
  }

  /// `August`
  String get monthAug {
    return Intl.message('August', name: 'monthAug', desc: '', args: []);
  }

  /// `September`
  String get monthSep {
    return Intl.message('September', name: 'monthSep', desc: '', args: []);
  }

  /// `October`
  String get monthOct {
    return Intl.message('October', name: 'monthOct', desc: '', args: []);
  }

  /// `November`
  String get monthNov {
    return Intl.message('November', name: 'monthNov', desc: '', args: []);
  }

  /// `December`
  String get monthDec {
    return Intl.message('December', name: 'monthDec', desc: '', args: []);
  }

  /// `Lunch Out`
  String get lunchOut {
    return Intl.message('Lunch Out', name: 'lunchOut', desc: '', args: []);
  }

  /// `Lunch In`
  String get lunchIn {
    return Intl.message('Lunch In', name: 'lunchIn', desc: '', args: []);
  }

  /// `On time`
  String get onTime {
    return Intl.message('On time', name: 'onTime', desc: '', args: []);
  }

  /// `Early Out`
  String get earlyOut {
    return Intl.message('Early Out', name: 'earlyOut', desc: '', args: []);
  }

  /// `Attendance Calendar`
  String get attendanceCalendar {
    return Intl.message(
      'Attendance Calendar',
      name: 'attendanceCalendar',
      desc: '',
      args: [],
    );
  }

  /// `Payslip`
  String get payslip {
    return Intl.message('Payslip', name: 'payslip', desc: '', args: []);
  }

  /// `Mecon Bharti`
  String get meconBharti {
    return Intl.message(
      'Mecon Bharti',
      name: 'meconBharti',
      desc: '',
      args: [],
    );
  }

  /// `TechQuest`
  String get techQuest {
    return Intl.message('TechQuest', name: 'techQuest', desc: '', args: []);
  }

  /// `Circulars`
  String get circulars {
    return Intl.message('Circulars', name: 'circulars', desc: '', args: []);
  }

  /// `Programmes`
  String get programmes {
    return Intl.message('Programmes', name: 'programmes', desc: '', args: []);
  }

  /// `TACD`
  String get tacd {
    return Intl.message('TACD', name: 'tacd', desc: '', args: []);
  }

  /// `HR Sandesh`
  String get hrSandesh {
    return Intl.message('HR Sandesh', name: 'hrSandesh', desc: '', args: []);
  }

  /// `Policies/Guidelines`
  String get policiesGuidelines {
    return Intl.message(
      'Policies/Guidelines',
      name: 'policiesGuidelines',
      desc: '',
      args: [],
    );
  }

  /// `PDP`
  String get pdp {
    return Intl.message('PDP', name: 'pdp', desc: '', args: []);
  }

  /// `Today's Punch Log`
  String get todaysPunchLog {
    return Intl.message(
      'Today\'s Punch Log',
      name: 'todaysPunchLog',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'hi'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
