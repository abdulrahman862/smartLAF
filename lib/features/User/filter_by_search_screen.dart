import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:prototype1/features/User/my_claims_screen.dart';
import 'package:prototype1/features/User/settings_screen.dart';
import 'package:prototype1/features/User/User_home_screen.dart';
import 'package:prototype1/features/User/SearchResultsScreen.dart';

class FilterBySearchScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const FilterBySearchScreen({super.key, required this.themeNotifier});

  @override
  State<FilterBySearchScreen> createState() => _FilterBySearchScreenState();
}

class _FilterBySearchScreenState extends State<FilterBySearchScreen> {
  final List<String> _selectedLocations = [];
  String? _selectedCategory;
  DateTime? _fromDate;
  DateTime? _toDate;

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

  void _toggleLocation(String location) {
    setState(() {
      if (_selectedLocations.contains(location)) {
        _selectedLocations.remove(location);
      } else {
        _selectedLocations.add(location);
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedLocations.clear();
      _selectedCategory = null;
      _fromDate = null;
      _toDate = null;
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
      });
    }
  }

  void _handleSearch() {
    final now = DateTime.now();
    if ((_fromDate != null && _fromDate!.isAfter(now)) ||
        (_toDate != null && _toDate!.isAfter(now))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('filter.invalid_date'.tr())),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(
          locations: _selectedLocations,
          category: _selectedCategory,
          fromDate: _fromDate,
          toDate: _toDate,
        ),
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
          'filter.title'.tr(),
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
                  Text('filter.title'.tr(), style: theme.textTheme.titleMedium),
                  TextButton(
                    onPressed: _clearFilters,
                    child: Text('Clear', style: TextStyle(color: textColor)),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: locations.map((location) {
                  final isSelected = _selectedLocations.contains(location);
                  return FilterChip(
                    label: Text(location),
                    selected: isSelected,
                    onSelected: (_) => _toggleLocation(location),
                    selectedColor: Colors.black,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : textColor),
                    backgroundColor: theme.cardColor,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text('filter.category'.tr(), style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory != null && _selectedCategory!.isNotEmpty ? _selectedCategory : null,
                items: categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
                hint: Text('filter.category'.tr(), style: TextStyle(color: textColor.withOpacity(0.6))),
                style: TextStyle(color: textColor),
                dropdownColor: inputColor,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputColor,
                  hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
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
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          color: inputColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          color: inputColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
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
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _handleSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('filter.button'.tr(), style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
