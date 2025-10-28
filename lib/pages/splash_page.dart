import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _tailSwing;
  late final Animation<double> _bobY;
  late final Animation<double> _orbit;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat(reverse: true);
    _logoScale = Tween<double>(begin: 0.96, end: 1.02).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeInOut)));
    _titleOpacity = CurvedAnimation(parent: _controller, curve: const Interval(0.2, 1.0, curve: Curves.easeIn));
    _tailSwing = Tween<double>(begin: -0.35, end: 0.35).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _bobY = Tween<double>(begin: -6, end: 6).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _orbit = CurvedAnimation(parent: _controller, curve: Curves.linear);
    Future.delayed(const Duration(milliseconds: 1600), () {
      Navigator.pushReplacementNamed(context, '/loginSelect');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PawBackdrop(
        child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.9, -1.0),
            end: Alignment(-0.9, 1.0),
            colors: [
              Color(0xFFFFF0F6),
              Color(0xFFFFF7FB),
            ],
          ),
        ),
          child: Stack(
            children: [
              // Center content with a wagging dog
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _bobY.value),
                          child: ScaleTransition(scale: _logoScale, child: child),
                        );
                      },
                      child: SizedBox(
                        width: 160,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Text('🐕', style: TextStyle(fontSize: 72)),
                            Positioned(
                              right: 30,
                              top: 54,
                              child: AnimatedBuilder(
                                animation: _tailSwing,
                                builder: (context, _) {
                                  return Transform.rotate(
                                    angle: _tailSwing.value,
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width: 24,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: kPrimary.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Orbiting bone
                            AnimatedBuilder(
                              animation: _orbit,
                              builder: (context, _) {
                                final angle = _orbit.value * 2 * 3.1415926535;
                                final radius = 46.0;
                                return Transform.translate(
                                  offset: Offset(radius * math.sin(angle), -radius * math.cos(angle) * 0.6),
                                  child: const Text('🦴', style: TextStyle(fontSize: 22)),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 18),
                    FadeTransition(
                      opacity: _titleOpacity,
                      child: Column(
                        children: [
                          Text('Care Connect',
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text('Connecting caregivers with shelters',
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      ),
                    ),
                  ],
                ),
              ),
              // (Optional) subtle ground shadow under dog
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.36,
                left: MediaQuery.of(context).size.width * 0.5 - 44,
                child: Container(
                  width: 88,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
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
