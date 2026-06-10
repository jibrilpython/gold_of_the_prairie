import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gold_of_the_prairie/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Gold of the Prairie shows onboarding', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({'gop_user_v1': true});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(child: MyApp(preferences: preferences)),
    );

    expect(find.textContaining('GOLD OF'), findsOneWidget);
    expect(find.text('GOP - GRAIN LEDGER'), findsOneWidget);
  });
}
