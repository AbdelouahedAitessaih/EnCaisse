import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Subjects for [SpotIllustration], one per place the app needs a picture.
enum SpotKind { caisse, audit, invite, groups, movements, inbox, success }

/// Flat teal/coral spot illustration: a card carrying the subject's icon on a
/// soft disc, with two small chips that drift gently. No gradients, no
/// shadows — hairlines separate surfaces, matching the rest of the UI.
class SpotIllustration extends StatefulWidget {
  const SpotIllustration({
    super.key,
    required this.kind,
    this.size = 180,
    this.animate = true,
  });

  final SpotKind kind;
  final double size;
  final bool animate;

  @override
  State<SpotIllustration> createState() => _SpotIllustrationState();
}

class _SpotIllustrationState extends State<SpotIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!widget.animate || reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tones = context.semantic;
    final scheme = Theme.of(context).colorScheme;
    final spec = _specs[widget.kind]!;
    final s = widget.size;
    final card = s * 0.46;
    final chip = s * 0.22;

    return Semantics(
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: s,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = Curves.easeOutCubic.transform(_controller.value);
            final drift = (1 - t) * s * 0.08;
            final pop = widget.kind == SpotKind.success
                ? Curves.easeOutBack.transform(_controller.value)
                : 0.9 + 0.1 * t;
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: s * 0.8,
                  height: s * 0.8,
                  decoration: BoxDecoration(
                    color: tones.positiveSurface,
                    shape: BoxShape.circle,
                  ),
                ),
                Transform.scale(
                  scale: pop,
                  child: Container(
                    width: card,
                    height: card,
                    decoration: BoxDecoration(
                      color: spec.filled ? tones.positive : scheme.surface,
                      borderRadius: BorderRadius.circular(card * 0.28),
                      border: spec.filled
                          ? null
                          : Border.all(color: tones.neutralBorder),
                    ),
                    child: Icon(
                      spec.icon,
                      size: card * 0.52,
                      color: spec.filled ? scheme.onPrimary : tones.positive,
                    ),
                  ),
                ),
                if (spec.first != null)
                  Positioned(
                    left: s * 0.1,
                    top: s * 0.16 + drift,
                    child: Opacity(
                      opacity: t,
                      child: _Chip(
                        icon: spec.first!,
                        size: chip,
                        background: scheme.surface,
                        border: tones.neutralBorder,
                        color: tones.positive,
                      ),
                    ),
                  ),
                if (spec.second != null)
                  Positioned(
                    right: s * 0.08,
                    bottom: s * 0.14 - drift,
                    child: Opacity(
                      opacity: t,
                      child: _Chip(
                        icon: spec.second!,
                        size: chip,
                        background: tones.negativeSurface,
                        border: tones.negativeSurface,
                        color: tones.negative,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.size,
    required this.background,
    required this.border,
    required this.color,
  });

  final IconData icon;
  final double size;
  final Color background;
  final Color border;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: border),
      ),
      child: Icon(icon, size: size * 0.55, color: color),
    );
  }
}

class _Spec {
  const _Spec(this.icon, {this.first, this.second, this.filled = false});

  final IconData icon;
  final IconData? first;
  final IconData? second;
  final bool filled;
}

const _specs = <SpotKind, _Spec>{
  SpotKind.caisse: _Spec(
    Icons.account_balance_wallet_rounded,
    first: Icons.south_west_rounded,
    second: Icons.north_east_rounded,
  ),
  SpotKind.audit: _Spec(
    Icons.receipt_long_rounded,
    first: Icons.history_rounded,
    second: Icons.verified_user_rounded,
  ),
  SpotKind.invite: _Spec(
    Icons.vpn_key_rounded,
    first: Icons.person_add_alt_1_rounded,
    second: Icons.share_rounded,
  ),
  SpotKind.groups: _Spec(
    Icons.groups_rounded,
    first: Icons.add_rounded,
    second: Icons.savings_rounded,
  ),
  SpotKind.movements: _Spec(
    Icons.swap_vert_rounded,
    first: Icons.add_rounded,
    second: Icons.remove_rounded,
  ),
  SpotKind.inbox: _Spec(
    Icons.notifications_none_rounded,
    first: Icons.done_all_rounded,
    second: Icons.schedule_rounded,
  ),
  SpotKind.success: _Spec(Icons.check_rounded, filled: true),
};
