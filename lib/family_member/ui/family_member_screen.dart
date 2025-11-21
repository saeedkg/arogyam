import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/ui/app_colors.dart';
import '../../_shared/patient/current_patient_controller.dart';
import '../../_shared/patient/current_patient.dart';
import '../controller/family_member_controller.dart';
import '../entities/FamilyMember.dart';
import 'add_family_member_sheet.dart';

class FamilyMembersBottomSheet extends StatefulWidget {
  const FamilyMembersBottomSheet({super.key});

  @override
  State<FamilyMembersBottomSheet> createState() =>
      _FamilyMembersBottomSheetState();
}

class _FamilyMembersBottomSheetState extends State<FamilyMembersBottomSheet> {
  final c = Get.put(FamilyMemberController());
  final currentPatientController = Get.put(CurrentPatientController());
  FamilyMember? selectedMember;

  @override
  void initState() {
    super.initState();
    // Set initially selected member based on current patient
    _setInitialSelection();
  }

  void _setInitialSelection() {
    final currentId = currentPatientController.current.value?.id;
    if (currentId != null && c.members.isNotEmpty) {
      selectedMember = c.members.firstWhereOrNull((m) => m.id == currentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.75;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Handle Bar ---
              Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(top: 12, bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              // --- Header Row ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Select Patient',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close_rounded),
                      color: Colors.grey.shade600,
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Divider(height: 16),
              ),

              // --- Content ---
              Expanded(
                child: Obx(() {
                  if (c.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (c.members.isEmpty) {
                    return _EmptyState(onAdd: _openAddMember);
                  }

                  // Set initial selection when members are loaded
                  if (selectedMember == null && c.members.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _setInitialSelection();
                      setState(() {});
                    });
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    itemBuilder: (_, i) {
                      final m = c.members[i];
                      final isCurrentPatient =
                          currentPatientController.current.value?.id == m.id;
                      final isPrimary = m.isPrimary ?? false;
                      final isSelected = selectedMember?.id == m.id;

                      return _FamilyCard(
                        name: m.name,
                        relation: m.relation,
                        dob: m.dateOfBirth,
                        isSelected: isSelected,
                        isPrimary: isPrimary,
                        isCurrentPatient: isCurrentPatient,
                        onTap: () {
                          setState(() {
                            selectedMember = m;
                          });
                        },
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: c.members.length,
                  );
                }),
              ),

              // --- Bottom Action Buttons ---
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Add Button
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: _openAddMember,
                        icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                        label: const Text(
                          'Add',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryGreen,
                          side: const BorderSide(
                            color: AppColors.primaryGreen,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Choose Button
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: selectedMember != null ? _handleChoose : null,
                        icon: const Icon(Icons.check_circle_rounded, size: 20),
                        label: const Text(
                          'Choose Patient',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade500,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleChoose() {
    if (selectedMember != null) {
      final isCurrentPatient =
          currentPatientController.current.value?.id == selectedMember!.id;
      
      if (!isCurrentPatient) {
        _handleMemberSelection(selectedMember!, currentPatientController);
      }
      // Return the patient ID
      Get.back(result: selectedMember!.id);
    }
  }

  void _openAddMember() {
    Get.bottomSheet(
      const AddPatientSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  void _handleMemberSelection(
      FamilyMember selectedMember, CurrentPatientController controller) {
    final CurrentPatient currentPatient = CurrentPatient(
      id: selectedMember.id,
      name: selectedMember.name,
      phone: selectedMember.dateOfBirth,
      dateOfBirth: selectedMember.dateOfBirth,
      //isPrimary: selectedMember.isPrimary ?? false,
    );

    controller.setCurrentPatient(currentPatient);
  }
}

// ------------------ EMPTY STATE ------------------

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.group_rounded,
                  color: AppColors.primaryGreen, size: 38),
            ),
            const SizedBox(height: 14),
            const Text(
              'No Family Members Yet',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add a member to book appointments on their behalf.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text(
                'Add Member',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: const BorderSide(color: AppColors.primaryGreen, width: 1.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------ FAMILY CARD ------------------

class _FamilyCard extends StatelessWidget {
  final String name;
  final String relation;
  final String dob;
  final bool isSelected;
  final bool isPrimary;
  final bool isCurrentPatient;
  final VoidCallback onTap;

  const _FamilyCard({
    required this.name,
    required this.relation,
    required this.dob,
    required this.onTap,
    this.isSelected = false,
    this.isPrimary = false,
    this.isCurrentPatient = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color:
        isSelected ? AppColors.primaryGreen.withValues(alpha: 0.08) : Colors.white,
        border: Border.all(
          color:
          isSelected ? AppColors.primaryGreen : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        splashColor: AppColors.primaryGreen.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                    AppColors.primaryGreen.withValues(alpha: isSelected ? 0.2 : 0.1),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.check_rounded,
                            color: Colors.white, size: 11),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Text Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15.5,
                              color: isSelected
                                  ? AppColors.primaryGreen
                                  : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (isPrimary)
                          const _Tag(label: 'Primary', color: Colors.orangeAccent),
                        if (isCurrentPatient)
                          const _Tag(
                            label: 'Current',
                            color: AppColors.primaryGreen,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$relation • $dob',
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primaryGreen.withValues(alpha: 0.8)
                            : Colors.grey.shade600,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                )
              else
                Icon(Icons.radio_button_unchecked,
                    color: Colors.grey.shade300, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
