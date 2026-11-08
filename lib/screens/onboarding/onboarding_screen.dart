import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/branded_lottie.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish({required String route}) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await markOnboardingCompleted(prefs);
    if (mounted) context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = [
      (
        title: l10n.onboardingTitle1,
        body: l10n.onboardingBody1,
        asset: 'assets/lottie/onboarding_1.json',
      ),
      (
        title: l10n.onboardingTitle2,
        body: l10n.onboardingBody2,
        asset: 'assets/lottie/onboarding_2.json',
      ),
      (
        title: l10n.onboardingTitle3,
        body: l10n.onboardingBody3,
        asset: 'assets/lottie/onboarding_3.json',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => _finish(route: '/welcome'),
                child: Text(l10n.skip),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BrandedLottie(
                              asset: page.asset,
                              height: (constraints.maxHeight * 0.45).clamp(
                                96.0,
                                200.0,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              page.title,
                              style: Theme.of(context).textTheme.headlineMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              page.body,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_page < pages.length - 1) {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOut,
                          );
                        } else {
                          _finish(route: '/signup');
                        }
                      },
                      child: Text(
                        _page < pages.length - 1
                            ? l10n.next
                            : l10n.createAccount,
                      ),
                    ),
                  ),
                  if (_page == pages.length - 1) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _finish(route: '/login'),
                      child: Text(l10n.alreadyHaveAccount),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
