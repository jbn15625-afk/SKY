import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/series_item.dart';
import '../services/animerc_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/form_widgets.dart';
import '../widgets/network_poster.dart';
import '../widgets/page_shell.dart';

/// اختيار المسلسلات التي تظهر في سلايدر الصفحة الرئيسية
/// (يطابق صفحة slider.html في تطبيق الويب).
class SliderManagerScreen extends StatefulWidget {
  const SliderManagerScreen({super.key});

  @override
  State<SliderManagerScreen> createState() => _SliderManagerScreenState();
}

class _SliderManagerScreenState extends State<SliderManagerScreen> {
  final _repository = AnimercRepository();

  List<SeriesItem> _series = [];
  final Set<String> _selected = {};

  bool _loading = true;
  bool _saving = false;
  bool _loadFailed = false;
  String _status = '';
  bool _statusIsError = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });

    try {
      final results = await Future.wait([
        _repository.fetchAllSeries(),
        _repository.fetchSliderIds(),
      ]);
      if (!mounted) return;
      setState(() {
        _series = results[0] as List<SeriesItem>;
        _selected
          ..clear()
          ..addAll(results[1] as List<String>);
        _loading = false;
        _status = 'حدد المسلسلات التي تريد عرضها في السلايدر.';
        _statusIsError = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
        _status =
            'تعذر تحميل المسلسلات. تحقق من الاتصال وقواعد Realtime Database.';
        _statusIsError = true;
      });
    }
  }

  Future<void> _save() async {
    // نحفظ بترتيب المسلسلات في القائمة، مثل موقع الويب.
    final ids = [
      for (final item in _series)
        if (_selected.contains(item.id)) item.id,
    ];

    setState(() {
      _saving = true;
      _status = 'جارٍ حفظ اختيار السلايدر...';
      _statusIsError = false;
    });

    try {
      await _repository.saveSliderSelection(ids);
      if (!mounted) return;
      setState(() {
        _status = 'تم حفظ اختيار السلايدر بنجاح.';
        _statusIsError = false;
      });
    } catch (error) {
      if (!mounted) return;
      final text = error.toString();
      setState(() {
        _status = text.contains('permission-denied') ||
                text.contains('PERMISSION_DENIED')
            ? 'رفضت قواعد قاعدة البيانات الحفظ. انشر قواعد Realtime Database المحدّثة.'
            : 'تعذر حفظ الاختيار. تحقق من الاتصال ثم أعد المحاولة.';
        _statusIsError = true;
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toggle(String id, bool? value) {
    setState(() {
      if (value ?? false) {
        _selected.add(id);
      } else {
        _selected.remove(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageShell(
      title: 'اختيار أنميات السلايدر',
      subtitle: 'اختر المسلسلات التي تريد عرضها في السلايدر على الرئيسية.',
      children: [
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator(color: Colors.white)),
          )
        else if (_loadFailed)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusMessage(message: _status, isError: true),
              const SizedBox(height: 16),
              PrimaryButton(label: 'إعادة المحاولة', onPressed: _load),
            ],
          )
        else if (_series.isEmpty)
          Container(
            height: 160,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'لا توجد مسلسلات للاختيار. أضف مسلسلًا أولًا.',
              style: GoogleFonts.cairo(color: AppColors.muted),
            ),
          )
        else ...[
          for (final item in _series)
            _SeriesOption(
              series: item,
              selected: _selected.contains(item.id),
              onChanged: (value) => _toggle(item.id, value),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PrimaryButton(
                label: 'حفظ الاختيار',
                busy: _saving,
                onPressed: _save,
              ),
              Text(
                _selected.isEmpty
                    ? 'لم يتم اختيار مسلسلات'
                    : 'تم اختيار ${_selected.length} مسلسل',
                style: GoogleFonts.cairo(color: AppColors.muted, fontSize: 13),
              ),
            ],
          ),
          StatusMessage(message: _status, isError: _statusIsError),
        ],
      ],
    );
  }
}

class _SeriesOption extends StatelessWidget {
  const _SeriesOption({
    required this.series,
    required this.selected,
    required this.onChanged,
  });

  final SeriesItem series;
  final bool selected;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChanged(!selected),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.pink : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: selected,
                  onChanged: onChanged,
                  activeColor: AppColors.pink,
                  checkColor: Colors.white,
                  side: const BorderSide(color: AppColors.muted),
                ),
                const SizedBox(width: 6),
                NetworkPoster(
                  url: series.coverUrl,
                  width: 52,
                  height: 74,
                  borderRadius: 8,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        series.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        series.year.isEmpty ? 'السنة غير محددة' : series.year,
                        style: GoogleFonts.cairo(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        series.id,
                        textDirection: TextDirection.ltr,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6F6B7D),
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
