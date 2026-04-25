import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedSubjectText extends StatefulWidget {
  const AnimatedSubjectText({super.key});

  @override
  State<AnimatedSubjectText> createState() => _AnimatedSubjectTextState();
}

class _AnimatedSubjectTextState extends State<AnimatedSubjectText>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _subjects = [
    {'label': 'CSE?', 'color': const Color(0xFF9B30FF)},
    {'label': 'Physics?', 'color': const Color(0xFF30AAFF)},
    {'label': 'Chemistry?', 'color': const Color(0xFF30FFB0)},
    {'label': 'EEE?', 'color': const Color(0xFFFFB030)},
    {'label': 'English?', 'color': const Color(0xFFFF6030)},
    {'label': 'Maths?', 'color': const Color(0xFFFF30AA)},
  ];

  int _currentIndex = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      _animateNext();
    });
  }

  void _animateNext() async {
    await _controller.reverse();
    if (mounted) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _subjects.length;
      });
      _controller.forward();
    }
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subject = _subjects[_currentIndex];
    final color = subject['color'] as Color;
    final label = subject['label'] as String;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ).createShader(bounds),
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
