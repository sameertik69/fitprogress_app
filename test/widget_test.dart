import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitprogress_app/main.dart';

void main() {
  testWidgets('shows FitProgress start page', (WidgetTester tester) async {
    await tester.pumpWidget(const FitProgressApp());

    expect(find.text('FitProgress AI'), findsOneWidget);
    expect(find.text('قياس تطور الجسم'), findsOneWidget);
    expect(find.text('الصورة الأمامية'), findsOneWidget);
    expect(find.text('الصورة الجانبية'), findsOneWidget);
    expect(find.text('الصورة الخلفية'), findsOneWidget);

    await tester.drag(find.byType(Scrollable), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('اختر الصور الثلاث أولًا'), findsOneWidget);
  });
}
