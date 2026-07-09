import 'dart:convert';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:talent_hr/utility/utils/extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/api/expense_api.dart';
// import '../../../data/database/Dao/expense/expense_dao.dart';
import '../../../data/database/dao/expense/analytic_account_dao.dart';
import '../../../data/database/dao/expense/expense_product_dao.dart';
import '../../../data/database/dao/expense/expense_tax_dao.dart';
import '../../../data/models/expense/analytic_account/analytic_account.dart';
import '../../../data/models/expense/expense/expense.dart';
import '../../../data/models/expense/expense_product/expense_product.dart';
import '../../../data/models/expense/expense_tax/expense_tax.dart';
import '../../../utility/style/theme.dart';
import '../../../utility/utils/date_util.dart';
import '../../widgets/custom_event_dialog.dart';
import '../../widgets/widgets.dart';
import '../base.account/login.dart';
import 'expense_request_history_list_page.dart';
import 'package:talent_hr/app/locale_controller.dart';

class ExpenseEntryPage extends StatefulWidget {
  const ExpenseEntryPage({super.key});

  @override
  State<ExpenseEntryPage> createState() => _ExpenseEntryPageState();
}

class _ExpenseEntryPageState extends State<ExpenseEntryPage> {
  var referenceNo = '';
  late BuildContext _scaffoldCtx;
  var billRefController = TextEditingController();
  var totalAmountController = TextEditingController();
  var descController = TextEditingController();
  var noteController = TextEditingController();
  var pref;
  var employeeName;
  List<ExpenseProduct> expenseProductList = [];
  List<ExpenseTax> expenseTaxList = [];
  var expensePeoductDao = ExpenseProductDao();
  var expenseTaxDao = ExpenseTaxDao();
  var photos = <File>[];
  var images = <Uint8List>[];
  List<String> base64ImageList = [];
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String base64Image = '';
  var mode;
  bool updateDenied = false;
  // var expenseDao = ExpenseDao();
  FToast? toast;
  var paidBy;
  List<Map<String, dynamic>> pendingLines = [];
  var insertResult;
  bool makeChanges = false;
  var expenseApi = ExpenseAPI();
  NumberFormat numberFormat = NumberFormat("#,###", "en_US");
  double total = 0;
  var expenseProductDao = ExpenseProductDao();
  var expenseTypeId;
  var analyticAccountId;
  var expenseTaxId;
  ExpenseProduct? selectedExpense;
  AnalyticAccount? selectedAnalyticAccount;
  ExpenseTax? selectedExpenseTax;
  var saveDate = '';
  String? selectedFormatDate;
  DateTime? dateTime;
  String selectedDate = 'Tuesday, Nov 2 2021';
  String path = "";
  var analyticAccountDao = AnalyticAccountDao();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    toast = FToast();
    toast!.init(context);
    loadData();
  }

  loadData() async {
    pref = await SharedPreferences.getInstance();
    selectedFormatDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
    employeeName = await pref!.getString('user_name');
    expenseProductList = [];

    expenseTaxList = [];
    expenseProductList = await expensePeoductDao.getExpenseProductList();

    expenseTaxList = await expenseTaxDao.getExpenseTaxList();
    dateTime = DateTime.now();

    selectedDate = DateUtil().getDateFormat(dateTime!);

    paidBy = 'own_account';

    setState(() {});
  }

  List<DropdownMenuItem<int>> _addDividersAfterItems(
      List<ExpenseProduct> items) {
    List<DropdownMenuItem<int>> menuItems = [];
    for (var item in items) {
      menuItems.addAll(
        [
          DropdownMenuItem<int>(
            value: item.expenseProductId!,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: Text(
                item.name!,
                style: normalMediumBalckText,
              ),
            ),
          ),
          if (item != items.last)
            DropdownMenuItem<int>(
              enabled: false,
              child: Container(
                height: 1,
                color: Colors.black12,
              ),
            ),
        ],
      );
    }

    return menuItems;
  }

  List<DropdownMenuItem<int>> _addDividersAfterItemsForAnalyticAccount(
      List<ExpenseTax> items) {
    List<DropdownMenuItem<int>> menuItems = [];
    for (var item in items) {
      menuItems.addAll(
        [
          DropdownMenuItem<int>(
            value: item.expenseTaxId!,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: Text(
                item.name!,
                style: normalMediumBalckText,
              ),
            ),
          ),
          if (item != items.last)
            DropdownMenuItem<int>(
              enabled: false,
              child: Container(
                height: 1,
                color: Colors.black12,
              ),
            ),
        ],
      );
    }

    return menuItems;
  }


  void _openFileExplorer() async {
    var status = await Permission.storage.request();

    if (!status.isGranted) {
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'doc'],
        allowMultiple: true);
    if (result != null) {
      setState(() {
        /*For(int i=0;i<result.length;i++) {

        }*/
        File file = File((result.files.single.path).toString());
        path = file.path;
        final bytes = File(file.path).readAsBytesSync();

        base64Image = base64Encode(bytes);
      });
    } else {
      path = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _scaffoldCtx = context;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return const ExpenseListPage();
        }));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.l10n.newPaymentRequest,
            style: appBarTitleStyle,
          ),
          backgroundColor: ColorObj.mainColor,
          leading: InkWell(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return const ExpenseListPage();
                }));
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: Icon(
                  Icons.arrow_back,
                  size: 28,
                  color: Colors.white,
                ),
              )),
        ),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: SingleChildScrollView(
                child: Container(
                    color: Colors.white,
                    child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Container(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    selectedDate,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontFamily: 'Regular',
                                        color: Color(0xff006ea5),
                                        fontSize: 16),
                                  )
                                ],
                              ),
                            

                              const SizedBox(
                                height: 8,
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 2.0.wp(context),
                                    vertical: 2.0.hp(context)),
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          offset: Offset(4, 4),
                                          blurRadius: 3,
                                          spreadRadius: 1,
                                          color: Colors.black12),
                                      BoxShadow(
                                          offset: Offset(-2, -2),
                                          blurRadius: 2,
                                          spreadRadius: 1,
                                          color: Colors.black12)
                                    ]),
                                child: Padding(
                                  padding: EdgeInsets.all(5.0.wp(context)),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Container(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      context.l10n.description,
                                                      style:
                                                          normalTextWithGrey700,
                                                    ),
                                                    const SizedBox(
                                                      height: 8,
                                                    ),
                                                    Container(
                                                      height: 40,
                                                      width: double.infinity,
                                                      //  margin: EdgeInsets.only(right: 20),
                                                      padding: const EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                          bottom: 8),
                                                      decoration: BoxDecoration(
                                                        // color: Color(0xffF5F5F5),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                            color: ColorObj
                                                                .dropDownBorderColor),
                                                      ),
                                                      child: TextFormField(
                                                          controller:
                                                              descController,
                                                          textAlign:
                                                              TextAlign.left,
                                                          cursorColor:
                                                              Colors.grey,
                                                          style:
                                                              normalTextWithBlack,
                                                          decoration:
                                                              InputDecoration(
                                                            // hintText:
                                                            //     'Enter............',
                                                            hintStyle:
                                                                smallTextWithGrey700,
                                                            border: InputBorder
                                                                .none,
                                                          ),
                                                          onChanged:
                                                              ((value) async {
                                                            setState(() {});
                                                          })),
                                                    )
                                                  ],
                                                ),
                                              )),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Divider(),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              child: Text(
                                                context.l10n.paymentItem,
                                                style: normalMediumGreyText,
                                              ),
                                            ),
                                            Container(
                                                height: 40,
                                                margin: const EdgeInsets.only(
                                                  top: 8,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(6)),
                                                    border: Border.all(
                                                        color: ColorObj
                                                            .dropDownBorderColor)),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child: DropdownButton2(
                                                    dropdownFullScreen: true,
                                                    dropdownDecoration:
                                                        const BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5))),
                                                    isExpanded: true,
                                                    hint: Text(
                                                      context.l10n.selectPaymentItem,
                                                      style:
                                                          normalMediumGreyText,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    items:
                                                        _addDividersAfterItems(
                                                            expenseProductList),
                                                    itemHeight: 20,
                                                    value: expenseTypeId,
                                                    onChanged: (value) async {
                                                      expenseTypeId =
                                                          value as int;

                                                      for (var element in expenseProductList) {
                                                        if (expenseTypeId ==
                                                            element
                                                                .expenseProductId) {
                                                          selectedExpense =
                                                              element;
                                                        }
                                                      }

                                                      setState(() {});
                                                    },
                                                  ),
                                                ))
                                          ]),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Divider(),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              child: Text(
                                                context.l10n.tax,
                                                style: normalMediumGreyText,
                                              ),
                                            ),
                                            Container(
                                                height: 40,
                                                margin: const EdgeInsets.only(
                                                  top: 8,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(6)),
                                                    border: Border.all(
                                                        color: ColorObj
                                                            .dropDownBorderColor)),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child: DropdownButton2(
                                                    dropdownFullScreen: true,
                                                    dropdownDecoration:
                                                        const BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5))),
                                                    isExpanded: true,
                                                    hint: Text(
                                                      context.l10n.selectTax,
                                                      style:
                                                          normalMediumGreyText,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    items:
                                                        _addDividersAfterItemsForAnalyticAccount(
                                                            expenseTaxList),
                                                    itemHeight: 20,
                                                    value: expenseTaxId,
                                                    onChanged: (value) async {
                                                      expenseTaxId =
                                                          value as int;

                                                      for (var element in expenseTaxList) {
                                                        if (expenseTaxId ==
                                                            element
                                                                .expenseTaxId) {
                                                          selectedExpenseTax =
                                                              element;
                                                        }
                                                      }

                                                      setState(() {});
                                                    },
                                                  ),
                                                ))
                                          ]),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Divider(),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Container(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      context.l10n.billReference,
                                                      style:
                                                          normalMediumGreyText,
                                                    ),
                                                    const SizedBox(
                                                      height: 8,
                                                    ),
                                                    Container(
                                                      height: 40,
                                                      width: double.infinity,
                                                      // margin: EdgeInsets.only(
                                                      //     right: 12),
                                                      padding: const EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                          bottom: 8),
                                                      decoration: BoxDecoration(
                                                        //  color: Color(0xffF5F5F5),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                            color: ColorObj
                                                                .dropDownBorderColor),
                                                      ),
                                                      child: TextFormField(
                                                        controller:
                                                            billRefController,
                                                        textAlign:
                                                            TextAlign.left,
                                                        cursorColor:
                                                            Colors.grey,
                                                        style:
                                                            normalTextWithBlack,
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          // hintText:
                                                          //     'Enter............',
                                                          hintStyle:
                                                              smallTextWithGrey700,
                                                        ),
                                                        onChanged:
                                                            ((value) async {
                                                          setState(() {});
                                                        }),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Divider(),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Container(
                                                // margin: EdgeInsets.only(
                                                //   left: 12,
                                                // ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      context.l10n.totalLabel,
                                                      style:
                                                          normalMediumGreyText,
                                                    ),
                                                    const SizedBox(
                                                      height: 8,
                                                    ),
                                                    Container(
                                                      height: 40,
                                                      width: double.infinity,
                                                      // margin: EdgeInsets.only(left: 20),
                                                      padding: const EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                          bottom: 8),
                                                      decoration: BoxDecoration(
                                                        //  color: Color(0xffF5F5F5),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                            color: ColorObj
                                                                .dropDownBorderColor),
                                                      ),
                                                      child: TextFormField(
                                                        controller:
                                                            totalAmountController,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        textAlign:
                                                            TextAlign.left,
                                                        cursorColor:
                                                            Colors.grey,
                                                        style:
                                                            normalTextWithBlack,
                                                        decoration:
                                                            InputDecoration(
                                                          // hintText:
                                                          //     context.l10n.enterAmount,
                                                          hintStyle:
                                                              smallTextWithGrey700,
                                                          border:
                                                              InputBorder.none,
                                                        ),
                                                        onFieldSubmitted:
                                                            (value) async {
                                                          total = double.parse(
                                                              value.toString());
                                                          totalAmountController
                                                                  .text =
                                                              numberFormat
                                                                  .format(
                                                                      total);
                                                        },
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Divider(),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Container(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      context.l10n.note,
                                                      style:
                                                          normalMediumGreyText,
                                                    ),
                                                    const SizedBox(
                                                      height: 8,
                                                    ),
                                                    Container(
                                                      // height: 40,
                                                      width: double.infinity,
                                                      //  margin: EdgeInsets.only(right: 20),
                                                      padding: const EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                          bottom: 8),
                                                      decoration: BoxDecoration(
                                                        // color: Color(0xffF5F5F5),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                            color: ColorObj
                                                                .dropDownBorderColor),
                                                      ),
                                                      child: TextFormField(
                                                          controller:
                                                              noteController,
                                                          textAlign:
                                                              TextAlign.left,
                                                          cursorColor:
                                                              Colors.grey,
                                                          style:
                                                              normalTextWithBlack,
                                                          decoration:
                                                              InputDecoration(
                                                            // hintText:
                                                            //     '............',
                                                            hintStyle:
                                                                smallTextWithGrey700,
                                                            border: InputBorder
                                                                .none,
                                                          ),
                                                          maxLines: 5,
                                                          onChanged:
                                                              ((value) async {
                                                            setState(() {});
                                                          })),
                                                    )
                                                  ],
                                                ),
                                              )),
                                        ],
                                      ),

                                      
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      _buildLinesSection(),
                                      const SizedBox(
                                        height: 30,
                                      ),
                                      SizedBox(
                                          height: 45,
                                          width: double.infinity,
                                          child: ElevatedButton(
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          ColorObj.mainColor),
                                                  shape: MaterialStateProperty.all(
                                                      const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5))))),
                                              onPressed: _submitRequest,
                                              child: Text(
                                                context.l10n.submitRequest,
                                                style: normalLargeWhiteText,
                                              ))),
                                    
                                      // GestureDetector(
                                      //   onTap: () {
                                      //     _openFileExplorer();
                                      //   },
                                      //   child: Container(
                                      //     padding:
                                      //         EdgeInsets.only(left: 5, top: 10),
                                      //     child: Row(
                                      //       children: [
                                      //         Icon(
                                      //           MdiIcons.attachment,
                                      //           color: ColorObj.secondColor,
                                      //         ),
                                      //         SizedBox(
                                      //           width: 10,
                                      //         ),
                                      //         Text(
                                      //           context.l10n.attachmentOptional,
                                      //           style: normalMediumGreyText,
                                      //         ),
                                      //       ],
                                      //     ),
                                      //   ),
                                      // ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.symmetric(vertical: 10),
                                        child: Text(path),
                                      ),
                                    
                                    ],
                                  ),
                                ),
                              ),
                            ])))))),
      ),
    );
  }

  bool _hasCurrentInput() =>
      descController.text.trim().isNotEmpty ||
      totalAmountController.text.trim().isNotEmpty;

  bool _validateCurrentLine() {
    if (descController.text == '') {
      toast!.showToast(
        child: Widgets().getWarningToast(context.l10n.pleaseEnterDescription),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 2),
      );
      return false;
    }
    if (selectedExpense == null) {
      toast!.showToast(
        child: Widgets().getWarningToast(context.l10n.pleaseSelectPaymentItem),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 2),
      );
      return false;
    }
    if (totalAmountController.text == '') {
      toast!.showToast(
        child: Widgets().getWarningToast(context.l10n.pleaseEnterTotalAmount),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 2),
      );
      return false;
    }
    return true;
  }

  void _captureCurrentLine() {
    var amount =
        double.parse(totalAmountController.text.toString().replaceAll(',', ''));
    pendingLines.add({
      'name': descController.text.toString(),
      'date': selectedFormatDate,
      'bill_ref': billRefController.text.toString(),
      'product_id': selectedExpense!.expenseProductId,
      'product_name': selectedExpense!.name,
      'amount': amount,
      'tax_id':
          selectedExpenseTax != null ? selectedExpenseTax!.expenseTaxId : 0,
      'note': noteController.text.toString(),
      'attachment': base64Image,
    });
    descController.clear();
    totalAmountController.clear();
    billRefController.clear();
    noteController.clear();
    selectedExpense = null;
    selectedExpenseTax = null;
    expenseTypeId = null;
    expenseTaxId = null;
    base64Image = '';
    base64ImageList = [];
    photos = [];
    total = 0;
    setState(() {});
  }

  void _addLine() {
    if (_validateCurrentLine()) {
      _captureCurrentLine();
    }
  }

  Widget _buildLinesSection() {
    double linesTotal = 0;
    for (var l in pendingLines) {
      linesTotal += l['amount'] as double;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pendingLines.isNotEmpty) ...[
          Text(context.l10n.linesCount(pendingLines.length),
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          for (var i = 0; i < pendingLines.length; i++)
            Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                dense: true,
                title: Text('${pendingLines[i]['name']}'),
                subtitle: Text(
                    '${pendingLines[i]['product_name'] ?? ''}  ·  ${pendingLines[i]['date'] ?? ''}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        numberFormat
                            .format(pendingLines[i]['amount'] as double),
                        style:
                            const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        setState(() => pendingLines.removeAt(i));
                      },
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(context.l10n.totalWithValue(numberFormat.format(linesTotal)),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addLine,
            icon: const Icon(Icons.add, color: ColorObj.mainColor),
            label: Text(context.l10n.addAnotherLine,
                style: TextStyle(color: ColorObj.mainColor)),
          ),
        ),
      ],
    );
  }

  _submitRequest() async {
    bool checkInternet = await InternetConnectionChecker().hasConnection;
    if (!mounted) return;
    if (checkInternet == false) {
      showDialog(context: context, builder: (_) => const CustomEventDialog());
      return;
    }

    // Capture whatever is currently typed as the last line.
    if (_hasCurrentInput() || pendingLines.isEmpty) {
      if (!_validateCurrentLine()) return;
      _captureCurrentLine();
    }

    EasyLoading.show(status: context.l10n.submittingPleaseWait);

    var failed = 0;
    var failMessage = '';
    for (var line in List<Map<String, dynamic>>.from(pendingLines)) {
      Expense expense = Expense(
          0,
          line['name'],
          line['date'],
          line['bill_ref'],
          line['product_id'],
          line['product_name'],
          line['amount'],
          1,
          line['amount'],
          'own_account',
          line['note'],
          'draft',
          0,
          line['tax_id'],
          line['attachment']);

      var createResult = await expenseApi.createExpense(expense);

      if (createResult['result'] == 'fail') {
        var resultMessage = createResult['message'] == ''
            ? context.l10n.fail
            : createResult['message'];
        if (resultMessage == 'Invalid cookie.') {
          EasyLoading.dismiss();
          toast!.showToast(
            child: Widgets()
                .getErrorToast(context.l10n.sessionExpired),
            gravity: ToastGravity.BOTTOM,
            toastDuration: const Duration(seconds: 3),
          );
          await pref.setString('jwt_token', "null");
          await Future.delayed(const Duration(seconds: 4));
          if (!mounted) return;
          Navigator.of(_scaffoldCtx).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) {
            return const LoginScreen();
          }), (route) => false);
          return;
        }
        failed++;
        failMessage = '$resultMessage';
      } else {
        pendingLines.remove(line);
      }
    }

    EasyLoading.dismiss();

    if (failed > 0) {
      toast!.showToast(
        child: Widgets()
            .getErrorToast('$failed line(s) failed: $failMessage'),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
      setState(() {});
      return;
    }

    toast!.showToast(
      child: Widgets().getSuccessToast(context.l10n.requestCreated),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );

    if (!mounted) return;
    await Navigator.pushReplacementNamed(context, '/expense');
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget bottomSheet() {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.12,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Text(
              context.l10n.takeAttachmentPhoto,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.camera,
                    color: ColorObj.mainColor,
                  ),
                  onPressed: () {
                    takephoto(ImageSource.camera);
                    Navigator.pop(context);
                  },
                  label: Text(
                    context.l10n.camera,
                    style: smallTextWithPurple,
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: ColorObj.mainColor,
                        width: 1,
                      )),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  takephoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      imageQuality: 85,
      source: source,
    );
    setState(() {
      _imageFile = File(pickedFile!.path);
    });

    setState(() {
      photos.add(_imageFile!);
    });

    final bytes = File(pickedFile!.path).readAsBytesSync();

    base64Image = base64Encode(bytes);
    base64ImageList.add(base64Image);
  }
}
