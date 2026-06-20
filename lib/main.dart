import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const FitProgressApp());
}

class FitProgressApp extends StatelessWidget {
  const FitProgressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitProgress AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff1f7a5a),
        ),
      ),
      home: const StartPage(),
    );
  }
}

enum PhotoAngle { front, side, back }

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final _imagePicker = ImagePicker();
  final Map<PhotoAngle, XFile> _photos = {};
  bool _showReport = false;

  Future<void> _pickPhoto(PhotoAngle angle) async {
    final photo = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (photo == null) {
      return;
    }

    setState(() {
      _photos[angle] = photo;
      _showReport = false;
    });
  }

  void _showProgressReport() {
    setState(() {
      _showReport = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FitProgress AI'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const _IntroSection(),
              const SizedBox(height: 28),
              _PhotoCaptureSection(
                photos: _photos,
                onPickPhoto: _pickPhoto,
              ),
              const SizedBox(height: 24),
              _StartButton(
                enabled: _photos.length == PhotoAngle.values.length,
                onPressed: _showProgressReport,
              ),
              if (_showReport) ...[
                const SizedBox(height: 24),
                const _ProgressReportSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroSection extends StatelessWidget {
  const _IntroSection();

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
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
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

class _PhotoCaptureSection extends StatelessWidget {
  const _PhotoCaptureSection({
    required this.photos,
    required this.onPickPhoto,
  });

  final Map<PhotoAngle, XFile> photos;
  final ValueChanged<PhotoAngle> onPickPhoto;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'صور المقارنة المطلوبة',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'التقط أو اختر نفس الزوايا في كل مرة حتى تكون المقارنة أكثر ثباتًا.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
        ),
        const SizedBox(height: 16),
        _PhotoSlot(
          angle: PhotoAngle.front,
          title: 'الصورة الأمامية',
          subtitle: 'الوقوف بشكل مستقيم والذراعان بجانب الجسم',
          icon: Icons.accessibility_new,
          photo: photos[PhotoAngle.front],
          onPickPhoto: onPickPhoto,
        ),
        const SizedBox(height: 12),
        _PhotoSlot(
          angle: PhotoAngle.side,
          title: 'الصورة الجانبية',
          subtitle: 'نفس المسافة والإضاءة مع دوران الجسم للجانب',
          icon: Icons.rotate_90_degrees_ccw,
          photo: photos[PhotoAngle.side],
          onPickPhoto: onPickPhoto,
        ),
        const SizedBox(height: 12),
        _PhotoSlot(
          angle: PhotoAngle.back,
          title: 'الصورة الخلفية',
          subtitle: 'الظهر باتجاه الكاميرا والوقفة ثابتة',
          icon: Icons.person_outline,
          photo: photos[PhotoAngle.back],
          onPickPhoto: onPickPhoto,
        ),
      ],
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({
    required this.angle,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.photo,
    required this.onPickPhoto,
  });

  final PhotoAngle angle;
  final String title;
  final String subtitle;
  final IconData icon;
  final XFile? photo;
  final ValueChanged<PhotoAngle> onPickPhoto;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasPhoto = photo != null;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => onPickPhoto(angle),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasPhoto ? colorScheme.primary : colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              _PhotoPreview(icon: icon, photo: photo),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      hasPhoto
                          ? 'تم اختيار الصورة. اضغط لتغييرها.'
                          : subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                hasPhoto
                    ? Icons.check_circle
                    : Icons.add_photo_alternate_outlined,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({
    required this.icon,
    required this.photo,
  });

  final IconData icon;
  final XFile? photo;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 64,
        height: 88,
        child: photo == null
            ? ColoredBox(
                color: colorScheme.primaryContainer,
                child: Icon(
                  icon,
                  color: colorScheme.onPrimaryContainer,
                  size: 34,
                ),
              )
            : Image.network(
                photo!.path,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return ColoredBox(
                    color: colorScheme.errorContainer,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: colorScheme.onErrorContainer,
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: enabled ? onPressed : null,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(enabled ? 'ابدأ الفحص' : 'اختر الصور الثلاث أولًا'),
    );
  }
}

class _ProgressReportSection extends StatelessWidget {
  const _ProgressReportSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                'تقرير التقدم التجريبي',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _ScoreCard(),
          const SizedBox(height: 16),
          const _ReportMetric(
            title: 'تقدير التطور البصري',
            value: '72%',
            description: 'تحسن ظاهر في تناسق الجزء العلوي مقارنة بالجلسة السابقة.',
          ),
          const Divider(height: 24),
          const _ReportMetric(
            title: 'مؤشر الثقة',
            value: 'متوسط',
            description: 'يعتمد على ثبات الإضاءة والمسافة ووضوح الصور المختارة.',
          ),
          const Divider(height: 24),
          const _ReportMetric(
            title: 'تغير نسبة الكتف إلى الخصر',
            value: '+4.8%',
            description: 'تغير تقديري مبني على مقارنة بصرية وليس قياسًا تشريحيًا دقيقًا.',
          ),
          const Divider(height: 24),
          const _ReportMetric(
            title: 'ثبات الوقفة',
            value: '81%',
            description: 'كلما كانت الوقفة أقرب بين الجلسات كانت المقارنة أفضل.',
          ),
          const SizedBox(height: 14),
          Text(
            'ملاحظة: هذه النتائج للعرض التجريبي فقط. التحليل الحقيقي سيُضاف لاحقًا بعد تثبيت خطوات التقاط الصور.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 78,
            height: 78,
            child: CircularProgressIndicator(
              value: 0.72,
              strokeWidth: 8,
              backgroundColor: colorScheme.surface,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visual progress estimate',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '72%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportMetric extends StatelessWidget {
  const _ReportMetric({
    required this.title,
    required this.value,
    required this.description,
  });

  final String title;
  final String value;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
        ),
      ],
    );
  }
}
