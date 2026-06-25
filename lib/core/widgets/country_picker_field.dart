import 'package:flutter/material.dart';

import '../data/country_options.dart';
import '../theme/app_theme.dart';

typedef CountryOptionLabelBuilder = String Function(CountryOption option);

class CountryPickerField extends StatelessWidget {
  final String label;
  final String hintText;
  final CountryOption? selectedOption;
  final ValueChanged<CountryOption> onSelected;
  final FormFieldValidator<String>? validator;
  final CountryOptionLabelBuilder labelBuilder;

  const CountryPickerField({
    super.key,
    required this.label,
    required this.hintText,
    required this.selectedOption,
    required this.onSelected,
    required this.labelBuilder,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: selectedOption?.name,
      validator: validator,
      builder: (field) {
        return InkWell(
          onTap: () async {
            final option = await showModalBottomSheet<CountryOption>(
              context: context,
              isScrollControlled: true,
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.modal),
              ),
              builder: (_) => _CountryPickerSheet(
                title: label,
                selectedOption: selectedOption,
                labelBuilder: labelBuilder,
              ),
            );
            if (option != null) {
              onSelected(option);
              field.didChange(option.name);
            }
          },
          borderRadius: BorderRadius.circular(AppRadius.input),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              errorText: field.errorText,
              suffixIcon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
            ),
            child: Text(
              selectedOption == null ? hintText : labelBuilder(selectedOption!),
              style: TextStyle(
                color: selectedOption == null
                    ? AppColors.textMuted
                    : AppColors.textPrimary,
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  final String title;
  final CountryOption? selectedOption;
  final CountryOptionLabelBuilder labelBuilder;

  const _CountryPickerSheet({
    required this.title,
    required this.selectedOption,
    required this.labelBuilder,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final results = countryOptions.where((option) {
      if (query.isEmpty) return true;
      return option.name.toLowerCase().contains(query) ||
          option.code.toLowerCase().contains(query) ||
          option.dialCode.contains(query);
    }).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Select ${widget.title}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choose one option to update this field.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
              decoration: const InputDecoration(
                hintText: 'Search country or code',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: results.isEmpty
                  ? const _CountryPickerEmptyState()
                  : ListView.separated(
                      itemCount: results.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final option = results[index];
                        final isSelected =
                            option.code == widget.selectedOption?.code;
                        return _CountryOptionTile(
                          option: option,
                          isSelected: isSelected,
                          label: widget.labelBuilder(option),
                          onTap: () => Navigator.of(context).pop(option),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryOptionTile extends StatelessWidget {
  final CountryOption option;
  final bool isSelected;
  final String label;
  final VoidCallback onTap;

  const _CountryOptionTile({
    required this.option,
    required this.isSelected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.12)
                : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.35)
                  : AppColors.divider,
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${option.code.toUpperCase()} ${option.dialCode}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontFamily: 'Montserrat',
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.textPrimary,
                    size: 14,
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountryPickerEmptyState extends StatelessWidget {
  const _CountryPickerEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.divider, width: 0.8),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: AppColors.textMuted,
                size: 24,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No country found',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try a different country name, ISO code, or dial code.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontFamily: 'Montserrat',
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
