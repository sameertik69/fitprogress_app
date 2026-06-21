import 'package:flutter/material.dart';

class StartButton extends StatelessWidget {
  const StartButton({
    required this.enabled,
    required this.isAnalyzing,
    required this.onPressed,
    super.key,
  });

  final bool enabled;
  final bool isAnalyzing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: enabled && !isAnalyzing ? onPressed : null,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        isAnalyzing
            ? 'جاري الفحص...'
            : enabled
            ? 'ابدأ الفحص'
            : 'اختر الصور الثلاث أولًا',
      ),
    );
  }
}
