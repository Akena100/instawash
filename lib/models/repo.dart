import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instawash/models/bills/airtime.dart';
import 'package:instawash/models/bills/electricity.dart';
import 'package:instawash/models/bills/submore.dart';
import 'package:instawash/models/bills/tv.dart';
import 'package:instawash/models/bills/water.dart';
import 'package:instawash/models/car_category.dart';
import 'package:instawash/models/car_category_select.dart';
import 'package:instawash/models/key.dart';
import 'package:instawash/models/more.dart';
import 'package:instawash/models/notifications.dart';
import 'package:instawash/models/selected_more_service.dart';
import 'package:instawash/models/user_subscription.dart';
import 'service.dart';
import 'booking.dart';
import 'sub_service.dart';
import 'more_service.dart';
import 'subscription.dart';
import 'user_model.dart';
import 'subscription_offer.dart';
import 'transactions.dart';

class Repo {
  CollectionReference services =
      FirebaseFirestore.instance.collection('services');
  CollectionReference mores = FirebaseFirestore.instance.collection('mores');
  CollectionReference bookings =
      FirebaseFirestore.instance.collection('bookings');
  CollectionReference subServices =
      FirebaseFirestore.instance.collection('subServices');
  CollectionReference moreServices =
      FirebaseFirestore.instance.collection('moreServices');
  CollectionReference subscriptions =
      FirebaseFirestore.instance.collection('subscriptions');
  CollectionReference transactions =
      FirebaseFirestore.instance.collection('transactions');
  CollectionReference userModels =
      FirebaseFirestore.instance.collection('userModels');
  CollectionReference subscriptionOffers =
      FirebaseFirestore.instance.collection('subscriptionOffers');
  CollectionReference selectedMoreServices =
      FirebaseFirestore.instance.collection('selectedMoreServices');
  CollectionReference keys = FirebaseFirestore.instance.collection('keys');
  CollectionReference airtimes =
      FirebaseFirestore.instance.collection('airtimes');
  CollectionReference electricities =
      FirebaseFirestore.instance.collection('electricities');
  CollectionReference waters = FirebaseFirestore.instance.collection('waters');
  CollectionReference tvs = FirebaseFirestore.instance.collection('tvs');
  CollectionReference submores =
      FirebaseFirestore.instance.collection('subMores');
  CollectionReference carCat =
      FirebaseFirestore.instance.collection('carCategories');
  CollectionReference carCatSelects =
      FirebaseFirestore.instance.collection('carCartSelects');
  CollectionReference userSubscriptions =
      FirebaseFirestore.instance.collection('userSubscriptions');

  CollectionReference notifications =
      FirebaseFirestore.instance.collection('notifications');

  Future<void> addNotification(Notifications notification) async {
    await notifications
        .doc(notification.id)
        .set(notification.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteNotification(Notifications notification) async {
    await notifications.doc(notification.id).delete();
  }

  Future<void> addCarCategorySelect(CarCategorySelect carCategory) async {
    await carCatSelects
        .doc(carCategory.id)
        .set(carCategory.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteCarCategorySelect(CarCategorySelect carCategory) async {
    await carCatSelects.doc(carCategory.id).delete();
  }

  Future<void> addCarCategory(CarCategory carCategory) async {
    await carCat
        .doc(carCategory.id)
        .set(carCategory.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteCarCategory(CarCategory carCategory) async {
    await carCat.doc(carCategory.id).delete();
  }

  Future<void> addService(Service service) async {
    await services
        .doc(service.id)
        .set(service.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteService(Service service) async {
    await services.doc(service.id).delete();
  }

  Future<void> addAirtime(Airtime airtime) async {
    await airtimes
        .doc(airtime.id)
        .set(airtime.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteAirtime(Airtime airtime) async {
    await airtimes.doc(airtime.id).delete();
  }

  Future<void> addElectricity(Electricity electricity) async {
    await electricities
        .doc(electricity.id)
        .set(electricity.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteElectricity(Electricity electricity) async {
    await electricities.doc(electricity.id).delete();
  }

  Future<void> addWater(Water water) async {
    await waters.doc(water.id).set(water.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteWater(Water water) async {
    await waters.doc(water.id).delete();
  }

  Future<void> addTv(TV tv) async {
    await tvs.doc(tv.id).set(tv.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteTv(TV tv) async {
    await tvs.doc(tv.id).delete();
  }

  Future<void> addSub(SubMore subMore) async {
    await submores
        .doc(subMore.id)
        .set(subMore.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteSub(SubMore subMore) async {
    await submores.doc(subMore.id).delete();
  }

  Future<void> addMore(More more) async {
    await mores.doc(more.id).set(more.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteMore(More more) async {
    await mores.doc(more.id).delete();
  }

  Future<void> addBooking(Booking booking) async {
    await bookings
        .doc(booking.id)
        .set(booking.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteBooking(Booking booking) async {
    await bookings.doc(booking.id).delete();
  }

  Future<void> addSelectedMoreService(
      SelectedMoreService selectedMoreService) async {
    await selectedMoreServices
        .doc(selectedMoreService.id)
        .set(selectedMoreService.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteSelectedMoreService(
      SelectedMoreService selectedMoreService) async {
    await selectedMoreServices.doc(selectedMoreService.id).delete();
  }

  Future<List<SelectedMoreService>> getSelectedMoreServicesByBookingId(
      String bookingId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('selectedMoreServices')
          .where('bookingId', isEqualTo: bookingId)
          .get();

      List<SelectedMoreService> selectedMoreServices = querySnapshot.docs
          .map((doc) => SelectedMoreService.fromSnapshot(doc))
          .toList();

      return selectedMoreServices;
    } catch (error) {
      print('Error retrieving selectedMoreServices: $error');
      return [];
    }
  }

  Future<void> addSubService(SubService subService) async {
    await subServices
        .doc(subService.id)
        .set(subService.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteSubService(SubService subService) async {
    await subServices.doc(subService.id).delete();
  }

  Future<void> addMoreService(MoreService moreService) async {
    await moreServices
        .doc(moreService.id)
        .set(moreService.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteMoreService(MoreService moreService) async {
    await moreServices.doc(moreService.id).delete();
  }

  Future<void> addSubscription(Subscription subscription) async {
    await subscriptions
        .doc(subscription.id)
        .set(subscription.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteSubscription(Subscription subscription) async {
    await subscriptions.doc(subscription.id).delete();
  }

  Future<void> addUserSubscription(UserSubscription userSubscription) async {
    await userSubscriptions
        .doc(userSubscription.id)
        .set(userSubscription.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteUserSubscription(UserSubscription userSubscription) async {
    await userSubscriptions.doc(userSubscription.id).delete();
  }

  Future<void> addTransaction(TransactionsRecord transaction) async {
    await transactions
        .doc(transaction.id)
        .set(transaction.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteTransaction(TransactionsRecord transaction) async {
    await transactions.doc(transaction.id).delete();
  }

  Future<void> addUserModel(UserModel userModel) async {
    await userModels
        .doc(userModel.id)
        .set(userModel.toDocument(), SetOptions(merge: true));
  }

  Future<void> deleteUserModel(UserModel userModel) async {
    await userModels.doc(userModel.id).delete();
  }

  Future<void> addSubscriptionOffer(SubscriptionOffer subscriptionOffer) async {
    await subscriptionOffers
        .doc(subscriptionOffer.id)
        .set(subscriptionOffer.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteSubscriptionOffer(
      SubscriptionOffer subscriptionOffer) async {
    await subscriptionOffers.doc(subscriptionOffer.id).delete();
  }

  Future<void> addKey(Key key) async {
    await keys.doc(key.id).set(key.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteKey(Key key) async {
    await keys.doc(key.id).delete();
  }

  getCarCategories() {}
}
