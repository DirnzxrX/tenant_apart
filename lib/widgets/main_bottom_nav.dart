import 'package:flutter/material.dart';

class MainBottomNav extends StatelessWidget {
  const MainBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_outlined),
          activeIcon: Icon(Icons.grid_view_rounded),
          label: 'Layanan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none_rounded),
          activeIcon: Icon(Icons.notifications_rounded),
          label: 'Notifikasi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profil',
        ),
      ],
    );
  }
}
