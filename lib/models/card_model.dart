class CardModel {
  final String id;
  final String name;
  final String netCharge;
  final String units;
  final String duration;
  final String productId;

  CardModel({
    required this.id,
    required this.name,
    required this.netCharge,
    required this.units,
    required this.duration,
    required this.productId,
  });

  static List<CardModel> getAll() => [
    // فكة
    CardModel(id: '1',  name: 'فكة 2.5',  netCharge: '2.50',  units: '45 وحدة + 20 واتساب', duration: 'يوم واحد',  productId: 'Fakka_2.5_Unite'),
    CardModel(id: '2',  name: 'فكة 4.25', netCharge: '4.25',  units: '190 وحدة/ميجا',      duration: 'يوم واحد',  productId: 'Fakka_4.25_Unite'),
    CardModel(id: '3',  name: 'فكة 5',    netCharge: '5.00',  units: '80 وحدة/ميجا',       duration: 'يوم واحد',  productId: 'Fakka_5_Unite'),
    CardModel(id: '4',  name: 'فكة 9',    netCharge: '9.00',  units: '400 وحدة + 50 واتساب', duration: '4 أيام',    productId: 'Fakka_9_Unite'),
    CardModel(id: '5',  name: 'فكة 11.5', netCharge: '11.50', units: '450 وحدة/ميجا',      duration: '7 أيام',    productId: 'Fakka_11.5_Unite'),
    CardModel(id: '6',  name: 'فكة 13.5', netCharge: '13.50', units: '625 وحدة/ميجا',      duration: '7 أيام',    productId: 'Fakka_13.5_Unite'),
    CardModel(id: '7',  name: 'فكة 17.5', netCharge: '17.50', units: '650 وحدة/ميجا',      duration: '10 أيام',   productId: 'Fakka_17.5_Unite'),
    CardModel(id: '8',  name: 'فكة 20',   netCharge: '20.00', units: '750 وحدة/ميجا',      duration: '10 أيام',   productId: 'Fakka_20_Unite'),
    // مارد
    CardModel(id: '9',  name: 'مارد 10 دقايق',   netCharge: '10.00', units: '10 دقايق',   duration: 'مارد', productId: 'Mared_10_Minuts'),
    CardModel(id: '10', name: 'مارد 10 فليكس',   netCharge: '10.00', units: '10 فليكس',   duration: 'مارد', productId: 'Mared_10_Flexs'),
    CardModel(id: '11', name: 'مارد 10 سوشيال',  netCharge: '10.00', units: '10 سوشيال',  duration: 'مارد', productId: 'Mared_10_Social'),
  ];
}
