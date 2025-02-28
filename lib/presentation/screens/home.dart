import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';
import 'package:instawash/drawer.dart';
import 'package:instawash/models/sub_service.dart';
import 'package:instawash/presentation/screens/ai_chat.dart';
import 'package:instawash/presentation/screens/sub_details.dart';
import 'package:instawash/presentation/screens/sub_service.dart';
import 'package:instawash/models/service.dart';
import 'package:instawash/core/core.dart';
import 'package:get/get.dart';
import 'package:instawash/configs/configs.dart';
import 'package:instawash/presentation/widgets/my_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:search_page/search_page.dart';
import 'package:instawash/forms/service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPage = 1;
  int packagesCurrentPage = 0;

  List itemsTemp = [];
  int itemLength = 0;
  String fullName = '';
  bool _isConnected = true; // Default to true, assuming there's a connection

  Future<void> _checkInternetConnection() async {
    bool isConnected = await InternetConnectivityService.isConnected();
    setState(() {
      _isConnected = isConnected;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    _fetchDataFromFirestore();
  }

  void _fetchDataFromFirestore() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('subServices').get();
    QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();

    setState(() {
      itemsTemp = querySnapshot.docs
          .map((DocumentSnapshot document) =>
              document.data() as Map<String, dynamic>)
          .toList();
      itemLength = itemsTemp.length;
      fullName = querySnapshot1.docs[0]['fullName'];
    });
  }

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    App.init(context);
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
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.96,
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: AppColors.secondaryColor),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HELLO $fullName !'.toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Text(
                                "Book us Now & Enjoy\nStress free cleaning services at your door step!\n",
                                style: TextStyle(
                                    color: Colors.white,
                                    height: 1.5,
                                    letterSpacing: 1.8,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                              Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.normalize(7),
                                ),
                                child: GestureDetector(
                                  onTap: () => showSearch(
                                    context: context,
                                    delegate: SearchPage(
                                      barTheme: ThemeData(
                                        textTheme: const TextTheme(
                                          bodyLarge:
                                              TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      onQueryUpdate: print,
                                      items: itemsTemp,
                                      searchLabel: 'Search service',
                                      suggestion: const Center(
                                        child: Text(
                                            'Filter item by name, category or description'),
                                      ),
                                      failure: const Center(
                                        child: Text('No item found :('),
                                      ),
                                      filter: (product) => [
                                        product['name'],
                                      ],
                                      builder: (product) => ListTile(
                                        leading: Image.network(
                                          '${product['imageUrl']}',
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.contain,
                                        ),
                                        title: Text(product['name']),
                                        onTap: () => Get.to(() => SubDetails(
                                              serviceId: product['serviceId'],
                                              amount:
                                                  SubService.fromJson(product)
                                                      .price,
                                              subService:
                                                  SubService.fromJson(product),
                                            )),
                                      ),
                                    ),
                                  ),
                                  child: Container(
                                    height: AppDimensions.normalize(22),
                                    width: AppDimensions.normalize(130),
                                    decoration: BoxDecoration(
                                      color: AppColors.bgColor,
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.normalize(7),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: Space.all(.8, .8),
                                          child: const Text(
                                            "Search Here",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        Padding(
                                          padding: Space.all(.8, .8),
                                          child: const Icon(
                                            Icons.search,
                                            color: Colors.purple,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        MyCard(),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppColors.secondaryColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        Padding(
                          padding: Space.hf(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Our Services",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              if (user.email == 'iakena420@gmail.com')
                                ElevatedButton(
                                    onPressed: () {
                                      Get.to(() => const ServiceForm());
                                    },
                                    child: const Text('Add'))
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('services')
                              .orderBy('createDate', descending: false)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              List<Service> services = snapshot.data!.docs
                                  .map((doc) => Service.fromSnapshot(doc))
                                  .toList();

                              return GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: services.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  Service service = services[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Get.to(() => SubServicesPage(
                                          serviceId: service.id));
                                    },
                                    child: SizedBox(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                border: Border.all(
                                                  color: Colors.grey,
                                                  width: 1,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: CachedNetworkImage(
                                                  imageUrl: service.imageUrl,
                                                  placeholder: (context, url) =>
                                                      CupertinoActivityIndicator(),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(Icons.error),
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            service.name,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  // const MoreCard(),
                  Space.yf(2),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Get.to(() => ChatScreen());
              },
              backgroundColor: Colors.black,
              child: Image.asset('assets/robot.gif'),
            ),
          );
  }

  bool x() {
    final u = FirebaseAuth.instance.currentUser;
    if (u != null && u.email == 'iakena420@gmail.com') {
      return true;
    }
    return false;
  }
}
