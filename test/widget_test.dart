import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitprogress_app/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

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

  testWidgets('loads saved sessions from local storage', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'fitprogress_sessions': jsonEncode([
        {
          'createdAt': DateTime(2026, 6, 21, 12).toIso8601String(),
          'visualScore': 78,
          'confidence': 'متوسط',
          'postureScore': 83,
          'summary': 'جلسة محفوظة للاختبار',
          'symmetryLabel': 'جيد',
          'comparabilityLabel': 'مقبولة',
          'shoulderWaistChange': 5.2,
          'recommendation': 'حافظ على نفس ظروف التصوير',
          'weightKg': 82.5,
          'phaseLabel': 'تنشيف',
          'note': 'التزام عالي هذا الأسبوع',
        },
      ]),
    });

    await tester.pumpWidget(const FitProgressApp());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('جاهزية البيانات'),
      500,
      scrollable: find.byType(Scrollable),
    );

    expect(find.text('جاهزية البيانات'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('خطة الجلسة القادمة'),
      500,
      scrollable: find.byType(Scrollable),
    );

    expect(find.text('خطة الجلسة القادمة'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('سجل الجلسات'),
      500,
      scrollable: find.byType(Scrollable),
    );

    expect(find.text('سجل الجلسات'), findsOneWidget);
    expect(find.text('اتجاه التطور'), findsOneWidget);
    expect(find.text('الكل'), findsOneWidget);
    expect(find.text('قياسات'), findsOneWidget);
    expect(find.text('جلسة 2026/6/21 - 12:00'), findsOneWidget);
    expect(find.text('تنشيف'), findsOneWidget);
  });

  testWidgets('clears saved sessions from history', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'fitprogress_sessions': jsonEncode([
        {
          'createdAt': DateTime(2026, 6, 21, 12).toIso8601String(),
          'visualScore': 78,
          'confidence': 'متوسط',
          'postureScore': 83,
          'summary': 'جلسة محفوظة للاختبار',
          'symmetryLabel': 'جيد',
          'comparabilityLabel': 'مقبولة',
          'shoulderWaistChange': 5.2,
          'recommendation': 'حافظ على نفس ظروف التصوير',
        },
      ]),
    });

    await tester.pumpWidget(const FitProgressApp());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('مسح السجل'),
      500,
      scrollable: find.byType(Scrollable),
    );

    await tester.tap(find.text('مسح السجل'));
    await tester.pumpAndSettle();

    expect(find.text('سجل الجلسات'), findsNothing);
    expect(find.text('78%'), findsNothing);
  });

  testWidgets('opens session details with notes and weight', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'fitprogress_sessions': jsonEncode([
        {
          'createdAt': DateTime(2026, 6, 21, 12).toIso8601String(),
          'visualScore': 78,
          'confidence': 'متوسط',
          'postureScore': 83,
          'summary': 'جلسة محفوظة للاختبار',
          'symmetryLabel': 'جيد',
          'comparabilityLabel': 'مقبولة',
          'shoulderWaistChange': 5.2,
          'recommendation': 'حافظ على نفس ظروف التصوير',
          'weightKg': 82.5,
          'phaseLabel': 'تنشيف',
          'note': 'التزام عالي هذا الأسبوع',
          'measurements': {
            'waistCm': 82,
            'chestCm': 104,
            'armCm': 36,
            'shoulderCm': 118,
          },
        },
      ]),
    });

    await tester.pumpWidget(const FitProgressApp());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('جلسة 2026/6/21 - 12:00'),
      500,
      scrollable: find.byType(Scrollable),
    );

    await tester.tap(find.text('جلسة 2026/6/21 - 12:00'));
    await tester.pumpAndSettle();

    expect(find.text('تفاصيل الجلسة'), findsOneWidget);
    expect(find.text('82.5 kg'), findsOneWidget);
    expect(find.text('التزام عالي هذا الأسبوع'), findsOneWidget);
    expect(find.text('القياسات اليدوية'), findsOneWidget);
    expect(find.text('الخصر 82.0 cm'), findsOneWidget);
    expect(find.text('تطور العضلات'), findsOneWidget);
    expect(find.text('الأكتاف'), findsOneWidget);
    expect(find.text('تصدير التقرير'), findsOneWidget);
  });

  testWidgets('filters history by measurements', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'fitprogress_sessions': jsonEncode([
        {
          'createdAt': DateTime(2026, 6, 21, 13).toIso8601String(),
          'visualScore': 81,
          'confidence': 'مرتفع',
          'postureScore': 88,
          'summary': 'جلسة بقياسات',
          'symmetryLabel': 'ممتاز',
          'comparabilityLabel': 'قوية',
          'shoulderWaistChange': 6.1,
          'recommendation': 'استمر',
          'measurements': {'waistCm': 82},
        },
        {
          'createdAt': DateTime(2026, 6, 21, 12).toIso8601String(),
          'visualScore': 78,
          'confidence': 'متوسط',
          'postureScore': 83,
          'summary': 'جلسة بدون قياسات',
          'symmetryLabel': 'جيد',
          'comparabilityLabel': 'مقبولة',
          'shoulderWaistChange': 5.2,
          'recommendation': 'حافظ على نفس ظروف التصوير',
        },
      ]),
    });

    await tester.pumpWidget(const FitProgressApp());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('قياسات'),
      500,
      scrollable: find.byType(Scrollable),
    );

    await tester.tap(find.text('قياسات'));
    await tester.pumpAndSettle();

    expect(find.text('جلسة 2026/6/21 - 13:00'), findsOneWidget);
    expect(find.text('جلسة 2026/6/21 - 12:00'), findsNothing);
  });

  testWidgets('deletes one session and keeps the other', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'fitprogress_sessions': jsonEncode([
        {
          'createdAt': DateTime(2026, 6, 21, 13).toIso8601String(),
          'visualScore': 81,
          'confidence': 'مرتفع',
          'postureScore': 88,
          'summary': 'جلسة أحدث',
          'symmetryLabel': 'ممتاز',
          'comparabilityLabel': 'قوية',
          'shoulderWaistChange': 6.1,
          'recommendation': 'استمر',
          'muscleMetrics': [
            {
              'name': 'الأكتاف',
              'score': 82,
              'status': 'جيد',
              'note': 'تحسن واضح',
            },
          ],
        },
        {
          'createdAt': DateTime(2026, 6, 21, 12).toIso8601String(),
          'visualScore': 78,
          'confidence': 'متوسط',
          'postureScore': 83,
          'summary': 'جلسة أقدم',
          'symmetryLabel': 'جيد',
          'comparabilityLabel': 'مقبولة',
          'shoulderWaistChange': 5.2,
          'recommendation': 'حافظ على نفس ظروف التصوير',
          'muscleMetrics': [
            {
              'name': 'الأكتاف',
              'score': 76,
              'status': 'جيد',
              'note': 'قراءة سابقة',
            },
          ],
        },
      ]),
    });

    await tester.pumpWidget(const FitProgressApp());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('جلسة 2026/6/21 - 13:00'),
      500,
      scrollable: find.byType(Scrollable),
    );

    await tester.ensureVisible(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();

    expect(find.text('81%'), findsNothing);
    expect(find.text('جلسة 2026/6/21 - 12:00'), findsOneWidget);
  });

  testWidgets('shows muscle differences in session comparison', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'fitprogress_sessions': jsonEncode([
        {
          'createdAt': DateTime(2026, 6, 21, 13).toIso8601String(),
          'visualScore': 81,
          'confidence': 'مرتفع',
          'postureScore': 88,
          'summary': 'جلسة أحدث',
          'symmetryLabel': 'ممتاز',
          'comparabilityLabel': 'قوية',
          'shoulderWaistChange': 6.1,
          'recommendation': 'استمر',
          'muscleMetrics': [
            {
              'name': 'الأكتاف',
              'score': 82,
              'status': 'جيد',
              'note': 'تحسن واضح',
            },
          ],
        },
        {
          'createdAt': DateTime(2026, 6, 21, 12).toIso8601String(),
          'visualScore': 78,
          'confidence': 'متوسط',
          'postureScore': 83,
          'summary': 'جلسة أقدم',
          'symmetryLabel': 'جيد',
          'comparabilityLabel': 'مقبولة',
          'shoulderWaistChange': 5.2,
          'recommendation': 'حافظ على نفس ظروف التصوير',
          'muscleMetrics': [
            {
              'name': 'الأكتاف',
              'score': 76,
              'status': 'جيد',
              'note': 'قراءة سابقة',
            },
          ],
        },
      ]),
    });

    await tester.pumpWidget(const FitProgressApp());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('مقارنة آخر جلستين'),
      500,
      scrollable: find.byType(Scrollable),
    );

    await tester.tap(find.text('مقارنة آخر جلستين'));
    await tester.pumpAndSettle();

    expect(find.text('فرق العضلات'), findsOneWidget);
    expect(find.text('من 76% إلى 82%'), findsOneWidget);
    expect(find.text('+6%'), findsOneWidget);
    expect(find.text('ملخص العضلات'), findsOneWidget);
    expect(find.text('أفضل تحسن: الأكتاف (+6%).'), findsOneWidget);
  });
}
