// -- show_info_panel.dart ---------------------------------------------------
//
// The top show metadata card displayed above the venue/positions panel.

import 'package:flutter/material.dart';

import '../../database/database.dart';
import '../../repositories/role_contact_repository.dart';
import '../../repositories/show_meta_repository.dart';
import 'playbill_field.dart';
import 'role_panel.dart';
import 'show_field_widgets.dart';

class ShowInfoPanel extends StatelessWidget {
  const ShowInfoPanel({required this.row, required this.repo});

  final ShowMetaData row;
  final ShowMetaRepository repo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amber = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // -- Playbill heading - constrained & centered --------------------
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                PlaybillField(
                  value: row.showName,
                  style: theme.textTheme.headlineLarge!.copyWith(
                    color: amber,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  hint: 'Show Title',
                  autoSize: true,
                  onSave: (v) => repo.updateShowName(row.id, v),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 390),
                  child: PlaybillField(
                    value: row.company,
                    style: theme.textTheme.titleMedium!,
                    hint: 'Production Company',
                    onSave: (v) => repo.updateCompany(row.id, v.isEmpty ? null : v),
                  ),
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 390),
                  child: PlaybillField(
                    value: row.designBusiness,
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: const Color(0xFF6B7280)),
                    hint: 'Design Business',
                    onSave: (v) =>
                        repo.updateDesignBusiness(row.id, v.isEmpty ? null : v),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 28),
        const Divider(height: 1),
        const SizedBox(height: 24),

        // -- Two-column role fields ----------------------------------------
        Row(
          children: [
            Expanded(
              child: RolePanel(
                roleKey: RoleKey.designer,
                customLabel: row.labelDesigner,
                value: row.designer,
                onSaveValue: (v) => repo.updateDesigner(row.id, v),
                onSaveLabel: (v) => repo.updateLabelDesigner(row.id, v),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: RolePanel(
                roleKey: RoleKey.asstDesigner,
                customLabel: row.labelAsstDesigner,
                value: row.asstDesigner,
                onSaveValue: (v) => repo.updateAsstDesigner(row.id, v),
                onSaveLabel: (v) => repo.updateLabelAsstDesigner(row.id, v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: RolePanel(
                roleKey: RoleKey.masterElectrician,
                customLabel: row.labelMasterElectrician,
                value: row.masterElectrician,
                onSaveValue: (v) => repo.updateMasterElectrician(row.id, v),
                onSaveLabel: (v) => repo.updateLabelMasterElectrician(row.id, v),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: RolePanel(
                roleKey: RoleKey.producer,
                customLabel: row.labelProducer,
                value: row.producer,
                onSaveValue: (v) => repo.updateProducer(row.id, v),
                onSaveLabel: (v) => repo.updateLabelProducer(row.id, v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: RolePanel(
                roleKey: RoleKey.asstMasterElectrician,
                customLabel: row.labelAsstMasterElectrician,
                value: row.asstMasterElectrician,
                onSaveValue: (v) => repo.updateAsstMasterElectrician(row.id, v),
                onSaveLabel: (v) => repo.updateLabelAsstMasterElectrician(row.id, v),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: RolePanel(
                roleKey: RoleKey.stageManager,
                customLabel: row.labelStageManager,
                value: row.stageManager,
                onSaveValue: (v) => repo.updateStageManager(row.id, v),
                onSaveLabel: (v) => repo.updateLabelStageManager(row.id, v),
              ),
            ),
          ],
        ),

        const SizedBox(height: 26),
        const Divider(height: 1),
        const SizedBox(height: 12),

        // -- Venue / dates strip -------------------------------------------
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: SimpleField(
                label: 'VENUE',
                value: row.venue,
                onSave: (v) => repo.updateVenue(row.id, v.isEmpty ? null : v),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SimpleField(
                label: 'TECH DATE',
                value: row.techDate,
                onSave: (v) => repo.updateTechDate(row.id, v.isEmpty ? null : v),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SimpleField(
                label: 'OPENING',
                value: row.openingDate,
                onSave: (v) => repo.updateOpeningDate(row.id, v.isEmpty ? null : v),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SimpleField(
                label: 'CLOSING',
                value: row.closingDate,
                onSave: (v) => repo.updateClosingDate(row.id, v.isEmpty ? null : v),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


