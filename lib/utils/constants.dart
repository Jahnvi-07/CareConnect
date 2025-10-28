import 'package:flutter/material.dart';
import 'dart:math' as math;

const Color kPrimary = Color(0xFFFF5A8F); // pink primary
const Color kAccent = Color(0xFFFFF7FA); // lightest pink background
const double kRadius = 16.0;

// Paw backdrop painter for playful background accents
class PawBackdrop extends StatefulWidget {
  final Widget child;
  final bool animate;
  final Duration duration;
  const PawBackdrop({super.key, required this.child, this.animate = true, this.duration = const Duration(seconds: 8)});

  @override
  State<PawBackdrop> createState() => _PawBackdropState();
}

class _PawBackdropState extends State<PawBackdrop> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant PawBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) {
      if (widget.animate) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _AnimatedPawPainter(progress: _controller.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _AnimatedPawPainter extends CustomPainter {
  final double progress; // 0..1
  _AnimatedPawPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = const Color(0xFFFFE4EC);
    final paint = Paint()..style = PaintingStyle.fill;

    // subtle drift on a lissajous-like path
    double dx(int i) => (i.isEven ? 1 : -1) * 6 * (0.5 - (progress));
    double dy(int i) => (i % 3 == 0 ? 1 : -1) * 4 * (0.5 - (0.5 * (1 - (progress - 0.5).abs() * 2)));

    final positions = <Offset>[
      Offset(size.width * 0.8, size.height * 0.15),
      Offset(size.width * 0.9, size.height * 0.28),
      Offset(size.width * 0.75, size.height * 0.3),
      Offset(size.width * 0.2, size.height * 0.85),
      Offset(size.width * 0.1, size.height * 0.72),
    ];
    final radii = <double>[42, 22, 26, 48, 24];

    for (int i = 0; i < positions.length; i++) {
      final t = (progress + i * 0.12) % 1.0;
      final alpha = (0.55 + 0.35 * (0.5 + 0.5 * MathUtils.cos2Pi(t))).clamp(0.0, 1.0);
      paint.color = baseColor.withOpacity(alpha);
      final offset = positions[i].translate(dx(i), dy(i));
      canvas.drawCircle(offset, radii[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedPawPainter oldDelegate) => oldDelegate.progress != progress;
}

class MathUtils {
  static double cos2Pi(double t) {
    // approximate cos(2*pi*t) with a simple Taylor-friendly variant via Flutter's lerpDouble is overkill
    // using Dart's math cos
    return math.cos(2 * math.pi * t);
  }
}

// Dummy data
final List<Map<String, String>> dummyCaregivers = [
  {
    'name': 'Asha Patel',
    'skill': 'Elderly Care',
    'phone': '+91 98xxxxxxx01',
    'location': 'Pune',
  },
  {
    'name': 'Rahul Verma',
    'skill': 'Physiotherapy Assistant',
    'phone': '+91 98xxxxxxx02',
    'location': 'Mumbai',
  },
  {
    'name': 'Sana Khan',
    'skill': 'Childcare',
    'phone': '+91 98xxxxxxx03',
    'location': 'Bengaluru',
  },
];

final List<Map<String, String>> dummyShelters = [
  {
    'name': 'Hope Shelter',
    'capacity': '20 beds',
    'contact': '+91 98xxxxxxx11',
    'location': 'Pune',
  },
  {
    'name': 'Safe Haven',
    'capacity': '12 beds',
    'contact': '+91 98xxxxxxx12',
    'location': 'Mumbai',
  },
];

// Dummy organisations with basic payment info (demo only)
final List<Map<String, String>> dummyOrganisations = [
  {
    'name': 'Mumbai Paws Shelter',
    'category': 'Dog Shelter',
    'city': 'Mumbai',
    'address': 'Sector 12, Navi Mumbai, MH',
    'phone': '+91 98xxxxxxx21',
    'upiId': 'mumbaipaws@upi',
    'payee': 'Mumbai Paws',
    'suggestedAmount': '500',
    'description': 'Rescuing and caring for stray dogs across Mumbai.',
  },
  {
    'name': 'Hope Orphanage',
    'category': 'Orphanage',
    'city': 'Pune',
    'address': 'MG Road, Camp, Pune, MH',
    'phone': '+91 98xxxxxxx22',
    'upiId': 'hopeorphanage@upi',
    'payee': 'Hope Orphanage',
    'suggestedAmount': '300',
    'description': 'Providing shelter and education for children in need.',
  },
  {
    'name': 'Kind Hearts Foundation',
    'category': 'NGO',
    'city': 'Bengaluru',
    'address': 'Koramangala 5th Block, BLR',
    'phone': '+91 98xxxxxxx23',
    'upiId': 'kindhearts@upi',
    'payee': 'Kind Hearts',
    'suggestedAmount': '750',
    'description': 'Supports food drives and medical aid for the homeless.',
  },
];
