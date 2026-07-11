import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @accessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access Denied!'**
  String get accessDenied;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addAnotherLine.
  ///
  /// In en, this message translates to:
  /// **'Add another line'**
  String get addAnotherLine;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @allowance.
  ///
  /// In en, this message translates to:
  /// **'Allowance'**
  String get allowance;

  /// No description provided for @alreadyCheckedInToday.
  ///
  /// In en, this message translates to:
  /// **'Today, already check in'**
  String get alreadyCheckedInToday;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @approvalChain.
  ///
  /// In en, this message translates to:
  /// **'Approval chain'**
  String get approvalChain;

  /// No description provided for @approvalOrDownload.
  ///
  /// In en, this message translates to:
  /// **'Approval Or Download'**
  String get approvalOrDownload;

  /// No description provided for @approvals.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get approvals;

  /// No description provided for @approvalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Requests waiting for your approval'**
  String get approvalsSubtitle;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @approverFor.
  ///
  /// In en, this message translates to:
  /// **'Approver — {role}'**
  String approverFor(String role);

  /// No description provided for @attachmentMedicalLeave.
  ///
  /// In en, this message translates to:
  /// **'Attachment ( For medical leave )'**
  String get attachmentMedicalLeave;

  /// No description provided for @attachmentOptional.
  ///
  /// In en, this message translates to:
  /// **'Attachment ( optional )'**
  String get attachmentOptional;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @attendanceDataDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Attendance data downloaded'**
  String get attendanceDataDownloaded;

  /// No description provided for @attendanceDateExists.
  ///
  /// In en, this message translates to:
  /// **'Attendance date is already exist in the system.'**
  String get attendanceDateExists;

  /// No description provided for @attendanceJustification.
  ///
  /// In en, this message translates to:
  /// **'Attendance Justification'**
  String get attendanceJustification;

  /// No description provided for @authenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get authenticationFailed;

  /// No description provided for @autoCheckout.
  ///
  /// In en, this message translates to:
  /// **'Auto Checkout'**
  String get autoCheckout;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @basic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get basic;

  /// No description provided for @billReference.
  ///
  /// In en, this message translates to:
  /// **'Bill Reference'**
  String get billReference;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cancelMyRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel my request'**
  String get cancelMyRequest;

  /// No description provided for @cancelRequestBody.
  ///
  /// In en, this message translates to:
  /// **'This will withdraw your request.'**
  String get cancelRequestBody;

  /// No description provided for @cancelRequestQ.
  ///
  /// In en, this message translates to:
  /// **'Cancel request?'**
  String get cancelRequestQ;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check In'**
  String get checkIn;

  /// No description provided for @checkInFail.
  ///
  /// In en, this message translates to:
  /// **'Check In Fail.'**
  String get checkInFail;

  /// No description provided for @checkInSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Check In Successful'**
  String get checkInSuccessful;

  /// No description provided for @checkOut.
  ///
  /// In en, this message translates to:
  /// **'Check Out'**
  String get checkOut;

  /// No description provided for @checkOutSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Check Out Successful'**
  String get checkOutSuccessful;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose Date'**
  String get chooseDate;

  /// No description provided for @commentOptional.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get commentOptional;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @createPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Password'**
  String get createPasswordTitle;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @currentPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Current Password not correct'**
  String get currentPasswordIncorrect;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @dailyRate.
  ///
  /// In en, this message translates to:
  /// **'Daily Rate'**
  String get dailyRate;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @dateSelectFailed.
  ///
  /// In en, this message translates to:
  /// **'Date Select Failed'**
  String get dateSelectFailed;

  /// No description provided for @deduction.
  ///
  /// In en, this message translates to:
  /// **'Deduction'**
  String get deduction;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @deviceInfoLoading.
  ///
  /// In en, this message translates to:
  /// **'Device information is still loading. Please try again.'**
  String get deviceInfoLoading;

  /// No description provided for @directMessage.
  ///
  /// In en, this message translates to:
  /// **'Direct Message'**
  String get directMessage;

  /// No description provided for @discuss.
  ///
  /// In en, this message translates to:
  /// **'Discuss'**
  String get discuss;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @durationColon.
  ///
  /// In en, this message translates to:
  /// **'Duration :'**
  String get durationColon;

  /// No description provided for @earlyLeave.
  ///
  /// In en, this message translates to:
  /// **'Early Leave'**
  String get earlyLeave;

  /// No description provided for @employeeCode.
  ///
  /// In en, this message translates to:
  /// **'Employee Code'**
  String get employeeCode;

  /// No description provided for @employeeDataDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Employee data downloaded'**
  String get employeeDataDownloaded;

  /// No description provided for @employeeDataMissing.
  ///
  /// In en, this message translates to:
  /// **'Employee data is missing on this device.'**
  String get employeeDataMissing;

  /// No description provided for @employeeId.
  ///
  /// In en, this message translates to:
  /// **'Employee ID'**
  String get employeeId;

  /// No description provided for @employeeName.
  ///
  /// In en, this message translates to:
  /// **'Employee Name'**
  String get employeeName;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @endDateSelectError.
  ///
  /// In en, this message translates to:
  /// **'End Date Select Error'**
  String get endDateSelectError;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount...........'**
  String get enterAmount;

  /// No description provided for @enterPasswordToAccess.
  ///
  /// In en, this message translates to:
  /// **'Enter Password To Access'**
  String get enterPasswordToAccess;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @escalatedToManager.
  ///
  /// In en, this message translates to:
  /// **'Escalated to manager'**
  String get escalatedToManager;

  /// No description provided for @exitAppConfirm.
  ///
  /// In en, this message translates to:
  /// **'You are going to exit the application!'**
  String get exitAppConfirm;

  /// No description provided for @fail.
  ///
  /// In en, this message translates to:
  /// **'Fail'**
  String get fail;

  /// No description provided for @failedToCreateGroup.
  ///
  /// In en, this message translates to:
  /// **'Failed to create group'**
  String get failedToCreateGroup;

  /// No description provided for @failedToFindEmployee.
  ///
  /// In en, this message translates to:
  /// **'Failed to find employee'**
  String get failedToFindEmployee;

  /// No description provided for @failedToSendImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to send image. Please try again.'**
  String get failedToSendImage;

  /// No description provided for @failedToSendPhoto.
  ///
  /// In en, this message translates to:
  /// **'Failed to send photo. Please try again.'**
  String get failedToSendPhoto;

  /// No description provided for @failedToStartConversation.
  ///
  /// In en, this message translates to:
  /// **'Failed to start conversation'**
  String get failedToStartConversation;

  /// No description provided for @fetchingData.
  ///
  /// In en, this message translates to:
  /// **'Fetching data...'**
  String get fetchingData;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{label} is required'**
  String fieldRequired(String label);

  /// No description provided for @fieldWork.
  ///
  /// In en, this message translates to:
  /// **'Field Work'**
  String get fieldWork;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @gettingCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting current location...'**
  String get gettingCurrentLocation;

  /// No description provided for @goodDayMessage.
  ///
  /// In en, this message translates to:
  /// **'Have a good day with full of productivity and good vibes.'**
  String get goodDayMessage;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning, {name}'**
  String goodMorning(String name);

  /// No description provided for @grossDeduction.
  ///
  /// In en, this message translates to:
  /// **'Gross Deduction'**
  String get grossDeduction;

  /// No description provided for @grossEarning.
  ///
  /// In en, this message translates to:
  /// **'Gross Earning'**
  String get grossEarning;

  /// No description provided for @grossSalary.
  ///
  /// In en, this message translates to:
  /// **'Gross Salary'**
  String get grossSalary;

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'Group name...'**
  String get groupNameHint;

  /// No description provided for @halfDay.
  ///
  /// In en, this message translates to:
  /// **'Half Day'**
  String get halfDay;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @homePhone.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homePhone;

  /// No description provided for @hourlyRate.
  ///
  /// In en, this message translates to:
  /// **'Hourly Rate'**
  String get hourlyRate;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @hrAdmin.
  ///
  /// In en, this message translates to:
  /// **'HR & Admin'**
  String get hrAdmin;

  /// No description provided for @hrAdminNoAccess.
  ///
  /// In en, this message translates to:
  /// **'You do not have access to the HR & Admin menu.'**
  String get hrAdminNoAccess;

  /// No description provided for @imageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get imageUnavailable;

  /// No description provided for @inOffice.
  ///
  /// In en, this message translates to:
  /// **'In Office'**
  String get inOffice;

  /// No description provided for @inOutside.
  ///
  /// In en, this message translates to:
  /// **'In: Outside'**
  String get inOutside;

  /// No description provided for @inbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inbox;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid Password'**
  String get invalidPassword;

  /// No description provided for @justificationRequests.
  ///
  /// In en, this message translates to:
  /// **'Justification Requests'**
  String get justificationRequests;

  /// No description provided for @justifications.
  ///
  /// In en, this message translates to:
  /// **'Justifications'**
  String get justifications;

  /// No description provided for @justify.
  ///
  /// In en, this message translates to:
  /// **'Justify'**
  String get justify;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @leaveDataDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Leave data downloaded'**
  String get leaveDataDownloaded;

  /// No description provided for @leaveHistory.
  ///
  /// In en, this message translates to:
  /// **'Leave History'**
  String get leaveHistory;

  /// No description provided for @leaveHistoryDetail.
  ///
  /// In en, this message translates to:
  /// **'Leave History Detail'**
  String get leaveHistoryDetail;

  /// No description provided for @leaveHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your submitted time off requests'**
  String get leaveHistorySubtitle;

  /// No description provided for @leaveReason.
  ///
  /// In en, this message translates to:
  /// **'Leave Reason'**
  String get leaveReason;

  /// No description provided for @leaveRequest.
  ///
  /// In en, this message translates to:
  /// **'Leave Request'**
  String get leaveRequest;

  /// No description provided for @leaveRequestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Submit a new time off request'**
  String get leaveRequestSubtitle;

  /// No description provided for @linesCount.
  ///
  /// In en, this message translates to:
  /// **'Lines ({count})'**
  String linesCount(int count);

  /// No description provided for @linkedLoan.
  ///
  /// In en, this message translates to:
  /// **'Linked loan'**
  String get linkedLoan;

  /// No description provided for @loanNumber.
  ///
  /// In en, this message translates to:
  /// **'Loan #{id}'**
  String loanNumber(String id);

  /// No description provided for @loanWithRemaining.
  ///
  /// In en, this message translates to:
  /// **'{name}  (remaining {amount})'**
  String loanWithRemaining(String name, String amount);

  /// No description provided for @loans.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get loans;

  /// No description provided for @missedCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Missed Check-In'**
  String get missedCheckIn;

  /// No description provided for @missedCheckOut.
  ///
  /// In en, this message translates to:
  /// **'Missed Check-Out'**
  String get missedCheckOut;

  /// No description provided for @missingCheckout.
  ///
  /// In en, this message translates to:
  /// **'Missing Checkout'**
  String get missingCheckout;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @myLeaveHistory.
  ///
  /// In en, this message translates to:
  /// **'My Leave History'**
  String get myLeaveHistory;

  /// No description provided for @myLoans.
  ///
  /// In en, this message translates to:
  /// **'My loans'**
  String get myLoans;

  /// No description provided for @myLoans2.
  ///
  /// In en, this message translates to:
  /// **'My Loans'**
  String get myLoans2;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get myRequests;

  /// No description provided for @myRequestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track the status of your requests'**
  String get myRequestsSubtitle;

  /// No description provided for @net.
  ///
  /// In en, this message translates to:
  /// **'NET'**
  String get net;

  /// No description provided for @netAmount.
  ///
  /// In en, this message translates to:
  /// **'Net Amount'**
  String get netAmount;

  /// No description provided for @newGroup.
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get newGroup;

  /// No description provided for @newLeaveRequest.
  ///
  /// In en, this message translates to:
  /// **'New Leave Request'**
  String get newLeaveRequest;

  /// No description provided for @newMessage.
  ///
  /// In en, this message translates to:
  /// **'New Message'**
  String get newMessage;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @newPaymentRequest.
  ///
  /// In en, this message translates to:
  /// **'New Payment Request'**
  String get newPaymentRequest;

  /// No description provided for @newRequest.
  ///
  /// In en, this message translates to:
  /// **'New Request'**
  String get newRequest;

  /// No description provided for @newRequestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Letters, loans, custody, vehicles and more'**
  String get newRequestSubtitle;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @noActiveLoans.
  ///
  /// In en, this message translates to:
  /// **'No active loans found. This request type requires a running loan.'**
  String get noActiveLoans;

  /// No description provided for @noConversationsYet.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversationsYet;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get noData;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No data found, please try again later.'**
  String get noDataFound;

  /// No description provided for @noFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get noFileSelected;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet !'**
  String get noInternet;

  /// No description provided for @noLoansOrAdvances.
  ///
  /// In en, this message translates to:
  /// **'No loans or advances'**
  String get noLoansOrAdvances;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @noRecordsFound.
  ///
  /// In en, this message translates to:
  /// **'0 records found'**
  String get noRecordsFound;

  /// No description provided for @noRequestTypes.
  ///
  /// In en, this message translates to:
  /// **'No request types available'**
  String get noRequestTypes;

  /// No description provided for @noRequestsYet.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get noRequestsYet;

  /// No description provided for @notAllowedLocation.
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to check in/out from this location'**
  String get notAllowedLocation;

  /// No description provided for @notInAllowedArea.
  ///
  /// In en, this message translates to:
  /// **'Not in allowed area'**
  String get notInAllowedArea;

  /// No description provided for @notInAllowedAreaMsg.
  ///
  /// In en, this message translates to:
  /// **'You are not in allowed area!'**
  String get notInAllowedAreaMsg;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @nothingWaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting for your approval'**
  String get nothingWaitingApproval;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @outOutside.
  ///
  /// In en, this message translates to:
  /// **'Out: Outside'**
  String get outOutside;

  /// No description provided for @outsideLocation.
  ///
  /// In en, this message translates to:
  /// **'Outside Location'**
  String get outsideLocation;

  /// No description provided for @overrideLabel.
  ///
  /// In en, this message translates to:
  /// **'Override'**
  String get overrideLabel;

  /// No description provided for @overrideAndApprove.
  ///
  /// In en, this message translates to:
  /// **'Override & approve'**
  String get overrideAndApprove;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @paidOf.
  ///
  /// In en, this message translates to:
  /// **'Paid {paid} of {total}'**
  String paidOf(String paid, String total);

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordBlank.
  ///
  /// In en, this message translates to:
  /// **'New or confirm password is blank.Please try again.'**
  String get passwordBlank;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password successfully changed.'**
  String get passwordChanged;

  /// No description provided for @passwordDoesNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Password does not match'**
  String get passwordDoesNotMatch;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Password and confirm password do not match'**
  String get passwordMismatch;

  /// No description provided for @paymentDataDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Payment request data downloaded'**
  String get paymentDataDownloaded;

  /// No description provided for @paymentItem.
  ///
  /// In en, this message translates to:
  /// **'Payment Item'**
  String get paymentItem;

  /// No description provided for @paymentRequest.
  ///
  /// In en, this message translates to:
  /// **'Payment Request'**
  String get paymentRequest;

  /// No description provided for @paymentRequestDetail.
  ///
  /// In en, this message translates to:
  /// **'Payment Request Detail'**
  String get paymentRequestDetail;

  /// No description provided for @paymentRequestHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment Request History'**
  String get paymentRequestHistory;

  /// No description provided for @payslip.
  ///
  /// In en, this message translates to:
  /// **'Pay Slip'**
  String get payslip;

  /// No description provided for @payslipDataDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Payslip data downloaded'**
  String get payslipDataDownloaded;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @pick.
  ///
  /// In en, this message translates to:
  /// **'Pick'**
  String get pick;

  /// No description provided for @pleaseCheckInOut.
  ///
  /// In en, this message translates to:
  /// **'Please Check In/Out For Your Attendance'**
  String get pleaseCheckInOut;

  /// No description provided for @pleaseChooseStartDateFirst.
  ///
  /// In en, this message translates to:
  /// **'Please choose Start Date First'**
  String get pleaseChooseStartDateFirst;

  /// No description provided for @pleaseContact.
  ///
  /// In en, this message translates to:
  /// **'Please contact'**
  String get pleaseContact;

  /// No description provided for @pleaseEnterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter description'**
  String get pleaseEnterDescription;

  /// No description provided for @pleaseEnterGroupName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a group name'**
  String get pleaseEnterGroupName;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// No description provided for @pleaseEnterReason.
  ///
  /// In en, this message translates to:
  /// **'Please enter reason'**
  String get pleaseEnterReason;

  /// No description provided for @pleaseEnterTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter total amount'**
  String get pleaseEnterTotalAmount;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get pleaseEnterUsername;

  /// No description provided for @pleaseSelectCorrectEndDate.
  ///
  /// In en, this message translates to:
  /// **'Please select correct End Date'**
  String get pleaseSelectCorrectEndDate;

  /// No description provided for @pleaseSelectDayType.
  ///
  /// In en, this message translates to:
  /// **'Please select day type'**
  String get pleaseSelectDayType;

  /// No description provided for @pleaseSelectLeaveType.
  ///
  /// In en, this message translates to:
  /// **'Please select leave type'**
  String get pleaseSelectLeaveType;

  /// No description provided for @pleaseSelectOneMember.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one member'**
  String get pleaseSelectOneMember;

  /// No description provided for @pleaseSelectPaymentItem.
  ///
  /// In en, this message translates to:
  /// **'Please select payment item'**
  String get pleaseSelectPaymentItem;

  /// No description provided for @pleaseSelectRelatedLoan.
  ///
  /// In en, this message translates to:
  /// **'Please select the related loan'**
  String get pleaseSelectRelatedLoan;

  /// No description provided for @pleaseSelectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Please select start date'**
  String get pleaseSelectStartDate;

  /// No description provided for @pleaseSelectValidDate.
  ///
  /// In en, this message translates to:
  /// **'Please select valid date'**
  String get pleaseSelectValidDate;

  /// No description provided for @pleaseUploadDocument.
  ///
  /// In en, this message translates to:
  /// **'Please upload document'**
  String get pleaseUploadDocument;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @reasonIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Reason is required'**
  String get reasonIsRequired;

  /// No description provided for @reasonOptional.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get reasonOptional;

  /// No description provided for @reasonRequired2.
  ///
  /// In en, this message translates to:
  /// **'Reason *'**
  String get reasonRequired2;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// No description provided for @refreshOrCheckInternet.
  ///
  /// In en, this message translates to:
  /// **'Refresh the page or check your internet connection.'**
  String get refreshOrCheckInternet;

  /// No description provided for @refuse.
  ///
  /// In en, this message translates to:
  /// **'Refuse'**
  String get refuse;

  /// No description provided for @refused.
  ///
  /// In en, this message translates to:
  /// **'Refused'**
  String get refused;

  /// No description provided for @registerYourPresence.
  ///
  /// In en, this message translates to:
  /// **'Register Your Presence And Start'**
  String get registerYourPresence;

  /// No description provided for @registrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Registration Number'**
  String get registrationNumber;

  /// No description provided for @relatedLoanRequired.
  ///
  /// In en, this message translates to:
  /// **'Related loan *'**
  String get relatedLoanRequired;

  /// No description provided for @remainingAmount.
  ///
  /// In en, this message translates to:
  /// **'remaining {amount}'**
  String remainingAmount(String amount);

  /// No description provided for @remoteWfh.
  ///
  /// In en, this message translates to:
  /// **'Remote / WFH'**
  String get remoteWfh;

  /// No description provided for @requestApproved.
  ///
  /// In en, this message translates to:
  /// **'Request approved'**
  String get requestApproved;

  /// No description provided for @requestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled'**
  String get requestCancelled;

  /// No description provided for @requestCreated.
  ///
  /// In en, this message translates to:
  /// **'Request successfully created.'**
  String get requestCreated;

  /// No description provided for @requestNumber.
  ///
  /// In en, this message translates to:
  /// **'Request #{id}'**
  String requestNumber(String id);

  /// No description provided for @requestOverridden.
  ///
  /// In en, this message translates to:
  /// **'Request overridden'**
  String get requestOverridden;

  /// No description provided for @requestRefused.
  ///
  /// In en, this message translates to:
  /// **'Request refused'**
  String get requestRefused;

  /// No description provided for @requestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Request submitted'**
  String get requestSubmitted;

  /// No description provided for @requestTypesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} request types'**
  String requestTypesCount(int count);

  /// No description provided for @requestsAndLeave.
  ///
  /// In en, this message translates to:
  /// **'Requests & Leave'**
  String get requestsAndLeave;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @salarySlip.
  ///
  /// In en, this message translates to:
  /// **'Salary Slip'**
  String get salarySlip;

  /// No description provided for @searchEmployee.
  ///
  /// In en, this message translates to:
  /// **'Search employee...'**
  String get searchEmployee;

  /// No description provided for @secondApproval.
  ///
  /// In en, this message translates to:
  /// **'Second Approval'**
  String get secondApproval;

  /// No description provided for @selectDatabase.
  ///
  /// In en, this message translates to:
  /// **'Select Database'**
  String get selectDatabase;

  /// No description provided for @selectDayType.
  ///
  /// In en, this message translates to:
  /// **'Select day Type'**
  String get selectDayType;

  /// No description provided for @selectEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Select...'**
  String get selectEllipsis;

  /// No description provided for @selectLeaveType.
  ///
  /// In en, this message translates to:
  /// **'Select Leave Type'**
  String get selectLeaveType;

  /// No description provided for @selectPaymentItem.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Item'**
  String get selectPaymentItem;

  /// No description provided for @selectTax.
  ///
  /// In en, this message translates to:
  /// **'Select Tax'**
  String get selectTax;

  /// No description provided for @selectWorkMode.
  ///
  /// In en, this message translates to:
  /// **'Select Work Mode'**
  String get selectWorkMode;

  /// No description provided for @sendImage.
  ///
  /// In en, this message translates to:
  /// **'Send Image'**
  String get sendImage;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session Expired.Please login again.'**
  String get sessionExpired;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'signing in...'**
  String get signingIn;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @startYourId.
  ///
  /// In en, this message translates to:
  /// **'Start Your ID'**
  String get startYourId;

  /// No description provided for @statusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get statusNew;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitted;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @submittingPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Submitting. Please Wait...'**
  String get submittingPleaseWait;

  /// No description provided for @takeAttachmentPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take attachment photo'**
  String get takeAttachmentPhoto;

  /// No description provided for @tapChatToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap the chat button to start'**
  String get tapChatToStart;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @toApprove.
  ///
  /// In en, this message translates to:
  /// **'To Approve'**
  String get toApprove;

  /// No description provided for @toConfirm.
  ///
  /// In en, this message translates to:
  /// **'To Confirm'**
  String get toConfirm;

  /// No description provided for @toReport.
  ///
  /// In en, this message translates to:
  /// **'To Report'**
  String get toReport;

  /// No description provided for @toSubmit.
  ///
  /// In en, this message translates to:
  /// **'To Submit'**
  String get toSubmit;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @todaysSummary.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Summary'**
  String get todaysSummary;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @totalWithValue.
  ///
  /// In en, this message translates to:
  /// **'Total: {value}'**
  String totalWithValue(String value);

  /// No description provided for @turnOnInternetMessage.
  ///
  /// In en, this message translates to:
  /// **'Your device will need to make sure wifi or mobile data are turn on.'**
  String get turnOnInternetMessage;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waiting;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @workEmail.
  ///
  /// In en, this message translates to:
  /// **'Work Email'**
  String get workEmail;

  /// No description provided for @workFromOutside.
  ///
  /// In en, this message translates to:
  /// **'Work From Outside'**
  String get workFromOutside;

  /// No description provided for @workPhone.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get workPhone;

  /// No description provided for @writeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Write a message...'**
  String get writeAMessage;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, cancel'**
  String get yesCancel;

  /// No description provided for @youDontHaveAccess.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have access'**
  String get youDontHaveAccess;

  /// No description provided for @yourWork.
  ///
  /// In en, this message translates to:
  /// **'Your Work'**
  String get yourWork;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
