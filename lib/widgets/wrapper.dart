import 'package:flutter/material.dart';
import 'package:jeas_worker/models/custom_user.dart';
import 'package:jeas_worker/screens/login_worker_screen.dart';
import 'package:jeas_worker/screens/worker_requests_screen.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final worker = Provider.of<CustomUser?>(context);

    if (worker == null) {
      return const LoginWorkerScreen();
    } else {
      return WorkerRequestsScreen();
    }
  }
}
