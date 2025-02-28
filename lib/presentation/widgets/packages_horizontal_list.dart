import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instawash/configs/configs.dart';
import 'package:instawash/presentation/widgets.dart';

import 'package:instawash/core/constants/strings.dart';

import '../../application/application.dart';

Widget packagesHorizontaList() {
  return BlocBuilder<PackagesBloc, PackagesState>(builder: (context, state) {
    if (state is PackagesLoaded) {
      return ListView.builder(
          itemCount: state.packages.length,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(
            left: AppDimensions.normalize(15),
            right: AppDimensions.normalize(15),
          ),
          itemBuilder: (context, index) {
            return const PackageItem(
              isFromVerticalList: false,
            );
          });
    } else {
      return const LoadingTicker(
        text: AppStrings.loading,
      );
    }
  });
}
