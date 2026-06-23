import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/photo_angle.dart';
import '../models/photo_readiness_report.dart';

class PhotoCaptureSection extends StatelessWidget {
  const PhotoCaptureSection({
    required this.photos,
    required this.readinessReport,
    required this.onPickPhoto,
    required this.onRemovePhoto,
    super.key,
  });

  final Map<PhotoAngle, XFile> photos;
  final PhotoReadinessReport? readinessReport;
  final ValueChanged<PhotoAngle> onPickPhoto;
  final ValueChanged<PhotoAngle> onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'صور المقارنة المطلوبة',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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
        PhotoSlot(
          angle: PhotoAngle.front,
          title: 'الصورة الأمامية',
          subtitle: 'الوقوف بشكل مستقيم والذراعان بجانب الجسم',
          icon: Icons.accessibility_new,
          photo: photos[PhotoAngle.front],
          onPickPhoto: onPickPhoto,
          onRemovePhoto: onRemovePhoto,
        ),
        const SizedBox(height: 12),
        PhotoSlot(
          angle: PhotoAngle.side,
          title: 'الصورة الجانبية',
          subtitle: 'نفس المسافة والإضاءة مع دوران الجسم للجانب',
          icon: Icons.rotate_90_degrees_ccw,
          photo: photos[PhotoAngle.side],
          onPickPhoto: onPickPhoto,
          onRemovePhoto: onRemovePhoto,
        ),
        const SizedBox(height: 12),
        PhotoSlot(
          angle: PhotoAngle.back,
          title: 'الصورة الخلفية',
          subtitle: 'الظهر باتجاه الكاميرا والوقفة ثابتة',
          icon: Icons.person_outline,
          photo: photos[PhotoAngle.back],
          onPickPhoto: onPickPhoto,
          onRemovePhoto: onRemovePhoto,
        ),
        if (readinessReport != null) ...[
          const SizedBox(height: 12),
          PhotoReadinessCard(report: readinessReport!),
        ],
      ],
    );
  }
}

class PhotoReadinessCard extends StatelessWidget {
  const PhotoReadinessCard({required this.report, super.key});

  final PhotoReadinessReport report;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = switch (report.level) {
      PhotoReadinessLevel.incomplete => Icons.pending_outlined,
      PhotoReadinessLevel.ready => Icons.check_circle_outline,
      PhotoReadinessLevel.attention => Icons.info_outline,
    };
    final color = switch (report.level) {
      PhotoReadinessLevel.incomplete => colorScheme.onSurfaceVariant,
      PhotoReadinessLevel.ready => colorScheme.primary,
      PhotoReadinessLevel.attention => colorScheme.tertiary,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  '${report.message} الحجم التقريبي: ${report.totalSizeLabel}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
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

class PhotoSlot extends StatelessWidget {
  const PhotoSlot({
    required this.angle,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.photo,
    required this.onPickPhoto,
    required this.onRemovePhoto,
    super.key,
  });

  final PhotoAngle angle;
  final String title;
  final String subtitle;
  final IconData icon;
  final XFile? photo;
  final ValueChanged<PhotoAngle> onPickPhoto;
  final ValueChanged<PhotoAngle> onRemovePhoto;

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
              color: hasPhoto
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              PhotoPreview(icon: icon, photo: photo),
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
                      hasPhoto ? 'تم اختيار الصورة. اضغط لتغييرها.' : subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (hasPhoto) ...[
                IconButton(
                  onPressed: () => onRemovePhoto(angle),
                  icon: const Icon(Icons.close),
                  color: colorScheme.error,
                  tooltip: 'حذف الصورة',
                ),
              ] else ...[
                Icon(
                  Icons.add_photo_alternate_outlined,
                  color: colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class PhotoPreview extends StatelessWidget {
  const PhotoPreview({required this.icon, required this.photo, super.key});

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
            : FutureBuilder<Uint8List>(
                future: photo!.readAsBytes(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return ColoredBox(
                      color: colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    );
                  }

                  return Image.memory(
                    snapshot.data!,
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
                  );
                },
              ),
      ),
    );
  }
}
