import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class MainLayout extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final bool showDrawer;
  final Widget? floatingActionButton;

  const MainLayout({
    super.key,
    required this.body,
    required this.title,
    this.actions,
    this.showDrawer = true,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: actions,
        leading: showDrawer
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      drawer: showDrawer ? const AppDrawer() : null,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
