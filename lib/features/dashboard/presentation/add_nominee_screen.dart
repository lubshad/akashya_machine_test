import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme.dart';

class AddNomineeScreen extends StatefulWidget {
  const AddNomineeScreen({super.key});

  @override
  State<AddNomineeScreen> createState() => _AddNomineeScreenState();
}

class _AddNomineeScreenState extends State<AddNomineeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  String? _selectedRelationship;
  String _allocation = '100';

  static const _relationships = [
    'Spouse',
    'Son',
    'Daughter',
    'Father',
    'Mother',
    'Brother',
    'Sister',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.mainGradient,
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        LucideIcons.chevronLeft,
                        color: Colors.white,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Add Nominee',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info banner
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.primaryColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                LucideIcons.info,
                                color: AppTheme.primaryColor,
                                size: 18,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'As per SEBI guidelines, nominee details are mandatory for all investments.',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Nominee Name
                        const Text(
                          'Nominee Name',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: AppTheme.glassDecoration,
                          child: TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Enter full legal name',
                              hintStyle: const TextStyle(
                                color: AppTheme.textSecondary,
                              ),
                              prefixIcon: const Icon(
                                LucideIcons.user,
                                color: AppTheme.primaryColor,
                                size: 18,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              filled: false,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Please enter nominee name'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Relationship
                        const Text(
                          'Relationship',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: AppTheme.glassDecoration,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedRelationship,
                            dropdownColor: const Color(0xFF1E2A3A),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Select relationship',
                              hintStyle: const TextStyle(
                                color: AppTheme.textSecondary,
                              ),
                              prefixIcon: const Icon(
                                LucideIcons.heart,
                                color: AppTheme.primaryColor,
                                size: 18,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              filled: false,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                            ),
                            items: _relationships
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(r),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedRelationship = v),
                            validator: (v) =>
                                v == null ? 'Please select relationship' : null,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Date of Birth
                        const Text(
                          'Date of Birth',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: AppTheme.glassDecoration,
                          child: TextFormField(
                            controller: _dobController,
                            readOnly: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'DD / MM / YYYY',
                              hintStyle: const TextStyle(
                                color: AppTheme.textSecondary,
                              ),
                              prefixIcon: const Icon(
                                LucideIcons.calendar,
                                color: AppTheme.primaryColor,
                                size: 18,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              filled: false,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime(1990),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                builder: (context, child) => Theme(
                                  data: ThemeData.dark().copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: AppTheme.primaryColor,
                                      surface: Color(0xFF1E2A3A),
                                    ),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (picked != null) {
                                _dobController.text =
                                    '${picked.day.toString().padLeft(2, '0')} / '
                                    '${picked.month.toString().padLeft(2, '0')} / '
                                    '${picked.year}';
                              }
                            },
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Please select date of birth'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Allocation %
                        const Text(
                          'Allocation Percentage',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: AppTheme.glassDecoration,
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Icon(
                                  LucideIcons.percent,
                                  color: AppTheme.primaryColor,
                                  size: 18,
                                ),
                              ),
                              Expanded(
                                child: Slider(
                                  value: double.tryParse(_allocation) ?? 100,
                                  min: 1,
                                  max: 100,
                                  divisions: 99,
                                  activeColor: AppTheme.primaryColor,
                                  inactiveColor: Colors.white12,
                                  onChanged: (v) => setState(
                                    () => _allocation = v.toInt().toString(),
                                  ),
                                ),
                              ),
                              Container(
                                width: 56,
                                margin: const EdgeInsets.only(right: 16),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$_allocation%',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Save Button
                        ElevatedButton.icon(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Nominee saved successfully!'),
                                  backgroundColor: AppTheme.primaryColor,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              context.pop();
                            }
                          },
                          icon: const Icon(LucideIcons.check, size: 18),
                          label: const Text('Save Nominee'),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            side: const BorderSide(color: Colors.white24),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
