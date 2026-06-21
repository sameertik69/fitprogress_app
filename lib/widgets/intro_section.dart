import 'package:flutter/material.dart';

class IntroSection extends StatelessWidget {
  const IntroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.monitor_heart_outlined,
          size: 68,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 22),
        Text(
          'قياس تطور الجسم',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          'سنبدأ بتجربة بسيطة لقياس تطور شكل الجسم والعضلات من خلال صور مقارنة ثابتة.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
        const SizedBox(height: 12),
        Text(
          'النتائج ستكون تقديرًا بصريًا وليست قياسًا طبيًا أو قياسًا دقيقًا للكتلة العضلية.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
