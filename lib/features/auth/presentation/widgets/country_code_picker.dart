/// Country code dropdown picker — shows flag + dial code.
library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Simple model for a country dial code.
class CountryCode {
  const CountryCode({
    required this.name,
    required this.dialCode,
    required this.flag,
  });

  final String name;
  final String dialCode;
  final String flag;
}

/// Common country codes list.
const List<CountryCode> kCountryCodes = [
  CountryCode(name: 'Nepal', dialCode: '+977', flag: '🇳🇵'),
  CountryCode(name: 'United States', dialCode: '+1', flag: '🇺🇸'),
  CountryCode(name: 'India', dialCode: '+91', flag: '🇮🇳'),
  CountryCode(name: 'United Kingdom', dialCode: '+44', flag: '🇬🇧'),
  CountryCode(name: 'Canada', dialCode: '+1', flag: '🇨🇦'),
  CountryCode(name: 'Australia', dialCode: '+61', flag: '🇦🇺'),
  CountryCode(name: 'Germany', dialCode: '+49', flag: '🇩🇪'),
  CountryCode(name: 'France', dialCode: '+33', flag: '🇫🇷'),
  CountryCode(name: 'Japan', dialCode: '+81', flag: '🇯🇵'),
  CountryCode(name: 'China', dialCode: '+86', flag: '🇨🇳'),
  CountryCode(name: 'Brazil', dialCode: '+55', flag: '🇧🇷'),
  CountryCode(name: 'Nigeria', dialCode: '+234', flag: '🇳🇬'),
  CountryCode(name: 'South Africa', dialCode: '+27', flag: '🇿🇦'),
  CountryCode(name: 'UAE', dialCode: '+971', flag: '🇦🇪'),
  CountryCode(name: 'Saudi Arabia', dialCode: '+966', flag: '🇸🇦'),
  CountryCode(name: 'Pakistan', dialCode: '+92', flag: '🇵🇰'),
  CountryCode(name: 'Bangladesh', dialCode: '+880', flag: '🇧🇩'),
];

/// A compact country-code selector that opens a bottom sheet.
class CountryCodePicker extends StatelessWidget {
  const CountryCodePicker({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final CountryCode selected;
  final ValueChanged<CountryCode> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.dotInactive),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selected.dialCode,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.dotInactive,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Country',
                  style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: kCountryCodes.length,
                    itemBuilder: (_, i) {
                      final code = kCountryCodes[i];
                      final isSelected =
                          code.dialCode == selected.dialCode &&
                          code.name == selected.name;
                      return ListTile(
                        leading: Text(
                          code.flag,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          code.name,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        trailing: Text(
                          code.dialCode,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor: AppColors.primaryLight,
                        onTap: () {
                          onChanged(code);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
