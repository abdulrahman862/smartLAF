import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:prototype1/features/User/User_home_screen.dart';
import 'package:prototype1/features/User/thank_you_for_reporting.dart';

class ReportLostItemScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const ReportLostItemScreen({super.key, required this.themeNotifier});

  @override
  State<ReportLostItemScreen> createState() => _ReportLostItemScreenState();
}

class _ReportLostItemScreenState extends State<ReportLostItemScreen> {
  String? _selectedLocation;
  String? _selectedCategory;
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _dateError;

  final List<String> locations = [
    'Main Lobby',
    'Library',
    'Cafeteria',
    'Block A',
    'Block B',
    'Sports Center',
  ];

  final List<String> categories = [
    'Electronics',
    'Accessories',
    'Clothing',
    'IDs / Cards',
    'Books',
    'Miscellaneous',
  ];

  void _clearFields() {
    setState(() {
      _selectedLocation = null;
      _selectedCategory = null;
      _fromDate = null;
      _toDate = null;
      _dateError = null;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).brightness == Brightness.dark
              ? ThemeData.dark()
              : ThemeData.light(),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
        _dateError = null;
      });
    }
  }

  void _submitReport() {
    setState(() => _dateError = null);

    if (_selectedLocation == null ||
        _selectedCategory == null ||
        _fromDate == null ||
        _toDate == null) {
      setState(() {
        _dateError = 'report.fill_all_fields'.tr();
      });
      return;
    }

    if (_fromDate!.isAfter(_toDate!)) {
      setState(() {
        _dateError = 'report.invalid_range'.tr();
      });
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ThankYouForReportingScreen(themeNotifier: widget.themeNotifier),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
    final inputColor = theme.cardColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: theme.iconTheme.color,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen(themeNotifier: widget.themeNotifier)),
            );
          },
        ),
        title: Text(
          'report.title'.tr(),
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('report.location_prompt'.tr(), style: theme.textTheme.titleMedium),
                  TextButton(
                    onPressed: _clearFields,
                    child: Text('Clear', style: TextStyle(color: textColor)),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: locations.map((location) {
                  final isSelected = _selectedLocation == location;
                  return FilterChip(
                    label: Text(location),
                    selected: isSelected,
                    onSelected: (_) => setState(() {
                      _selectedLocation = isSelected ? null : location;
                    }),
                    selectedColor: Colors.black,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : textColor),
                    backgroundColor: theme.cardColor,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text('filter.date_range'.tr(), style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: inputColor, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          _fromDate != null
                              ? 'filter.from_date'.tr(args: [_fromDate!.toLocal().toString().split(' ')[0]])
                              : 'filter.from_date_placeholder'.tr(),
                          style: TextStyle(color: textColor.withOpacity(0.7)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: inputColor, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          _toDate != null
                              ? 'filter.to_date'.tr(args: [_toDate!.toLocal().toString().split(' ')[0]])
                              : 'filter.to_date_placeholder'.tr(),
                          style: TextStyle(color: textColor.withOpacity(0.7)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_dateError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _dateError!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              const SizedBox(height: 20),
              Text('filter.category'.tr(), style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
                hint: Text('filter.category'.tr(), style: TextStyle(color: textColor.withOpacity(0.6))),
                dropdownColor: inputColor,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('report.button'.tr(), style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
