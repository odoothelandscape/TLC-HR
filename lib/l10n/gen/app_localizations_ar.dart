import 'app_localizations.dart';

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get accessDenied => 'تم رفض الوصول!';

  @override
  String get add => 'إضافة';

  @override
  String get addAnotherLine => 'إضافة بند آخر';

  @override
  String get afternoon => 'مسائية';

  @override
  String get all => 'الكل';

  @override
  String get allowance => 'البدلات';

  @override
  String get alreadyCheckedInToday => 'تم تسجيل الحضور اليوم بالفعل';

  @override
  String get amount => 'المبلغ';

  @override
  String get approvalChain => 'سلسلة الاعتماد';

  @override
  String get approvalOrDownload => 'الاعتماد أو التنزيل';

  @override
  String get approvals => 'الاعتمادات';

  @override
  String get approvalsSubtitle => 'طلبات بانتظار اعتمادك';

  @override
  String get approve => 'اعتماد';

  @override
  String get approved => 'معتمد';

  @override
  String approverFor(String role) {
    return 'المعتمد — $role';
  }

  @override
  String get attachmentMedicalLeave => 'مرفق (للإجازة المرضية)';

  @override
  String get attachmentOptional => 'مرفق (اختياري)';

  @override
  String get attachments => 'المرفقات';

  @override
  String get attendance => 'الحضور';

  @override
  String get attendanceDataDownloaded => 'تم تنزيل بيانات الحضور';

  @override
  String get attendanceDateExists => 'تاريخ الحضور مسجل مسبقاً في النظام.';

  @override
  String get attendanceJustification => 'تبرير الحضور';

  @override
  String get authenticationFailed => 'فشل التحقق';

  @override
  String get autoCheckout => 'انصراف تلقائي';

  @override
  String get back => 'رجوع';

  @override
  String get basic => 'الأساسي';

  @override
  String get billReference => 'مرجع الفاتورة';

  @override
  String get birthday => 'تاريخ الميلاد';

  @override
  String get camera => 'الكاميرا';

  @override
  String get cancel => 'إلغاء';

  @override
  String get cancelMyRequest => 'إلغاء طلبي';

  @override
  String get cancelRequestBody => 'سيتم سحب طلبك.';

  @override
  String get cancelRequestQ => 'إلغاء الطلب؟';

  @override
  String get cancelled => 'ملغي';

  @override
  String get change => 'تغيير';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get chat => 'محادثة';

  @override
  String get checkIn => 'تسجيل حضور';

  @override
  String get checkInFail => 'فشل تسجيل الحضور.';

  @override
  String get checkInSuccessful => 'تم تسجيل الحضور بنجاح';

  @override
  String get checkOut => 'تسجيل انصراف';

  @override
  String get checkOutSuccessful => 'تم تسجيل الانصراف بنجاح';

  @override
  String get chooseDate => 'اختر التاريخ';

  @override
  String get commentOptional => 'ملاحظة (اختياري)';

  @override
  String get confirm => 'تأكيد';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get confirmation => 'تأكيد';

  @override
  String get create => 'إنشاء';

  @override
  String get createPasswordTitle => 'إنشاء كلمة مرور';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get currentPasswordIncorrect => 'كلمة المرور الحالية غير صحيحة';

  @override
  String get custom => 'مخصص';

  @override
  String get dailyRate => 'الأجر اليومي';

  @override
  String get date => 'التاريخ';

  @override
  String get dateSelectFailed => 'فشل اختيار التاريخ';

  @override
  String get deduction => 'الاستقطاعات';

  @override
  String get department => 'القسم';

  @override
  String get description => 'الوصف';

  @override
  String get details => 'التفاصيل';

  @override
  String get deviceInfoLoading => 'ما زالت معلومات الجهاز قيد التحميل. حاول مرة أخرى.';

  @override
  String get directMessage => 'رسالة مباشرة';

  @override
  String get discuss => 'المحادثات';

  @override
  String get duration => 'المدة';

  @override
  String get durationColon => 'المدة :';

  @override
  String get earlyLeave => 'خروج مبكر';

  @override
  String get employeeCode => 'رقم الموظف';

  @override
  String get employeeDataDownloaded => 'تم تنزيل بيانات الموظف';

  @override
  String get employeeDataMissing => 'بيانات الموظف غير موجودة على هذا الجهاز.';

  @override
  String get employeeId => 'معرف الموظف';

  @override
  String get employeeName => 'اسم الموظف';

  @override
  String get endDate => 'تاريخ النهاية';

  @override
  String get endDateSelectError => 'خطأ في اختيار تاريخ النهاية';

  @override
  String get endTime => 'وقت النهاية';

  @override
  String get enterAmount => 'أدخل المبلغ...';

  @override
  String get enterPasswordToAccess => 'أدخل كلمة المرور للدخول';

  @override
  String get enterValidNumber => 'أدخل رقماً صحيحاً';

  @override
  String get escalatedToManager => 'تم التصعيد إلى المدير';

  @override
  String get exitAppConfirm => 'أنت على وشك الخروج من التطبيق!';

  @override
  String get fail => 'فشل';

  @override
  String get failedToCreateGroup => 'فشل إنشاء المجموعة';

  @override
  String get failedToFindEmployee => 'تعذر العثور على الموظف';

  @override
  String get failedToSendImage => 'فشل إرسال الصورة. حاول مرة أخرى.';

  @override
  String get failedToSendPhoto => 'فشل إرسال الصورة. حاول مرة أخرى.';

  @override
  String get failedToStartConversation => 'فشل بدء المحادثة';

  @override
  String get fetchingData => 'جاري تحميل البيانات...';

  @override
  String fieldRequired(String label) {
    return '$label مطلوب';
  }

  @override
  String get fieldWork => 'عمل ميداني';

  @override
  String get gender => 'الجنس';

  @override
  String get gettingCurrentLocation => 'جاري تحديد الموقع الحالي...';

  @override
  String get goodDayMessage => 'نتمنى لك يوماً مليئاً بالإنتاجية والطاقة الإيجابية.';

  @override
  String goodMorning(String name) {
    return 'صباح الخير، $name';
  }

  @override
  String get grossDeduction => 'إجمالي الاستقطاعات';

  @override
  String get grossEarning => 'إجمالي الاستحقاقات';

  @override
  String get grossSalary => 'إجمالي الراتب';

  @override
  String get groupNameHint => 'اسم المجموعة...';

  @override
  String get halfDay => 'نصف يوم';

  @override
  String get history => 'السجل';

  @override
  String get homePhone => 'المنزل';

  @override
  String get hourlyRate => 'أجر الساعة';

  @override
  String get hours => 'الساعات';

  @override
  String get hrAdmin => 'الموارد البشرية والإدارة';

  @override
  String get hrAdminNoAccess => 'ليس لديك صلاحية الوصول إلى قائمة الموارد البشرية والإدارة.';

  @override
  String get imageUnavailable => 'الصورة غير متاحة';

  @override
  String get inOffice => 'في المكتب';

  @override
  String get inOutside => 'حضور: خارج الموقع';

  @override
  String get inbox => 'الوارد';

  @override
  String get invalidPassword => 'كلمة مرور غير صحيحة';

  @override
  String get justificationRequests => 'طلبات التبرير';

  @override
  String get justifications => 'التبريرات';

  @override
  String get justify => 'تبرير';

  @override
  String get language => 'اللغة';

  @override
  String get leaveDataDownloaded => 'تم تنزيل بيانات الإجازات';

  @override
  String get leaveHistory => 'سجل الإجازات';

  @override
  String get leaveHistoryDetail => 'تفاصيل الإجازة';

  @override
  String get leaveHistorySubtitle => 'طلبات الإجازة المقدمة منك';

  @override
  String get leaveReason => 'سبب الإجازة';

  @override
  String get leaveRequest => 'طلب إجازة';

  @override
  String get leaveRequestSubtitle => 'تقديم طلب إجازة جديد';

  @override
  String linesCount(int count) {
    return 'البنود ($count)';
  }

  @override
  String get linkedLoan => 'السلفة المرتبطة';

  @override
  String loanNumber(String id) {
    return 'سلفة رقم $id';
  }

  @override
  String loanWithRemaining(String name, String amount) {
    return '$name  (المتبقي $amount)';
  }

  @override
  String get loans => 'السلف';

  @override
  String get missedCheckIn => 'حضور غير مسجل';

  @override
  String get missedCheckOut => 'انصراف غير مسجل';

  @override
  String get missingCheckout => 'انصراف مفقود';

  @override
  String get morning => 'صباحية';

  @override
  String get myLeaveHistory => 'سجل إجازاتي';

  @override
  String get myLoans => 'سلفي';

  @override
  String get myLoans2 => 'سلفي';

  @override
  String get myRequests => 'طلباتي';

  @override
  String get myRequestsSubtitle => 'تابع حالة طلباتك';

  @override
  String get net => 'الصافي';

  @override
  String get netAmount => 'صافي المبلغ';

  @override
  String get newGroup => 'مجموعة جديدة';

  @override
  String get newLeaveRequest => 'طلب إجازة جديد';

  @override
  String get newMessage => 'رسالة جديدة';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get newPaymentRequest => 'طلب دفع جديد';

  @override
  String get newRequest => 'طلب جديد';

  @override
  String get newRequestSubtitle => 'خطابات، سلف، عهد، مركبات والمزيد';

  @override
  String get no => 'لا';

  @override
  String get noActiveLoans => 'لا توجد سلف نشطة. هذا النوع من الطلبات يتطلب سلفة قائمة.';

  @override
  String get noConversationsYet => 'لا توجد محادثات بعد';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get noDataFound => 'لم يتم العثور على بيانات، حاول لاحقاً.';

  @override
  String get noFileSelected => 'لم يتم اختيار ملف';

  @override
  String get noInternet => 'لا يوجد اتصال بالإنترنت!';

  @override
  String get noLoansOrAdvances => 'لا توجد سلف أو دفعات مقدمة';

  @override
  String get noMessagesYet => 'لا توجد رسائل بعد';

  @override
  String get noRecordsFound => 'لا توجد سجلات';

  @override
  String get noRequestTypes => 'لا توجد أنواع طلبات متاحة';

  @override
  String get noRequestsYet => 'لا توجد طلبات بعد';

  @override
  String get notAllowedLocation => 'غير مسموح لك بتسجيل الحضور/الانصراف من هذا الموقع';

  @override
  String get notInAllowedArea => 'خارج النطاق المسموح';

  @override
  String get notInAllowedAreaMsg => 'أنت خارج النطاق المسموح!';

  @override
  String get note => 'ملاحظة';

  @override
  String get noteOptional => 'ملاحظة (اختياري)';

  @override
  String get nothingWaitingApproval => 'لا توجد طلبات بانتظار اعتمادك';

  @override
  String get ok => 'موافق';

  @override
  String get outOutside => 'انصراف: خارج الموقع';

  @override
  String get outsideLocation => 'خارج الموقع';

  @override
  String get overrideLabel => 'تجاوز';

  @override
  String get overrideAndApprove => 'تجاوز واعتماد';

  @override
  String get paid => 'مدفوع';

  @override
  String paidOf(String paid, String total) {
    return 'مدفوع $paid من $total';
  }

  @override
  String get password => 'كلمة المرور';

  @override
  String get passwordBlank => 'كلمة المرور الجديدة أو التأكيد فارغة. حاول مرة أخرى.';

  @override
  String get passwordChanged => 'تم تغيير كلمة المرور بنجاح.';

  @override
  String get passwordDoesNotMatch => 'كلمة المرور غير متطابقة';

  @override
  String get passwordMismatch => 'كلمة المرور وتأكيدها غير متطابقين';

  @override
  String get paymentDataDownloaded => 'تم تنزيل بيانات طلبات الدفع';

  @override
  String get paymentItem => 'بند الدفع';

  @override
  String get paymentRequest => 'طلب دفع';

  @override
  String get paymentRequestDetail => 'تفاصيل طلب الدفع';

  @override
  String get paymentRequestHistory => 'سجل طلبات الدفع';

  @override
  String get payslip => 'قسيمة الراتب';

  @override
  String get payslipDataDownloaded => 'تم تنزيل بيانات قسائم الرواتب';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get pick => 'اختيار';

  @override
  String get pleaseCheckInOut => 'يرجى تسجيل الحضور/الانصراف';

  @override
  String get pleaseChooseStartDateFirst => 'يرجى اختيار تاريخ البداية أولاً';

  @override
  String get pleaseContact => 'يرجى التواصل';

  @override
  String get pleaseEnterDescription => 'يرجى إدخال الوصف';

  @override
  String get pleaseEnterGroupName => 'يرجى إدخال اسم المجموعة';

  @override
  String get pleaseEnterPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get pleaseEnterReason => 'يرجى إدخال السبب';

  @override
  String get pleaseEnterTotalAmount => 'يرجى إدخال المبلغ الإجمالي';

  @override
  String get pleaseEnterUsername => 'يرجى إدخال اسم المستخدم';

  @override
  String get pleaseSelectCorrectEndDate => 'يرجى اختيار تاريخ نهاية صحيح';

  @override
  String get pleaseSelectDayType => 'يرجى اختيار نوع اليوم';

  @override
  String get pleaseSelectLeaveType => 'يرجى اختيار نوع الإجازة';

  @override
  String get pleaseSelectOneMember => 'يرجى اختيار عضو واحد على الأقل';

  @override
  String get pleaseSelectPaymentItem => 'يرجى اختيار بند الدفع';

  @override
  String get pleaseSelectRelatedLoan => 'يرجى اختيار السلفة المرتبطة';

  @override
  String get pleaseSelectStartDate => 'يرجى اختيار تاريخ البداية';

  @override
  String get pleaseSelectValidDate => 'يرجى اختيار تاريخ صحيح';

  @override
  String get pleaseUploadDocument => 'يرجى رفع المستند';

  @override
  String get position => 'المسمى الوظيفي';

  @override
  String get reason => 'السبب';

  @override
  String get reasonIsRequired => 'السبب مطلوب';

  @override
  String get reasonOptional => 'السبب (اختياري)';

  @override
  String get reasonRequired2 => 'السبب *';

  @override
  String get reference => 'المرجع';

  @override
  String get refreshOrCheckInternet => 'حدّث الصفحة أو تحقق من اتصالك بالإنترنت.';

  @override
  String get refuse => 'رفض';

  @override
  String get refused => 'مرفوض';

  @override
  String get registerYourPresence => 'سجّل حضورك وابدأ';

  @override
  String get registrationNumber => 'الرقم الوظيفي';

  @override
  String get relatedLoanRequired => 'السلفة المرتبطة *';

  @override
  String remainingAmount(String amount) {
    return 'المتبقي $amount';
  }

  @override
  String get remoteWfh => 'عن بعد / من المنزل';

  @override
  String get requestApproved => 'تم اعتماد الطلب';

  @override
  String get requestCancelled => 'تم إلغاء الطلب';

  @override
  String get requestCreated => 'تم إنشاء الطلب بنجاح.';

  @override
  String requestNumber(String id) {
    return 'طلب رقم $id';
  }

  @override
  String get requestOverridden => 'تم تجاوز الطلب';

  @override
  String get requestRefused => 'تم رفض الطلب';

  @override
  String get requestSubmitted => 'تم تقديم الطلب';

  @override
  String requestTypesCount(int count) {
    return '$count نوع طلب';
  }

  @override
  String get requestsAndLeave => 'الطلبات والإجازات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get salarySlip => 'قسيمة الراتب';

  @override
  String get searchEmployee => 'ابحث عن موظف...';

  @override
  String get secondApproval => 'الاعتماد الثاني';

  @override
  String get selectDatabase => 'اختر قاعدة البيانات';

  @override
  String get selectDayType => 'اختر نوع اليوم';

  @override
  String get selectEllipsis => 'اختر...';

  @override
  String get selectLeaveType => 'اختر نوع الإجازة';

  @override
  String get selectPaymentItem => 'اختر بند الدفع';

  @override
  String get selectTax => 'اختر الضريبة';

  @override
  String get selectWorkMode => 'اختر نمط العمل';

  @override
  String get sendImage => 'إرسال صورة';

  @override
  String get sessionExpired => 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signingIn => 'جاري تسجيل الدخول...';

  @override
  String get skip => 'تخطي';

  @override
  String get startDate => 'تاريخ البداية';

  @override
  String get startYourId => 'ابدأ الآن';

  @override
  String get statusNew => 'جديد';

  @override
  String get submit => 'إرسال';

  @override
  String get submitRequest => 'إرسال الطلب';

  @override
  String get submitted => 'مقدم';

  @override
  String get submitting => 'جاري الإرسال...';

  @override
  String get submittingPleaseWait => 'جاري الإرسال. يرجى الانتظار...';

  @override
  String get takeAttachmentPhoto => 'التقط صورة المرفق';

  @override
  String get tapChatToStart => 'اضغط زر المحادثة للبدء';

  @override
  String get tax => 'الضريبة';

  @override
  String get to => 'إلى';

  @override
  String get toApprove => 'بانتظار الاعتماد';

  @override
  String get toConfirm => 'بانتظار التأكيد';

  @override
  String get toReport => 'بانتظار التقرير';

  @override
  String get toSubmit => 'بانتظار التقديم';

  @override
  String get today => 'اليوم';

  @override
  String get todaysSummary => 'ملخص اليوم';

  @override
  String get totalLabel => 'الإجمالي';

  @override
  String totalWithValue(String value) {
    return 'الإجمالي: $value';
  }

  @override
  String get turnOnInternetMessage => 'يرجى التأكد من تشغيل الواي فاي أو بيانات الهاتف.';

  @override
  String get type => 'النوع';

  @override
  String get waiting => 'انتظار';

  @override
  String get welcome => 'مرحباً';

  @override
  String get workEmail => 'البريد الإلكتروني للعمل';

  @override
  String get workFromOutside => 'العمل من الخارج';

  @override
  String get workPhone => 'العمل';

  @override
  String get writeAMessage => 'اكتب رسالة...';

  @override
  String get yesCancel => 'نعم، إلغاء';

  @override
  String get youDontHaveAccess => 'ليس لديك صلاحية وصول';

  @override
  String get yourWork => 'عملك';
}
