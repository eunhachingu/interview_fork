import 'package:balance/core/database/dao/transactions_dao.dart';
import 'package:balance/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class EditTransactionScreen extends StatelessWidget {
  static String route = "/editTransaction";
  const EditTransactionScreen({
    required this.groupId,
    required this.currentAmount,
    required this.didAddAmount,
    required this.balance,
    required this.id,
    super.key,
  });

  final String groupId;
  final int currentAmount;
  final bool didAddAmount;
  final int balance;
  final String id;

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    late final TransactionsDao transactionsDao = getIt.get<TransactionsDao>();

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[0-9]"))],
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 10),
              suffixText: "\$",
            ),
          ),
          TextButton(
            onPressed: () {
              transactionsDao
                  .updateTransaction(
                amount: int.parse(controller.text),
                id: id,
              )
                  .then((value) {
                transactionsDao.updateBalance(
                  balance: balance,
                  didAddAmount: didAddAmount,
                  currentAmount: currentAmount,
                  id: groupId,
                  updatedAmount: int.parse(controller.text),
                );
              });

              context.pop();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
