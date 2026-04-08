import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterbase/app/di/service_locator.dart';
import 'package:flutterbase/presentation/viewmodels/add_points_viewmodel.dart';
import 'package:flutterbase/presentation/widgets/ui/widgets.dart';
import 'package:flutterbase/shared/l10n/app_strings.dart';
import 'package:flutterbase/shared/theme/theme.dart';

class AddPointsPage extends StatefulWidget {
  const AddPointsPage({super.key, required this.userId});
  final int userId;

  @override
  State<AddPointsPage> createState() => _AddPointsPageState();
}

class _AddPointsPageState extends State<AddPointsPage> {
  late final AddPointsViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _reasonFocusNode = FocusNode();
  final _pointsController = TextEditingController();
  final _tagController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _viewModel = sl<AddPointsViewModel>();
    _viewModel.addListener(_onChanged);
    _viewModel.loadSuggestions(widget.userId);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    _viewModel.reset();
    _reasonController.dispose();
    _reasonFocusNode.dispose();
    _pointsController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (_viewModel.state == AddPointsState.success) {
      if (mounted) Navigator.of(context).pop();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppMainHeader(title: AppStrings.pointAdd),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pageMargin),
          children: [
            AppCard(
              child: ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text(AppStrings.pointDateTime),
                subtitle: Text(_formatDate(_selectedDate)),
                onTap: () => _pickDate(context),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildReasonField(context),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _pointsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: AppStrings.pointAmount,
                hintText: AppStrings.pointAmountHint,
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null ||
                          v.isEmpty ||
                          int.tryParse(v) == null ||
                          int.parse(v) <= 0)
                      ? AppStrings.pointAmountError
                      : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _tagController,
              decoration: const InputDecoration(
                labelText: AppStrings.pointTag,
                hintText: AppStrings.pointTagHint,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (_viewModel.state == AddPointsState.error)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Text(
                  _viewModel.error?.message ?? AppStrings.commonError,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            AppPrimaryButton(
              label: _viewModel.state == AddPointsState.loading
                  ? AppStrings.commonLoading
                  : AppStrings.commonSave,
              onPressed: _viewModel.state == AddPointsState.loading
                  ? null
                  : _submit,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonField(BuildContext context) {
    final suggestions = _viewModel.reasonSuggestions;
    return RawAutocomplete<String>(
      textEditingController: _reasonController,
      focusNode: _reasonFocusNode,
      optionsBuilder: (textEditingValue) {
        if (suggestions.isEmpty) return const [];
        final query = textEditingValue.text.toLowerCase();
        if (query.isEmpty) return suggestions;
        return suggestions.where(
          (s) => s.toLowerCase().contains(query),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: AppRadius.smBorder,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(option),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: AppStrings.pointReason,
            hintText: AppStrings.pointReasonHint,
            border: OutlineInputBorder(),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty)
                  ? AppStrings.pointReasonError
                  : null,
        );
      },
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (time == null) return;
    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
        0,
        0,
      );
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _viewModel.submit(
      userId: widget.userId,
      dateTime: _selectedDate,
      points: int.parse(_pointsController.text),
      reason: _reasonController.text.trim(),
      tag: _tagController.text.trim().isEmpty
          ? null
          : _tagController.text.trim(),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
