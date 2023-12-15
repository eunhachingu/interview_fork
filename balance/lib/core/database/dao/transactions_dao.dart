import 'package:balance/core/database/dao/groups_dao.dart';
import 'package:balance/core/database/database.dart';
import 'package:balance/main.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

part 'transactions_dao.g.dart';

@lazySingleton
@DriftAccessor(tables: [Transaction])
class TransactionsDao extends DatabaseAccessor<Database> with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  Future<int> updateHistory({
    required int amount,
    required String groupId,
    required bool didAddAmount,
  }) async {
    final companion = TransactionsCompanion(
      amount: Value(amount),
      createdAt: Value(DateTime.now()),
      groupId: Value(groupId),
      id: Value(const Uuid().v1()),
      didAddAmount: Value(didAddAmount),
    );
    return await into(transactions).insert(companion);
  }

  Stream<List<Transaction>> watchGroup(String groupId) {
    return (select(transactions)..where((tbl) => tbl.groupId.equals(groupId))).watch();
  }

  Future<int> updateTransaction({
    required String id,
    required int amount,
  }) async {
    final companion = TransactionsCompanion(
      id: Value(id),
      amount: Value(amount),
    );
    return (update(transactions)..where((tbl) => tbl.id.equals(id))).write(companion);
  }

  void updateBalance({
    required bool didAddAmount,
    required int currentAmount,
    required int balance,
    required int updatedAmount,
    required String id,
  }) async {
    late final GroupsDao groupsDao = getIt.get<GroupsDao>();

    await groupsDao.adjustBalance(
      didAddAmount ? (balance - currentAmount) + updatedAmount : (balance - currentAmount) - updatedAmount,
      id,
    );
  }
}
