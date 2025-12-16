import 'package:flutter/material.dart';
import '../../../../../features/search/presentation/pages/search_screen.dart';

/// Visitor Search Screen
///
/// This screen wraps the shared SearchScreen component
/// to provide search functionality for visitors.
class VisitorSearchScreen extends StatelessWidget {
  const VisitorSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SearchScreen();
  }
}
