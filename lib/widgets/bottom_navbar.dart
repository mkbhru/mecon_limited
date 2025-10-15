import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final bool isAdmin;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTabSelected,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    // Build items list dynamically based on admin status
    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: "Home",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.notifications),
        label: "Notifications",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.note),
        label: "Notes",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.chat),
        label: "Ai Chat",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: "Settings",
      ),
    ];

    // Add admin tab if user is admin
    if (widget.isAdmin) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: "Admin",
        ),
      );
    }

    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: widget.onTabSelected,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: widget.isAdmin && widget.currentIndex == items.length - 1
          ? Colors.red // Red color when admin tab is selected
          : Colors.blue, // Blue for other tabs
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: items,
    );
  }
}
