import 'package:balance/ui/group/edit_transaction.dart';
import 'package:balance/ui/group/group_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'ui/home/home_page.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: "/",
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: "/groups/:id",
      builder: (context, state) => GroupPage(state.pathParameters["id"]!),
    ),
    GoRoute(
      path: "${EditTransactionScreen.route}/:id",
      pageBuilder: (context, state) => MaterialPage(
        child: EditTransactionScreen(
          groupId: state.pathParameters["id"]!,
          currentAmount: (state.extra as Map)["currentAmount"] as int,
          didAddAmount: (state.extra as Map)["didAddAmount"] as bool,
          balance: (state.extra as Map)["balance"] as int,
          id: (state.extra as Map)["id"] as String,
        ),
      ),
    ),
  ],
);
