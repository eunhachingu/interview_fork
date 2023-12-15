import 'package:balance/core/database/dao/groups_dao.dart';
import 'package:balance/core/database/dao/transactions_dao.dart';
import 'package:balance/core/database/database.dart';
import 'package:balance/main.dart';
import 'package:balance/ui/group/edit_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class GroupPage extends StatefulWidget {
  final String groupId;
  const GroupPage(this.groupId, {super.key});

  @override
  State<StatefulWidget> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  late final GroupsDao _groupsDao = getIt.get<GroupsDao>();
  late final TransactionsDao _transactionsDao = getIt.get<TransactionsDao>();

  final _incomeController = TextEditingController();
  final _expenseController = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Group details"),
        ),
        body: Scaffold(
          key: scaffoldKey,
          body: Column(
            children: [
              StreamBuilder<Group?>(
                stream: _groupsDao.watchGroup(widget.groupId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text("Loading...");
                  } else {
                    final groupData = snapshot.data!;
                    String balance = snapshot.data?.balance.toString() ?? "";

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(snapshot.data?.name ?? ""),
                        Text(balance),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _incomeController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[0-9]"))],
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                                  suffixText: "\$",
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                final amount = int.parse(_incomeController.text);
                                final balance = snapshot.data?.balance ?? 0;
                                _groupsDao.adjustBalance(balance + amount, widget.groupId);
                                _incomeController.text = "";

                                _transactionsDao.updateHistory(
                                  amount: amount,
                                  groupId: groupData.id,
                                  didAddAmount: true,
                                );
                              },
                              child: const Text("Add income"),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _expenseController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[0-9]"))],
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                                  suffixText: "\$",
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                final amount = int.parse(_expenseController.text);
                                final balance = snapshot.data?.balance ?? 0;
                                _groupsDao.adjustBalance(balance - amount, widget.groupId);
                                _expenseController.text = "";

                                _transactionsDao.updateHistory(
                                  amount: amount,
                                  groupId: groupData.id,
                                  didAddAmount: false,
                                );
                              },
                              child: const Text("Add expense"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        const Center(child: Text("History")),
                        StreamBuilder<List<Transaction>>(
                          stream: _transactionsDao.watchGroup(widget.groupId),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Text("Loading...");
                            } else {
                              final transactionList = snapshot.data!;
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: transactionList.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                                    decoration: BoxDecoration(
                                      border: const Border(
                                        bottom: BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      color: transactionList[index].didAddAmount ? Colors.green : Colors.red,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(transactionList[index].amount.toString()),
                                        IconButton(
                                          onPressed: () {
                                            context.push(
                                              "${EditTransactionScreen.route}/${widget.groupId}",
                                              extra: {
                                                "didAddAmount": transactionList[index].didAddAmount,
                                                "currentAmount": transactionList[index].amount,
                                                "balance": groupData.balance,
                                                "id": transactionList[index].id,
                                              },
                                              
                                              
                                              
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.edit,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
}
