import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../theme/app_theme.dart';

/// Colour used for each order status across the admin panel.
Color orderStatusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.placed:
      return AppColors.secondaryText;
    case OrderStatus.processing:
      return AppColors.warning;
    case OrderStatus.shipped:
      return AppColors.primaryBlue;
    case OrderStatus.outForDelivery:
      return const Color(0xFF2BA3C7);
    case OrderStatus.delivered:
      return AppColors.success;
  }
}

String formatMoney(double value) => '\$${value.toStringAsFixed(2)}';

String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

/// Short simulated delay so admin lists show a loading state.
Future<void> adminSimulatedLoad() =>
    Future<void>.delayed(const Duration(milliseconds: 600));

class AdminCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const AdminCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AdminSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!, style: const TextStyle(fontSize: 13)),
          ),
      ],
    );
  }
}

class AdminInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const AdminInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminThumb extends StatelessWidget {
  final String url;
  final double size;

  const AdminThumb({super.key, required this.url, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: size,
        height: size,
        child: url.isEmpty
            ? _placeholder()
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _placeholder(),
              ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.softBlue,
      child: Icon(
        Icons.image_outlined,
        size: size * 0.4,
        color: AppColors.primaryBlue.withValues(alpha: 0.6),
      ),
    );
  }
}

class AdminEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AdminEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.softBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
                height: 1.5,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(160, 46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AdminErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AdminErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.error),
            ),
            const SizedBox(height: 18),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(160, 46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminSkeletonList extends StatefulWidget {
  final int count;
  final double itemHeight;

  const AdminSkeletonList({super.key, this.count = 5, this.itemHeight = 110});

  @override
  State<AdminSkeletonList> createState() => _AdminSkeletonListState();
}

class _AdminSkeletonListState extends State<AdminSkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: widget.count,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => Container(
          height: widget.itemHeight,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
        ),
      ),
    );
  }
}

/// Shows a loading skeleton, then the content. If loading fails, shows a
/// friendly message with a retry action (never a raw exception).
class AdminLoader extends StatefulWidget {
  final Future<void> Function() load;
  final WidgetBuilder builder;
  final double skeletonHeight;

  const AdminLoader({
    super.key,
    required this.load,
    required this.builder,
    this.skeletonHeight = 110,
  });

  @override
  State<AdminLoader> createState() => _AdminLoaderState();
}

class _AdminLoaderState extends State<AdminLoader> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    if (!_loading) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      await widget.load();
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'We could not load this section. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return AdminSkeletonList(itemHeight: widget.skeletonHeight);
    if (_error != null) return AdminErrorState(message: _error!, onRetry: _run);
    return widget.builder(context);
  }
}

Future<bool> showAdminConfirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 14, color: AppColors.secondaryText, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: destructive ? AppColors.error : AppColors.primaryBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

class AdminField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final int maxLines;
  final IconData? prefixIcon;
  final String? prefixText;
  final ValueChanged<String>? onChanged;

  const AdminField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
    this.prefixIcon,
    this.prefixText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.primaryText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: maxLines > 1 ? TextInputAction.newline : textInputAction,
          maxLines: maxLines,
          onChanged: onChanged,
          style: const TextStyle(color: AppColors.primaryText, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            alignLabelWithHint: true,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.secondaryText, size: 20)
                : null,
            prefixText: prefixText,
          ),
        ),
      ],
    );
  }
}
