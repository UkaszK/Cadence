import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cadence/data/isar_data_store.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarDataStore.init();
  runApp(ProviderScope(child: const App()));
}
