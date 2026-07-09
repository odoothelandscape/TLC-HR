import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

/// Generated file — do not edit by hand. Run `flutter gen-l10n` to regenerate.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  String get accessDenied;

  String get add;

  String get addAnotherLine;

  String get afternoon;

  String get all;

  String get allowance;

  String get alreadyCheckedInToday;

  String get amount;

  String get approvalChain;

  String get approvalOrDownload;

  String get approvals;

  String get approvalsSubtitle;

  String get approve;

  String get approved;

  String approverFor(String role);

  String get attachmentMedicalLeave;

  String get attachmentOptional;

  String get attachments;

  String get attendance;

  String get attendanceDataDownloaded;

  String get attendanceDateExists;

  String get attendanceJustification;

  String get authenticationFailed;

  String get autoCheckout;

  String get back;

  String get basic;

  String get billReference;

  String get birthday;

  String get camera;

  String get cancel;

  String get cancelMyRequest;

  String get cancelRequestBody;

  String get cancelRequestQ;

  String get cancelled;

  String get change;

  String get changePassword;

  String get chat;

  String get checkIn;

  String get checkInFail;

  String get checkInSuccessful;

  String get checkOut;

  String get checkOutSuccessful;

  String get chooseDate;

  String get commentOptional;

  String get confirm;

  String get confirmPassword;

  String get confirmation;

  String get create;

  String get createPasswordTitle;

  String get currentPassword;

  String get currentPasswordIncorrect;

  String get custom;

  String get dailyRate;

  String get date;

  String get dateSelectFailed;

  String get deduction;

  String get department;

  String get description;

  String get details;

  String get deviceInfoLoading;

  String get directMessage;

  String get discuss;

  String get duration;

  String get durationColon;

  String get earlyLeave;

  String get employeeCode;

  String get employeeDataDownloaded;

  String get employeeDataMissing;

  String get employeeId;

  String get employeeName;

  String get endDate;

  String get endDateSelectError;

  String get endTime;

  String get enterAmount;

  String get enterPasswordToAccess;

  String get enterValidNumber;

  String get escalatedToManager;

  String get exitAppConfirm;

  String get fail;

  String get failedToCreateGroup;

  String get failedToFindEmployee;

  String get failedToSendImage;

  String get failedToSendPhoto;

  String get failedToStartConversation;

  String get fetchingData;

  String fieldRequired(String label);

  String get fieldWork;

  String get gender;

  String get gettingCurrentLocation;

  String get goodDayMessage;

  String goodMorning(String name);

  String get grossDeduction;

  String get grossEarning;

  String get grossSalary;

  String get groupNameHint;

  String get halfDay;

  String get history;

  String get homePhone;

  String get hourlyRate;

  String get hours;

  String get hrAdmin;

  String get hrAdminNoAccess;

  String get imageUnavailable;

  String get inOffice;

  String get inOutside;

  String get inbox;

  String get invalidPassword;

  String get justificationRequests;

  String get justifications;

  String get justify;

  String get language;

  String get leaveDataDownloaded;

  String get leaveHistory;

  String get leaveHistoryDetail;

  String get leaveHistorySubtitle;

  String get leaveReason;

  String get leaveRequest;

  String get leaveRequestSubtitle;

  String linesCount(int count);

  String get linkedLoan;

  String loanNumber(String id);

  String loanWithRemaining(String name, String amount);

  String get loans;

  String get missedCheckIn;

  String get missedCheckOut;

  String get missingCheckout;

  String get morning;

  String get myLeaveHistory;

  String get myLoans;

  String get myLoans2;

  String get myRequests;

  String get myRequestsSubtitle;

  String get net;

  String get netAmount;

  String get newGroup;

  String get newLeaveRequest;

  String get newMessage;

  String get newPassword;

  String get newPaymentRequest;

  String get newRequest;

  String get newRequestSubtitle;

  String get no;

  String get noActiveLoans;

  String get noConversationsYet;

  String get noData;

  String get noDataFound;

  String get noFileSelected;

  String get noInternet;

  String get noLoansOrAdvances;

  String get noMessagesYet;

  String get noRecordsFound;

  String get noRequestTypes;

  String get noRequestsYet;

  String get notAllowedLocation;

  String get notInAllowedArea;

  String get notInAllowedAreaMsg;

  String get note;

  String get noteOptional;

  String get nothingWaitingApproval;

  String get ok;

  String get outOutside;

  String get outsideLocation;

  String get overrideLabel;

  String get overrideAndApprove;

  String get paid;

  String paidOf(String paid, String total);

  String get password;

  String get passwordBlank;

  String get passwordChanged;

  String get passwordDoesNotMatch;

  String get passwordMismatch;

  String get paymentDataDownloaded;

  String get paymentItem;

  String get paymentRequest;

  String get paymentRequestDetail;

  String get paymentRequestHistory;

  String get payslip;

  String get payslipDataDownloaded;

  String get pending;

  String get pick;

  String get pleaseCheckInOut;

  String get pleaseChooseStartDateFirst;

  String get pleaseContact;

  String get pleaseEnterDescription;

  String get pleaseEnterGroupName;

  String get pleaseEnterPassword;

  String get pleaseEnterReason;

  String get pleaseEnterTotalAmount;

  String get pleaseEnterUsername;

  String get pleaseSelectCorrectEndDate;

  String get pleaseSelectDayType;

  String get pleaseSelectLeaveType;

  String get pleaseSelectOneMember;

  String get pleaseSelectPaymentItem;

  String get pleaseSelectRelatedLoan;

  String get pleaseSelectStartDate;

  String get pleaseSelectValidDate;

  String get pleaseUploadDocument;

  String get position;

  String get reason;

  String get reasonIsRequired;

  String get reasonOptional;

  String get reasonRequired2;

  String get reference;

  String get refreshOrCheckInternet;

  String get refuse;

  String get refused;

  String get registerYourPresence;

  String get registrationNumber;

  String get relatedLoanRequired;

  String remainingAmount(String amount);

  String get remoteWfh;

  String get requestApproved;

  String get requestCancelled;

  String get requestCreated;

  String requestNumber(String id);

  String get requestOverridden;

  String get requestRefused;

  String get requestSubmitted;

  String requestTypesCount(int count);

  String get requestsAndLeave;

  String get retry;

  String get salarySlip;

  String get searchEmployee;

  String get secondApproval;

  String get selectDatabase;

  String get selectDayType;

  String get selectEllipsis;

  String get selectLeaveType;

  String get selectPaymentItem;

  String get selectTax;

  String get selectWorkMode;

  String get sendImage;

  String get sessionExpired;

  String get signOut;

  String get signingIn;

  String get skip;

  String get startDate;

  String get startYourId;

  String get statusNew;

  String get submit;

  String get submitRequest;

  String get submitted;

  String get submitting;

  String get submittingPleaseWait;

  String get takeAttachmentPhoto;

  String get tapChatToStart;

  String get tax;

  String get to;

  String get toApprove;

  String get toConfirm;

  String get toReport;

  String get toSubmit;

  String get today;

  String get todaysSummary;

  String get totalLabel;

  String totalWithValue(String value);

  String get turnOnInternetMessage;

  String get type;

  String get waiting;

  String get welcome;

  String get workEmail;

  String get workFromOutside;

  String get workPhone;

  String get writeAMessage;

  String get yesCancel;

  String get youDontHaveAccess;

  String get yourWork;

}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }
  throw FlutterError('AppLocalizations.delegate failed to load unsupported locale "\$locale".');
}
