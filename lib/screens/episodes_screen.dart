import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/episode_item.dart';
import '../models/series_item.dart';
import '../services/animerc_repository.dart';
import '../theme/app_colors.dart';
import '../utils/validators.dart';
import '../widgets/form_widgets.dart';
import '../widgets/page_shell.dart';

/// إضافة حلقة وربطها بمسلسل، مع عرض الحلقات الموجودة
/// (يطابق صفحة episodes.html في تطبيق الويب).
class EpisodesScreen extends StatefulWidget {
  const EpisodesScreen({super.key});

  @override
  State<EpisodesScreen> createState() => _EpisodesScreenState();
}

class _EpisodesScreenState extends State<EpisodesScreen> {
  final _repository = AnimercRepository();
  final _formKey = GlobalKey<FormState>();

  final _episodeName = TextEditingController();
  final _groupName = TextEditingController();
  final _duration = TextEditingController();
  final _episodeUrl = TextEditingController();
  final _additionalUrl = TextEditingController();
  final _description = TextEditingController();

  List<SeriesItem> _series = [];
  List<EpisodeItem> _episodes = [];

  String? _seriesId;
  int _formVersion = 0;

  bool _loading = true;
  bool _loadFailed = false;
  bool _episodesFailed = false;
  bool _saving = false;
  String _status = '';
  bool _statusIsError = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _episodeName.dispose();
    _groupName.dispose();
    _duration.dispose();
    _episodeUrl.dispose();
    _additionalUrl.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
      _episodesFailed = false;
    });

    try {
      final series = await _repository.fetchAllSeries();
      if (!mounted) return;
      _series = series;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
      return;
    }

    await _loadEpisodes(showLoading: false);
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _loadEpisodes({bool showLoading = true}) async {
    if (showLoading) setState(() => _episodesFailed = false);
    try {
      final episodes = await _repository.fetchEpisodes();
      if (!mounted) return;
      setState(() => _episodes = episodes);
    } catch (_) {
      if (!mounted) return;
      setState(() => _episodesFailed = true);
    }
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
      final id = await _repository.addEpisode({
        'seriesId': _seriesId,
        'episodeGroupName': _groupName.text.trim(),
        'episodeUrl': normalizeUrl(_episodeUrl.text, 'الحلقة', required: true),
        'episodeName': _episodeName.text.trim(),
        'duration': parseOptionalInt(_duration.text),
        'additionalUrl': normalizeUrl(_additionalUrl.text, 'الرابط الإضافي'),
        'description': _description.text.trim(),
      });
      if (!mounted) return;

      _episodeName.clear();
      _groupName.clear();
      _duration.clear();
      _episodeUrl.clear();
      _additionalUrl.clear();
      _description.clear();
      setState(() {
        _seriesId = null;
        _formVersion++;
        _status = 'تمت إضافة الحلقة بنجاح. المعرّف: $id';
        _statusIsError = false;
      });
      await _loadEpisodes();
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
            : 'تعذر حفظ الحلقة. تحقق من الاتصال ثم أعد المحاولة.';
        _statusIsError = true;
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _seriesName(String id) {
    for (final item in _series) {
      if (item.id == id) return item.name;
    }
    return id;
  }

  @override
  Widget build(BuildContext context) {
    return PageShell(
      title: 'إضافة حلقة',
      subtitle: 'اختر المسلسل المرتبطة به الحلقة، وسيُنشأ معرّف الحلقة تلقائيًا.',
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
              const StatusMessage(
                message:
                    'تعذر تحميل قائمة المسلسلات. تحقق من قواعد Realtime Database.',
                isError: true,
              ),
              const SizedBox(height: 16),
              PrimaryButton(label: 'إعادة المحاولة', onPressed: _load),
            ],
          )
        else ...[
          _buildForm(),
          const SizedBox(height: 40),
          Text(
            'الحلقات الموجودة',
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 14),
          _buildEpisodesList(),
        ],
      ],
    );
  }

  Widget _buildForm() {
    if (_series.isEmpty) {
      return Text(
        'أضف مسلسلًا أولًا قبل إضافة الحلقات.',
        style: GoogleFonts.cairo(color: AppColors.muted),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldGrid(
            children: [
              FullWidthField(
                child: KeyedSubtree(
                  key: ValueKey('series-$_formVersion'),
                  child: AppDropdown<String>(
                    label: 'المسلسل',
                    hint: 'اختر المسلسل',
                    value: _seriesId,
                    items: [
                      for (final item in _series)
                        DropdownMenuItem(
                          value: item.id,
                          child: Text(
                            item.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) => setState(() => _seriesId = value),
                    validator: (value) =>
                        value == null ? 'اختر مسلسلًا موجودًا.' : null,
                  ),
                ),
              ),
              AppTextField(
                controller: _episodeName,
                label: 'اسم الحلقة',
                hint: 'الحلقة 1',
                maxLength: 200,
                validator: (value) =>
                    (value ?? '').trim().isEmpty ? 'اكتب اسم الحلقة.' : null,
              ),
              AppTextField(
                controller: _groupName,
                label: 'اسم المجموعة',
                hint: 'الموسم الأول',
                maxLength: 150,
              ),
              AppTextField(
                controller: _duration,
                label: 'المدة (بالدقائق)',
                hint: '45',
                ltr: true,
                keyboardType: TextInputType.number,
                validator: (value) => optionalIntValidator(value, 'مدة الحلقة'),
              ),
              AppTextField(
                controller: _episodeUrl,
                label: 'رابط الحلقة',
                hint: 'https://example.com/watch',
                ltr: true,
                keyboardType: TextInputType.url,
                validator: (value) =>
                    urlValidator(value, 'الحلقة', required: true),
              ),
              FullWidthField(
                child: AppTextField(
                  controller: _additionalUrl,
                  label: 'رابط إضافي',
                  hint: 'https://example.com/mirror',
                  ltr: true,
                  keyboardType: TextInputType.url,
                  validator: (value) => urlValidator(value, 'الرابط الإضافي'),
                ),
              ),
              FullWidthField(
                child: AppTextField(
                  controller: _description,
                  label: 'الوصف',
                  maxLines: 4,
                  maxLength: 3000,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'إضافة الحلقة',
            busy: _saving,
            onPressed: _submit,
          ),
          StatusMessage(message: _status, isError: _statusIsError),
        ],
      ),
    );
  }

  Widget _buildEpisodesList() {
    if (_episodesFailed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StatusMessage(
            message:
                'تعذر تحميل الحلقات. تحقق من قواعد Realtime Database.',
            isError: true,
          ),
          const SizedBox(height: 12),
          PrimaryButton(label: 'إعادة المحاولة', onPressed: _loadEpisodes),
        ],
      );
    }

    if (_episodes.isEmpty) {
      return Text(
        'لا توجد حلقات حتى الآن.',
        style: GoogleFonts.cairo(color: AppColors.muted),
      );
    }

    return Column(
      children: [
        for (final episode in _episodes)
          _EpisodeCard(
            episode: episode,
            seriesName: _seriesName(episode.seriesId),
          ),
      ],
    );
  }
}

class _EpisodeCard extends StatelessWidget {
  const _EpisodeCard({required this.episode, required this.seriesName});

  final EpisodeItem episode;
  final String seriesName;

  @override
  Widget build(BuildContext context) {
    final details = [
      'المسلسل: $seriesName',
      if (episode.groupName.isNotEmpty) 'المجموعة: ${episode.groupName}',
      if (episode.duration > 0) 'المدة: ${episode.duration} دقيقة',
    ].join(' · ');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            episode.name,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            details,
            style: GoogleFonts.cairo(color: AppColors.muted, fontSize: 12),
          ),
          if (episode.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              episode.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                color: AppColors.muted,
                fontSize: 13,
                height: 1.7,
              ),
            ),
          ],
          if (episode.url.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    episode.url,
                    textDirection: TextDirection.ltr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFC9A8FF),
                      fontSize: 12,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await Clipboard.setData(ClipboardData(text: episode.url));
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم نسخ رابط الحلقة',
                          style: GoogleFonts.cairo(),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text(
                    'نسخ الرابط',
                    style: GoogleFonts.cairo(
                      color: AppColors.pink,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
