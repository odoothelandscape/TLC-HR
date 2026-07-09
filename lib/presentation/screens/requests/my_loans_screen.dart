import 'package:flutter/material.dart';

import '../../../data/api/requests_api.dart';
import '../../../data/models/request/employee_request_models.dart';
import '../../../utility/style/theme.dart';
import '../../../app/locale_controller.dart';

/// The employee's loans and advances with installment progress.
class MyLoansScreen extends StatefulWidget {
  const MyLoansScreen({Key? key}) : super(key: key);

  @override
  State<MyLoansScreen> createState() => _MyLoansScreenState();
}

class _MyLoansScreenState extends State<MyLoansScreen> {
  final _api = RequestsAPI();
  List<MyLoan>? _loans;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loans = null;
      _error = null;
    });
    try {
      final loans = await _api.getMyLoans();
      if (mounted) setState(() => _loans = loans);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.myLoans2),
        backgroundColor: ColorObj.mainColor,
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: ColorObj.mainColor),
                      onPressed: _load,
                      child: Text(context.l10n.retry)),
                ],
              ),
            )
          : _loans == null
              ? const Center(child: CircularProgressIndicator())
              : _loans!.isEmpty
                  ? Center(child: Text(context.l10n.noLoansOrAdvances))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _loans!.length,
                        itemBuilder: (context, i) => _LoanCard(loan: _loans![i]),
                      ),
                    ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  final MyLoan loan;
  const _LoanCard({required this.loan});

  @override
  Widget build(BuildContext context) {
    final progress =
        loan.amount > 0 ? (loan.paidAmount / loan.amount).clamp(0.0, 1.0) : 0.0;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        title: Text(loan.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                color: ColorObj.successColor,
                minHeight: 6,
              ),
              const SizedBox(height: 6),
              Text(
                loan.remainingAmount > 0
                    ? '${context.l10n.paidOf(loan.paidAmount.toStringAsFixed(0), loan.amount.toStringAsFixed(0))}  ·  ${context.l10n.remainingAmount(loan.remainingAmount.toStringAsFixed(0))}'
                    : context.l10n.paidOf(loan.paidAmount.toStringAsFixed(0),
                        loan.amount.toStringAsFixed(0)),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        trailing: loan.state.isEmpty
            ? null
            : Text(loan.state,
                style: const TextStyle(
                    fontSize: 12, color: ColorObj.secondaryColor)),
        children: loan.installments
            .map((inst) => ListTile(
                  dense: true,
                  leading: Icon(
                    inst.paid
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: inst.paid ? ColorObj.successColor : Colors.grey,
                    size: 20,
                  ),
                  title: Text(inst.date),
                  trailing: Text(inst.amount.toStringAsFixed(2),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ))
            .toList(),
      ),
    );
  }
}
