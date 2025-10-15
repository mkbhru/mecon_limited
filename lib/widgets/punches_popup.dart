import 'package:flutter/material.dart';
import '../services/attendance_service.dart';

class PunchesPopup extends StatefulWidget {
  const PunchesPopup({super.key});

  @override
  PunchesPopupState createState() => PunchesPopupState();
}

class PunchesPopupState extends State<PunchesPopup> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>>? punches;
  bool isLoading = true;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    );
    fetchPunches();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> fetchPunches() async {
    final data = await ApiService().fetchLatestPunches();
    if (mounted) {
      setState(() {
        punches = data;
        isLoading = false;
      });
      _animationController?.forward();
    }
  }

  String formatDateTime(String? date, String? time) {
    if (date == null || time == null) return "N/A";
    try {
      return "$date $time";
    } catch (e) {
      return "Invalid date";
    }
  }

  String formatTimestamp(String? date, String? time) {
    if (date == null || time == null) return "N/A";
    return "$date | $time";
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Punch Log",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.black87),
                    iconSize: 20,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        )),
                        child: child,
                      ),
                    );
                  },
                  child: isLoading
                      ? Center(
                          key: const ValueKey('loading'),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 800),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.easeInOut,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: child,
                                  );
                                },
                                child: const SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(
                                    color: Colors.blue,
                                    strokeWidth: 3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 600),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.easeInOut,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: child,
                                  );
                                },
                                child: const Text(
                                  "Loading punch data...",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : punches == null || punches!.isEmpty
                          ? Center(
                              key: const ValueKey('empty'),
                              child: Text(
                                "No punches found for today",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            )
                          : FadeTransition(
                              key: const ValueKey('list'),
                              opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: punches!.length,
                                itemBuilder: (context, index) {
                                  final punch = punches![index];

                                  return TweenAnimationBuilder<double>(
                                    duration: Duration(milliseconds: 300 + (index * 50)),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, value, child) {
                                      return Opacity(
                                        opacity: value,
                                        child: Transform.translate(
                                          offset: Offset(0, 20 * (1 - value)),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                        horizontal: 8,
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${index + 1}.'.padLeft(3),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              formatTimestamp(
                                                punch['punchDate'],
                                                punch['punchTime'],
                                              ),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}