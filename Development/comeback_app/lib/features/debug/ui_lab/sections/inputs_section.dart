import 'package:flutter/material.dart';
import 'package:fossui/fossui.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/lab_titles.dart';

// [COMPONENT] Form inputs. Replaces our deprecated PrimaryButton, custom TextField, custom Chip, custom Switch, and Checkbox.
class InputsSection extends StatefulWidget {
  const InputsSection({super.key});

  @override
  State<InputsSection> createState() => _InputsSectionState();
}

class _InputsSectionState extends State<InputsSection> {
  bool _switchValue = true;
  bool? _checkboxValue = false;
  bool _chipSelected = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // [COMPONENT] FossButton variants — replaces custom PrimaryButton.
        // [TOKEN MAPPING] primary -> colors.primary; ghost -> transparent + primary text.
        const LabSubTitle('FossButton — variants'),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            FossButton(onPressed: () {}, child: const Text('Primary')),
            FossButton(
              variant: FossButtonVariant.secondary,
              onPressed: () {},
              child: const Text('Secondary'),
            ),
            FossButton(
              variant: FossButtonVariant.outline,
              onPressed: () {},
              child: const Text('Outline'),
            ),
            FossButton(
              variant: FossButtonVariant.ghost,
              onPressed: () {},
              child: const Text('Ghost'),
            ),
            FossButton(
              variant: FossButtonVariant.destructive,
              onPressed: () {},
              child: const Text('Destructive'),
            ),
            FossButton(
              variant: FossButtonVariant.link,
              onPressed: () {},
              child: const Text('Link'),
            ),
          ],
        ),

        // [COMPONENT] Sizes.
        const LabSubTitle('FossButton — sizes'),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            FossButton(
              size: FossButtonSize.sm,
              onPressed: () {},
              child: const Text('Small'),
            ),
            FossButton(
              size: FossButtonSize.md,
              onPressed: () {},
              child: const Text('Medium'),
            ),
            FossButton(
              size: FossButtonSize.lg,
              onPressed: () {},
              child: const Text('Large'),
            ),
          ],
        ),

        // [COMPONENT] Loading + disabled states.
        const LabSubTitle('FossButton — states'),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            FossButton(loading: true, onPressed: () {}, child: const Text('Loading')),
            FossButton(onPressed: null, child: const Text('Disabled')),
          ],
        ),

        // [COMPONENT] FossTextField — replaces custom Container+TextField.
        // [TOKEN MAPPING] border -> colors.input; errorText -> colors.destructive; radius -> radii.md.
        const LabSubTitle('FossTextField'),
        const FossTextField(
          label: 'Email',
          hintText: 'you@example.com',
          helperText: 'We never share your email.',
        ),
        const SizedBox(height: AppSpacing.sm),
        const FossTextField(
          label: 'Username',
          hintText: 'deevanshu_guru',
          errorText: 'Username already taken.',
        ),

        // [COMPONENT] FossChip — replaces custom _buildChip.
        const LabSubTitle('FossChip'),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            const FossChip(label: Text('Default')),
            const FossChip(
              label: Text('Outline'),
              variant: FossChipVariant.outline,
            ),
            FossChip(
              label: const Text('Selected'),
              selected: _chipSelected,
              onSelected: (v) => setState(() => _chipSelected = v),
            ),
            FossChip(label: const Text('Removable'), onRemove: () {}),
          ],
        ),

        // [COMPONENT] FossSwitch — replaces custom SwitchListTile.
        const LabSubTitle('FossSwitch'),
        Row(
          children: [
            FossSwitch(
              value: _switchValue,
              onChanged: (v) => setState(() => _switchValue = v),
              semanticLabel: 'Developer mode',
            ),
            const SizedBox(width: AppSpacing.sm),
            FossText(_switchValue ? 'On' : 'Off', size: FossTextSize.sm),
          ],
        ),

        // [COMPONENT] FossCheckbox — tristate.
        const LabSubTitle('FossCheckbox'),
        FossCheckbox(
          value: _checkboxValue,
          label: 'Accept terms and conditions',
          onChanged: (v) => setState(() => _checkboxValue = v),
        ),
      ],
    );
  }
}