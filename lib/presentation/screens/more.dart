import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';
import 'package:instawash/core/core.dart';

import 'package:instawash/configs/configs.dart';
import 'package:instawash/drawer.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  bool _isConnected = true;
  Future<void> _checkInternetConnection() async {
    bool isConnected = await InternetConnectivityService.isConnected();
    setState(() {
      _isConnected = isConnected;
    });
  }

  @override
  void initState() {
    _checkInternetConnection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !_isConnected
        ? NoInternetConnectionPage()
        : Scaffold(
            backgroundColor: AppColors.bgColor,
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: AppColors.secondaryColor,
              title: const Text(
                'INSTA WASH MOBILE',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            drawer: const CustomDrawer(),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height / .62,
                    child: Stack(
                      children: [
                        Positioned(
                          top: AppDimensions.normalize(15),
                          child: SizedBox(
                            height: AppDimensions.normalize(1000),
                            width: MediaQuery.sizeOf(context).width,
                            child: GridView.builder(
                              itemCount: 6,
                              padding: Space.hf(),
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: AppDimensions.normalize(9),
                                mainAxisSpacing: AppDimensions.normalize(11),
                                childAspectRatio: .87,
                              ),
                              itemBuilder: (context, index) {
                                return Material(
                                  elevation: 2,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(
                                        AppDimensions.normalize(10)),
                                    topRight: Radius.circular(
                                        AppDimensions.normalize(18)),
                                    bottomRight: Radius.circular(
                                        AppDimensions.normalize(10)),
                                    bottomLeft: Radius.circular(
                                        AppDimensions.normalize(30)),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                        AppRouter.moreScreenTaps[index],
                                        arguments: FirebaseAuth
                                            .instance.currentUser!.uid,
                                      );
                                    },
                                    child: Container(
                                      padding: Space.hf(1.2),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryColor,
                                        border: Border.all(color: Colors.white),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(
                                              AppDimensions.normalize(10)),
                                          topRight: Radius.circular(
                                              AppDimensions.normalize(18)),
                                          bottomRight: Radius.circular(
                                              AppDimensions.normalize(10)),
                                          bottomLeft: Radius.circular(
                                              AppDimensions.normalize(30)),
                                        ),
                                      ),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Space.yf(3.4),
                                            SvgPicture.asset(
                                              AppAssets.moreScreenItems[index],
                                              colorFilter:
                                                  const ColorFilter.mode(
                                                      AppColors.deepTeal,
                                                      BlendMode.srcIn),
                                            ),
                                            Space.yf(),
                                            Text(
                                              AppStrings
                                                  .moreScreenStrings[index],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

extension CutOverflowText on Text {
  Widget cutOverflowText() {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Flexible(
            child: this,
          ),
        ],
      ),
    );
  }
}
