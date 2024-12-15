import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class TimezoneDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const TimezoneDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.validator,
  });

  Future<List<DropdownMenuItem<String>>> _getFilteredTimeZones() async {
    final filteredTimezones = [
      'Europe/Berlin',
      'Europe/London',
      'Europe/Paris',
      'Europe/Rome',
      'Europe/Madrid',
      'Europe/Amsterdam',
      'Europe/Brussels',
      'Europe/Vienna',
      'Europe/Warsaw',
      'Europe/Prague',
    ];
    return filteredTimezones.map((String timezone) {
      // Convert timezone to a more readable format
      final parts = timezone.split('/');
      final city = parts.last.replaceAll('_', ' ');
      return DropdownMenuItem<String>(
        value: timezone,
        child: Text(city),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DropdownMenuItem<String>>>(
      future: _getFilteredTimeZones(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Text('Error loading time zones');
        } else {
          return DropdownButtonFormField2<String>(
            value: value,
            decoration: InputDecoration(
              labelText: 'Timezone',
              prefixIcon: const Icon(Icons.access_time),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: snapshot.data,
            onChanged: onChanged,
            validator: validator,
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: 48,
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: WidgetStateProperty.all(6),
                thumbVisibility: WidgetStateProperty.all(true),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
            ),
          );
        }
      },
    );
  }
}
