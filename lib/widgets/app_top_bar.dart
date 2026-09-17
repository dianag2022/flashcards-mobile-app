import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'ui_bits.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.onNotifications,
    required this.onSignOut,
    this.signingOut = false,
  });

  final VoidCallback onNotifications;
  final VoidCallback onSignOut;
  final bool signingOut;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
      child: Row(
        children: [
          const Spacer(),
          CircularIconButton(
            icon: Icons.notifications_none_rounded,
            onPressed: onNotifications,
          ),
          const SizedBox(width: 10),
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            elevation: 1,
            shadowColor: const Color(0x33000000),
            child: InkWell(
              onTap: signingOut ? null : onSignOut,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: signingOut
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.tealDeep,
                        ),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            size: 18,
                            color: AppColors.tealDeep,
                          )
                
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
