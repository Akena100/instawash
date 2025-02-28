import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instawash/models/service.dart';
import 'package:instawash/presentation/widgets.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:instawash/application/application.dart';
import 'package:instawash/configs/configs.dart';
import 'package:instawash/core/constants/assets.dart';
import 'package:instawash/core/constants/colors.dart';
import 'package:instawash/core/router/app_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PackageItem extends StatelessWidget {
  const PackageItem({
    super.key,
    required this.isFromVerticalList,
  });

  final bool isFromVerticalList;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('services').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<DocumentSnapshot> serviceDocs = snapshot.data!.docs;
        List<Service> services = serviceDocs.map((doc) {
          return Service(
            id: doc['id'],
            name: doc['name'],
            description: doc['description'],
            imageUrl: doc['imageUrl'],
            createDate: doc['createDate'],
          );
        }).toList();

        return _buildPackageItem(context, services);
      },
    );
  }

  Widget _buildPackageItem(BuildContext context, List<Service> services) {
    if (services.isEmpty) {
      return const SizedBox(); // No packages found in Firestore, handle accordingly
    }

    final Service retrievedService = services.first;

    return SizedBox(
      width: AppDimensions.normalize(120),
      child: Padding(
        padding: isFromVerticalList
            ? EdgeInsets.only(bottom: AppDimensions.normalize(9))
            : EdgeInsets.only(right: AppDimensions.normalize(7)),
        child: Stack(
          children: [
            Column(
              children: [
                Space.yf(3.5),
                Stack(
                  children: [
                    Container(
                      height: AppDimensions.normalize(100),
                      width: AppDimensions.normalize(120),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: packageBorderRadius,
                      ),
                    ),
                    Positioned(
                      top: AppDimensions.normalize(48),
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Text(
                            retrievedService.name.toUpperCase(),
                            style: AppText.h3?.copyWith(letterSpacing: 1.7),
                          ),
                          Space.yf(.4),
                          Text(
                            retrievedService.id,
                            style: AppText.b1?.copyWith(
                              color: AppColors.deepTeal,
                            ),
                          ),
                          Space.yf(.6),
                          Text(
                            retrievedService.name.toUpperCase(),
                            style: AppText.h3,
                          ),
                          Space.yf(.6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                AppAssets.percent,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.antiqueRuby,
                                  BlendMode.srcIn,
                                ),
                                height: AppDimensions.normalize(10),
                              ),
                              Space.xf(.3),
                              Text(
                                retrievedService.name,
                                style: AppText.h3?.copyWith(
                                  color: Colors.purple,
                                  decoration: TextDecoration.lineThrough,
                                  decorationThickness:
                                      AppDimensions.normalize(1.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: BlocBuilder<UserBloc, UserState>(
                        builder: (context, userState) {
                          return userState.user.id != ''
                              ? GestureDetector(
                                  onTap: () {
                                    context
                                        .read<FavouritePackagesCubit>()
                                        .toggleFavorite(
                                          userState.user.id,
                                          retrievedService,
                                        );
                                  },
                                  child: BlocBuilder<FavouritePackagesCubit,
                                      FavoritesPackagesState>(
                                    builder: (context, favState) {
                                      if (favState is FavoritePackagesLoaded) {
                                        final isFavorite = favState
                                            .favouritePackages
                                            .any((favouritePackage) =>
                                                favouritePackage.id ==
                                                retrievedService.id);
                                        return LeftFavIconStack(
                                          isFilled: isFavorite,
                                        );
                                      } else {
                                        return LeftFavIconStack(
                                          isFilled: false,
                                        );
                                      }
                                    },
                                  ),
                                )
                              : LeftFavIconStack(
                                  isFilled: false,
                                );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRouter.selectKid,
                            arguments: retrievedService,
                          );
                        },
                        child: Stack(
                          children: [
                            SvgPicture.asset(
                              AppAssets.rightIconRec,
                              colorFilter: const ColorFilter.mode(
                                AppColors.deepTeal,
                                BlendMode.srcIn,
                              ),
                            ),
                            Positioned(
                              right: AppDimensions.normalize(4),
                              top: AppDimensions.normalize(1),
                              bottom: 0,
                              child: SvgPicture.asset(
                                AppAssets.cartWhite,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: AppDimensions.normalize(9),
              child: Image.asset(
                AppAssets.packagesPng,
                width: AppDimensions.normalize(90),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
