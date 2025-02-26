import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instawash/presentation/widgets.dart';

import 'package:instawash/core/constants/strings.dart';

import '../../application/application.dart';

Widget packagesList() {
  return BlocBuilder<PackagesBloc, PackagesState>(builder: (context, state) {
    if (state is PackagesLoaded) {
      return Column(
        children: List.generate(
          state.packages.length,
          // Number of PackageItem widgets
          (index) => const PackageItem(
            isFromVerticalList: true,
          ),
        ),
      );
    } else {
      return const LoadingTicker(
        text: AppStrings.loading,
      );
    }
  });
}
