import 'package:flutter/material.dart';

import '../models/series_item.dart';
import '../services/animerc_repository.dart';
import '../utils/validators.dart';
import '../widgets/form_widgets.dart';
import '../widgets/page_shell.dart';

/// إضافة مسلسل جديد إلى Realtime Database
/// (يطابق صفحة admin.html في تطبيق الويب، وبنفس شروط قواعد الأمان).
class AddSeriesScreen extends StatefulWidget {
  const AddSeriesScreen({super.key});

  @override
  State<AddSeriesScreen> createState() => _AddSeriesScreenState();
}

class _AddSeriesScreenState extends State<AddSeriesScreen> {
  final _repository = AnimercRepository();
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _type = TextEditingController();
  final _year = TextEditingController();
  final _countries = TextEditingController();
  final _audioLanguage = TextEditingController();
  final _subtitleLanguage = TextEditingController();
  final _rating = TextEditingController();
  final _likes = TextEditingController();
  final _studio = TextEditingController();
  final _episodeCount = TextEditingController();
  final _platform = TextEditingController();
  final _seasonCount = TextEditingController();
  final _previousSeasonId = TextEditingController();
  final _nextSeasonId = TextEditingController();
  final _coverUrl = TextEditingController();
  final _desktopBackgroundUrl = TextEditingController();
  final _mobileBackgroundUrl = TextEditingController();
  final _description = TextEditingController();

  String _genre = 'other';
  int _formVersion = 0;
  bool _saving = false;
  String _status = '';
  bool _statusIsError = false;

  List<TextEditingController> get _controllers => [
        _name,
        _type,
        _year,
        _countries,
        _audioLanguage,
        _subtitleLanguage,
        _rating,
        _likes,
        _studio,
        _episodeCount,
        _platform,
        _seasonCount,
        _previousSeasonId,
        _nextSeasonId,
        _coverUrl,
        _desktopBackgroundUrl,
        _mobileBackgroundUrl,
        _description,
      ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _ratingValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final rating = double.tryParse(text);
    if (rating == null || rating < 0 || rating > 10) {
      return 'التقييم يجب أن يكون بين 0 و10.';
    }
    return null;
  }

  Map<String, Object?> _buildData() {
    final rating = double.tryParse(_rating.text.trim()) ?? 0;

    return {
      'name': _name.text.trim(),
      'type': _type.text.trim(),
      'year': parseOptionalInt(_year.text),
      'countries': _countries.text.trim(),
      'description': _description.text.trim(),
      'audioLanguage': _audioLanguage.text.trim(),
      'subtitleLanguage': _subtitleLanguage.text.trim(),
      'genre': _genre,
      'coverUrl': normalizeUrl(_coverUrl.text, 'الغلاف'),
      'desktopBackgroundUrl':
          normalizeUrl(_desktopBackgroundUrl.text, 'خلفية الكمبيوتر'),
      'mobileBackgroundUrl':
          normalizeUrl(_mobileBackgroundUrl.text, 'خلفية الهاتف'),
      'likes': parseOptionalInt(_likes.text),
      'studio': _studio.text.trim(),
      // نخزّن الأعداد الصحيحة كأعداد صحيحة (8 وليس 8.0) مثل موقع الويب.
      'rating': rating == rating.roundToDouble() ? rating.toInt() : rating,
      'episodeCount': parseOptionalInt(_episodeCount.text),
      'platform': _platform.text.trim(),
      'seasonCount': parseOptionalInt(_seasonCount.text),
      'previousSeasonId': _previousSeasonId.text.trim(),
      'nextSeasonId': _nextSeasonId.text.trim(),
    };
  }

  Future<void> _submit() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _status = 'راجع الحقول المظلّلة ثم أعد المحاولة.';
        _statusIsError = true;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _status = '';
    });

    try {
      final id = await _repository.addSeries(_buildData());
      if (!mounted) return;

      for (final controller in _controllers) {
        controller.clear();
      }
      setState(() {
        _genre = 'other';
        _formVersion++;
        _status = 'تمت إضافة المسلسل بنجاح. المعرّف: $id';
        _statusIsError = false;
      });
    } on FormatException catch (error) {
      if (!mounted) return;
      setState(() {
        _status = error.message;
        _statusIsError = true;
      });
    } catch (error) {
      if (!mounted) return;
      final text = error.toString();
      setState(() {
        _status = text.contains('permission-denied') ||
                text.contains('PERMISSION_DENIED')
            ? 'رفضت قواعد قاعدة البيانات الحفظ. تحقق من قواعد Realtime Database المنشورة.'
            : 'تعذر حفظ المسلسل. تحقق من الاتصال ثم أعد المحاولة.';
        _statusIsError = true;
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageShell(
      title: 'إضافة مسلسل',
      subtitle: 'أدخل معلومات مسلسل جديد واحفظه في قاعدة البيانات.',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FieldGrid(
                children: [
                  AppTextField(
                    controller: _name,
                    label: 'اسم المسلسل',
                    hint: 'مثال: Weak Hero Class 1',
                    maxLength: 150,
                    validator: (value) => (value ?? '').trim().isEmpty
                        ? 'اكتب اسم المسلسل.'
                        : null,
                  ),
                  AppTextField(
                    controller: _type,
                    label: 'النوع',
                    hint: 'مسلسل، فيلم، أنمي',
                    maxLength: 60,
                  ),
                  AppTextField(
                    controller: _year,
                    label: 'سنة الإصدار',
                    hint: '2022',
                    ltr: true,
                    keyboardType: TextInputType.number,
                    validator: (value) => optionalIntValidator(
                      value,
                      'سنة الإصدار',
                      min: 1900,
                      max: 2100,
                    ),
                  ),
                  KeyedSubtree(
                    key: ValueKey('genre-$_formVersion'),
                    child: AppDropdown<String>(
                      label: 'التصنيف',
                      value: _genre,
                      items: [
                        for (final entry in SeriesItem.genreLabels.entries)
                          DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          ),
                      ],
                      onChanged: (value) =>
                          setState(() => _genre = value ?? 'other'),
                    ),
                  ),
                  AppTextField(
                    controller: _countries,
                    label: 'الدول',
                    hint: 'كوريا الجنوبية، اليابان',
                    maxLength: 300,
                  ),
                  AppTextField(
                    controller: _audioLanguage,
                    label: 'لغة الصوت',
                    hint: 'الكورية',
                    maxLength: 100,
                  ),
                  AppTextField(
                    controller: _subtitleLanguage,
                    label: 'لغة الترجمة',
                    hint: 'العربية',
                    maxLength: 100,
                  ),
                  AppTextField(
                    controller: _rating,
                    label: 'التقييم (من 10)',
                    hint: '8.5',
                    ltr: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _ratingValidator,
                  ),
                  AppTextField(
                    controller: _likes,
                    label: 'عدد الإعجابات',
                    hint: '0',
                    ltr: true,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        optionalIntValidator(value, 'عدد الإعجابات'),
                  ),
                  AppTextField(
                    controller: _studio,
                    label: 'الاستوديو',
                    maxLength: 150,
                  ),
                  AppTextField(
                    controller: _episodeCount,
                    label: 'عدد الحلقات',
                    hint: '16',
                    ltr: true,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        optionalIntValidator(value, 'عدد الحلقات'),
                  ),
                  AppTextField(
                    controller: _platform,
                    label: 'المنصة',
                    hint: 'Netflix',
                    maxLength: 150,
                  ),
                  AppTextField(
                    controller: _seasonCount,
                    label: 'عدد المواسم',
                    hint: '1',
                    ltr: true,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        optionalIntValidator(value, 'عدد المواسم'),
                  ),
                  AppTextField(
                    controller: _previousSeasonId,
                    label: 'معرّف الموسم السابق',
                    ltr: true,
                    maxLength: 150,
                  ),
                  AppTextField(
                    controller: _nextSeasonId,
                    label: 'معرّف الموسم التالي',
                    ltr: true,
                    maxLength: 150,
                  ),
                  FullWidthField(
                    child: AppTextField(
                      controller: _coverUrl,
                      label: 'رابط الغلاف',
                      hint: 'example.com/poster.jpg',
                      ltr: true,
                      keyboardType: TextInputType.url,
                      validator: (value) => urlValidator(value, 'الغلاف'),
                    ),
                  ),
                  FullWidthField(
                    child: AppTextField(
                      controller: _desktopBackgroundUrl,
                      label: 'رابط خلفية الكمبيوتر',
                      hint: 'example.com/desktop.jpg',
                      ltr: true,
                      keyboardType: TextInputType.url,
                      validator: (value) =>
                          urlValidator(value, 'خلفية الكمبيوتر'),
                    ),
                  ),
                  FullWidthField(
                    child: AppTextField(
                      controller: _mobileBackgroundUrl,
                      label: 'رابط خلفية الهاتف',
                      hint: 'example.com/mobile.jpg',
                      ltr: true,
                      keyboardType: TextInputType.url,
                      validator: (value) =>
                          urlValidator(value, 'خلفية الهاتف'),
                    ),
                  ),
                  FullWidthField(
                    child: AppTextField(
                      controller: _description,
                      label: 'الوصف',
                      hint: 'اكتب وصف المسلسل هنا...',
                      maxLines: 5,
                      maxLength: 3000,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'إضافة المسلسل',
                busy: _saving,
                onPressed: _submit,
              ),
              StatusMessage(message: _status, isError: _statusIsError),
            ],
          ),
        ),
      ],
    );
  }
}
