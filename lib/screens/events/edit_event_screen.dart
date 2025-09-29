import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/constants/text_styles.dart';
import '../../widgets/animations/confetti_animation.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/gradient_background.dart';

class EditEventScreen extends StatefulWidget {
  final String eventId;

  const EditEventScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxAttendeesController = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  EventCategory _selectedCategory = EventCategory.meetup;
  bool _isLoading = false;
  EventModel? _event;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadEventData();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  void _loadEventData() {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    _event = eventProvider.events.firstWhere((e) => e.id == widget.eventId);
    
    if (_event != null) {
      _titleController.text = _event!.title;
      _descriptionController.text = _event!.description;
      _locationController.text = _event!.location;
      _maxAttendeesController.text = _event!.maxAttendees.toString();
      _selectedDate = _event!.date;
      _selectedCategory = _event!.category;
      
      // Parse time string back to TimeOfDay
      final timeParts = _event!.time.split(':');
      if (timeParts.length >= 2) {
        final hour = int.tryParse(timeParts[0]) ?? 0;
        final minute = int.tryParse(timeParts[1].split(' ')[0]) ?? 0;
        _selectedTime = TimeOfDay(hour: hour, minute: minute);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxAttendeesController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        type: GradientType.secondary,
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppDimensions.radiusXL),
                        topRight: Radius.circular(AppDimensions.radiusXL),
                      ),
                    ),
                    child: _buildEventForm(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.close, color: AppColors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Event',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Update your event details',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Basic Information', Icons.info_outline),
            const SizedBox(height: AppDimensions.spaceMD),

            // Event Title
            CustomTextField(
              controller: _titleController,
              label: 'Event Title',
              hint: 'Enter a catchy title for your event',
              prefixIcon: Icons.title,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter event title';
                }
                if (value.length < AppConstants.minEventTitleLength) {
                  return 'Title must be at least ${AppConstants.minEventTitleLength} characters';
                }
                return null;
              },
            ),

            const SizedBox(height: AppDimensions.spaceMD),

            // Event Description
            CustomTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Describe what attendees can expect...',
              prefixIcon: Icons.description,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter event description';
                }
                if (value.length < AppConstants.minEventDescriptionLength) {
                  return 'Description must be at least ${AppConstants.minEventDescriptionLength} characters';
                }
                return null;
              },
            ),

            const SizedBox(height: AppDimensions.spaceLG),

            _buildSectionHeader('Event Details', Icons.event),
            const SizedBox(height: AppDimensions.spaceMD),

            // Category Selection
            _buildCategorySelection(),

            const SizedBox(height: AppDimensions.spaceMD),

            // Date and Time Selection
            Row(
              children: [
                Expanded(child: _buildDatePicker()),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(child: _buildTimePicker()),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceMD),

            // Location
            CustomTextField(
              controller: _locationController,
              label: 'Location',
              hint: 'Where will the event take place?',
              prefixIcon: Icons.location_on,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter event location';
                }
                return null;
              },
            ),

            const SizedBox(height: AppDimensions.spaceMD),

            // Max Attendees
            CustomTextField(
              controller: _maxAttendeesController,
              label: 'Maximum Attendees',
              hint: 'How many people can attend?',
              prefixIcon: Icons.people,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter maximum attendees';
                }
                final attendees = int.tryParse(value);
                if (attendees == null || attendees < 1) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),

            const SizedBox(height: AppDimensions.spaceXL),

            // Submit Button
            CustomButton(
              text: 'Update Event',
              type: ButtonType.gradient,
              size: ButtonSize.large,
              isFullWidth: true,
              isLoading: _isLoading,
              gradientColors: AppColors.secondaryGradient,
              icon: Icons.update,
              onPressed: _submitForm,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.secondaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.white, size: 20),
        ),
        const SizedBox(width: AppDimensions.spaceMD),
        Text(
          title,
          style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Category',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSM),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: EventCategory.values.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: _getCategoryGradient(category),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : AppColors.grey100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppColors.grey300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: 18,
                      color: isSelected ? AppColors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getCategoryName(category),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected ? AppColors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey300),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: AppColors.secondary),
                const SizedBox(width: 8),
                Text(
                  _selectedDate != null
                      ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                      : 'Select date',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _selectedDate != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey300),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 18, color: AppColors.secondary),
                const SizedBox(width: 8),
                Text(
                  _selectedTime != null
                      ? _selectedTime!.format(context)
                      : 'Select time',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _selectedTime != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.secondary,
              surface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.secondary,
              surface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an event date')),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an event time')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      // Convert TimeOfDay to string
      final timeString = _selectedTime!.format(context);

      // Create updated event model
      final updatedEvent = _event!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate!,
        time: timeString,
        location: _locationController.text.trim(),
        category: _selectedCategory,
        maxAttendees: int.parse(_maxAttendeesController.text),
        updatedAt: DateTime.now(),
      );

      final success = await eventProvider.updateEvent(updatedEvent);

      if (success && mounted) {
        // Show success dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const ConfettiSuccessDialog(
            title: 'Event Updated! ✨',
            message: 'Your event has been successfully updated!',
          ),
        );

        Navigator.of(context).pop(); // Return to previous screen
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(eventProvider.errorMessage ?? 'Failed to update event'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Color> _getCategoryGradient(EventCategory category) {
    switch (category) {
      case EventCategory.workshop:
        return [AppColors.workshopColor, AppColors.workshopColor.withOpacity(0.8)];
      case EventCategory.meetup:
        return [AppColors.meetupColor, AppColors.meetupColor.withOpacity(0.8)];
      case EventCategory.hackathon:
        return [AppColors.hackathonColor, AppColors.hackathonColor.withOpacity(0.8)];
      case EventCategory.conference:
        return [AppColors.conferenceColor, AppColors.conferenceColor.withOpacity(0.8)];
      case EventCategory.seminar:
        return [AppColors.seminarColor, AppColors.seminarColor.withOpacity(0.8)];
    }
  }

  IconData _getCategoryIcon(EventCategory category) {
    switch (category) {
      case EventCategory.workshop:
        return Icons.build;
      case EventCategory.meetup:
        return Icons.people;
      case EventCategory.hackathon:
        return Icons.code;
      case EventCategory.conference:
        return Icons.mic;
      case EventCategory.seminar:
        return Icons.school;
    }
  }

  String _getCategoryName(EventCategory category) {
    return category.name[0].toUpperCase() + category.name.substring(1);
  }
}
