import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lottie/lottie.dart';
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

class _FilterBySearchScreenState extends State<FilterBySearchScreen> with SingleTickerProviderStateMixin {
  final List<String> _selectedLocations = [];
  String? _selectedCategory;
  DateTime? _fromDate;
  DateTime? _toDate;
  late AnimationController _searchAnimationController;
  final TextEditingController _searchController = TextEditingController();
  bool _hasFilters = false;

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

  @override
  void initState() {
    super.initState();
    _searchAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _searchAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _updateHasFilters() {
    setState(() {
      _hasFilters = _selectedLocations.isNotEmpty ||
          _selectedCategory != null ||
          _fromDate != null ||
          _toDate != null;
    });
  }

  void _toggleLocation(String location) {
    setState(() {
      if (_selectedLocations.contains(location)) {
        _selectedLocations.remove(location);
      } else {
        _selectedLocations.add(location);
      }
      _updateHasFilters();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedLocations.clear();
      _selectedCategory = null;
      _fromDate = null;
      _toDate = null;
      _updateHasFilters();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final now = DateTime.now();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final accentColor = isDarkMode ? Colors.blueAccent : const Color(0xFF4A80F0);

    // Custom header style
    final headerStyle = TextStyle(
      color: isDarkMode ? Colors.white : Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: accentColor,
              onPrimary: Colors.white,
              surface: theme.scaffoldBackgroundColor,
              onSurface: theme.textTheme.bodyLarge?.color ?? Colors.black,
            ),
            dialogBackgroundColor: theme.colorScheme.surface,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 24,
            ),
            datePickerTheme: DatePickerThemeData(
              headerHelpStyle: headerStyle,
              headerForegroundColor: isDarkMode ? Colors.white : Colors.black,
              headerBackgroundColor: isDarkMode
                  ? theme.scaffoldBackgroundColor
                  : Colors.white,
              dayOverlayColor: MaterialStateProperty.resolveWith(
                    (states) {
                  if (states.contains(MaterialState.selected)) {
                    return accentColor.withOpacity(0.2);
                  }
                  if (states.contains(MaterialState.hovered)) {
                    return accentColor.withOpacity(0.1);
                  }
                  return null;
                },
              ),
              todayBorder: BorderSide(color: accentColor, width: 1),
              dayStyle: TextStyle(fontWeight: FontWeight.w500),
              weekdayStyle: TextStyle(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.7)
                    : Colors.black.withOpacity(0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: child,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
          // If to date is before from date, adjust it
          if (_toDate != null && _toDate!.isBefore(_fromDate!)) {
            _toDate = _fromDate;
          }
        } else {
          _toDate = picked;
          // If from date is after to date, adjust it
          if (_fromDate != null && _fromDate!.isAfter(_toDate!)) {
            _fromDate = _toDate;
          }
        }
        _updateHasFilters();
      });
    }
  }

  void _handleSearch() {
    final now = DateTime.now();
    if ((_fromDate != null && _fromDate!.isAfter(now)) ||
        (_toDate != null && _toDate!.isAfter(now))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('filter.invalid_date'.tr()),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // Animate the button briefly
    _searchAnimationController.reset();
    _searchAnimationController.forward();

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

  void _navigateToScreen(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final accentColor = isDarkMode ? Colors.blueAccent : const Color(0xFF4A80F0);
    final cardColor = theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: accentColor,
              size: 22,
            ),
          ),
          onPressed: () {
            _navigateToScreen(HomeScreen(themeNotifier: widget.themeNotifier));
          },
        ),
        title: Text(
          'filter.title'.tr(),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 28,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          if (_hasFilters)
            TextButton(
              onPressed: _clearFilters,
              child: Text(
                'Clear',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'filter.search_description'.tr(),
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 30, bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'filter.location_title'.tr(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'filter.location_subtitle'.tr(),
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildLocationGrid(),
                          const SizedBox(height: 32),
                          Text(
                            'filter.category'.tr(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'filter.category_subtitle'.tr(),
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildCategoryDropdown(cardColor, textColor, accentColor),
                          const SizedBox(height: 32),
                          Text(
                            'filter.date_range'.tr(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'filter.date_subtitle'.tr(),
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDateSelectors(cardColor, textColor, accentColor),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        width: double.infinity,
        child: AnimatedBuilder(
          animation: _searchAnimationController,
          builder: (context, child) {
            final scale = 1.0 + (_searchAnimationController.value * 0.03);
            return Transform.scale(
              scale: scale,
              child: ElevatedButton(
                onPressed: _handleSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'filter.search_button'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'nav.home'.tr(), accentColor),
                _buildNavItem(1, Icons.check_circle_outline, 'nav.claims'.tr(), accentColor),
                _buildNavItem(2, Icons.settings_outlined, 'nav.settings'.tr(), accentColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 2.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      children: locations.map((location) {
        final isSelected = _selectedLocations.contains(location);
        final theme = Theme.of(context);
        final isDarkMode = theme.brightness == Brightness.dark;
        final accentColor = isDarkMode ? Colors.blueAccent : const Color(0xFF4A80F0);

        // Define location icons mapping
        final Map<String, IconData> locationIcons = {
          'Main Lobby': Icons.meeting_room_outlined,
          'Library': Icons.menu_book_outlined,
          'Cafeteria': Icons.restaurant_outlined,
          'Block A': Icons.domain_outlined,
          'Block B': Icons.apartment_outlined,
          'Sports Center': Icons.sports_basketball_outlined,
        };

        final IconData locationIcon = locationIcons[location] ?? Icons.place_outlined;

        return InkWell(
          onTap: () => _toggleLocation(location),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? accentColor : theme.cardColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? accentColor.withOpacity(0.4)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: isSelected ? 8 : 4,
                  offset: isSelected ? const Offset(0, 3) : const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                if (isSelected)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check,
                          size: 12,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        locationIcon,
                        size: 16,
                        color: isSelected ? Colors.white : accentColor,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          location,
                          style: TextStyle(
                            color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryDropdown(Color cardColor, Color textColor, Color accentColor) {
    // Map of categories to their respective icons
    final Map<String, IconData> categoryIcons = {
      'Electronics': Icons.devices,
      'Accessories': Icons.watch,
      'Clothing': Icons.checkroom,
      'IDs / Cards': Icons.credit_card,
      'Books': Icons.book,
      'Miscellaneous': Icons.category,
    };

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        child: DropdownButtonFormField<String>(
          value: _selectedCategory,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.keyboard_arrow_down_rounded,
              color: accentColor,
              size: 20,
            ),
          ),
          elevation: 16,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(left: 20, right: 12, top: 8, bottom: 8),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: accentColor, width: 1.5),
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: cardColor,
          hint: Text(
            'filter.category_placeholder'.tr(),
            style: TextStyle(color: textColor.withOpacity(0.6)),
          ),
          menuMaxHeight: 300,
          onChanged: (String? value) {
            setState(() {
              _selectedCategory = value;
              _updateHasFilters();
            });
          },
          selectedItemBuilder: (BuildContext context) {
            return categories.map<Widget>((String item) {
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      categoryIcons[item] ?? Icons.category,
                      color: accentColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              );
            }).toList();
          },
          items: categories.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        categoryIcons[value] ?? Icons.category,
                        color: accentColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDateSelectors(Color cardColor, Color textColor, Color accentColor) {
    return Column(
      children: [
        InkWell(
          onTap: () => _selectDate(context, true),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(_fromDate != null ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.calendar_month_rounded,
                        color: _fromDate != null ? accentColor : textColor.withOpacity(0.5),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'filter.from_date_label'.tr(),
                          style: TextStyle(
                            fontSize: 13,
                            color: textColor.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _fromDate != null
                              ? DateFormat('EEEE, MMMM d, yyyy').format(_fromDate!)
                              : 'filter.select_date'.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: _fromDate != null ? FontWeight.w600 : FontWeight.w400,
                            color: _fromDate != null ? textColor : textColor.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_fromDate != null)
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.close,
                          size: 16,
                          color: accentColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _fromDate = null;
                            _updateHasFilters();
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () => _selectDate(context, false),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(_toDate != null ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.calendar_month_rounded,
                        color: _toDate != null ? accentColor : textColor.withOpacity(0.5),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'filter.to_date_label'.tr(),
                          style: TextStyle(
                            fontSize: 13,
                            color: textColor.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _toDate != null
                              ? DateFormat('EEEE, MMMM d, yyyy').format(_toDate!)
                              : 'filter.select_date'.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: _toDate != null ? FontWeight.w600 : FontWeight.w400,
                            color: _toDate != null ? textColor : textColor.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_toDate != null)
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.close,
                          size: 16,
                          color: accentColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _toDate = null;
                            _updateHasFilters();
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color accentColor) {
    final isSelected = index == 0;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        if (index == 0) {
          _navigateToScreen(HomeScreen(themeNotifier: widget.themeNotifier));
        } else if (index == 1) {
          _navigateToScreen(MyClaimsScreen(themeNotifier: widget.themeNotifier));
        } else if (index == 2) {
          _navigateToScreen(SettingsScreen(themeNotifier: widget.themeNotifier));
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? accentColor : theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? accentColor : theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}