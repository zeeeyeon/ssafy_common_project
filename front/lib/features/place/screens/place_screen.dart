import 'package:flutter/material.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';
import 'package:kkulkkulk/features/place/components/place_form.dart';

class PlaceScreen extends StatelessWidget {
  const PlaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '장소'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PlaceForm(),
      ),
    );
  }
}
