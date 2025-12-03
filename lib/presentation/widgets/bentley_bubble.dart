import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';

class BentleyBubble extends StatelessWidget {
  final String message;
  final bool isLeft; // Position of Bentley (Left or Right)

  const BentleyBubble({
    super.key,
    required this.message,
    this.isLeft = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (isLeft) _buildBentleyAvatar(),
        if (isLeft) const SizedBox(width: 12),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomRight: isLeft ? const Radius.circular(20) : const Radius.circular(4),
                bottomLeft: isLeft ? const Radius.circular(4) : const Radius.circular(20),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: AppTheme.accentColor.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ),
        if (!isLeft) const SizedBox(width: 12),
        if (!isLeft) _buildBentleyAvatar(),
      ],
    );
  }

  Widget _buildBentleyAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SvgPicture.asset(
            'assets/bentley.svg',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

