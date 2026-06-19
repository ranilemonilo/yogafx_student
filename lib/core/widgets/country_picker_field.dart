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
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              errorText: field.errorText,
              suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
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
    final results = countryOptions.where((option) {
      if (_query.trim().isEmpty) return true;
      final query = _query.trim().toLowerCase();
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Text(
              'Select ${widget.title}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 14),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: results.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final option = results[index];
                  final isSelected = option.code == widget.selectedOption?.code;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      widget.labelBuilder(option),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.primary,
                          )
                        : null,
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
