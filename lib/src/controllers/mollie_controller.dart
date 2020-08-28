import 'dart:convert';

import 'package:ecommerce/src/controllers/checkout_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

import '../models/address.dart';
import 'package:mollie/mollie.dart';
import 'package:http/http.dart' as http;

import '../repository/settings_repository.dart' as settingRepo;

class MollieController extends CheckoutController {
  GlobalKey<ScaffoldState> scaffoldKey;
  InAppWebViewController webView;
  String url = "";
  double progress = 0;
  Address deliveryAddress;
  //CheckoutController checkoutController;

  MollieController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }
  @override
  void initState() {
    // final String _apiToken = 'api_token=${userRepo.currentUser.value.apiToken}';
    // final String _deliveryAddress =
    //     'delivery_address_id=${settingRepo.deliveryAddress.value?.id}';
    // url =
    //     '${GlobalConfiguration().getString('base_url')}payments/razorpay/checkout?$_apiToken&$_deliveryAddress';
    client.init('live_nrPPgR7Nq6SDUuABbb6CsWHb7hDQUG');
    listenForCarts();
    setState(() {});

    super.initState();
  }

  MollieOrderRequest initPayments() {
    List<MollieProductRequest> products = new List<MollieProductRequest>();

    double totalAmount = 0.00;
    carts.forEach((_cart) {
      double _price = (_cart.product.price +
          (taxAmount / carts.length +
                  _cart.product.store.deliveryFee / carts.length) /
              _cart.quantity);
      double amount = (_cart.quantity * _price);

      totalAmount += double.parse(amount.toStringAsFixed(2));

      MollieProductRequest productRequest = new MollieProductRequest(
        name: _cart.product.name,
        quantity: _cart.quantity.toInt(),
        vatRate: "0.00",
        productUrl: 'https://shop.lego.com/nl-NL/Bugatti-Chiron-42083',
        imageUrl: 'https://sh-s7-live-s.legocdn.com/is/image//LEGO/42083_alt1?',
        unitPrice: MollieAmount(
          currency: 'EUR',
          value: _price.toStringAsFixed(2),
        ),
        totalAmount: MollieAmount(
          currency: 'EUR',
          value: amount.toStringAsFixed(2),
        ),
        discountAmount: MollieAmount(
          currency: 'EUR',
          value: '0.00',
        ),
        vatAmount: MollieAmount(
          currency: 'EUR',
          value: "0.00",
        ),
      );

      products.add(productRequest);
    });
    MollieOrderRequest o = new MollieOrderRequest(
      amount:
          MollieAmount(value: totalAmount.toStringAsFixed(2), currency: "EUR"),
      orderNumber: "1222",
      redirectUrl: "mollie://payment-return",
      locale: "en_US",
      shippingAddress: new MollieAddress(
        organizationName: 'Mollie B.V.',
        streetAndNumber: 'Keizersgracht 313',
        city: 'Amsterdam',
        region: 'Noord-Holland',
        postalCode: '1234AB',
        country: 'DE',
        title: 'Dhr.',
        givenName: 'Piet',
        familyName: 'Mondriaan',
        email: 'piet@mondriaan.com',
        phone: '+31309202070',
      ),
      billingAddress: new MollieAddress(
        streetAndNumber: 'Keizersgracht 313',
        city: 'Amsterdam',
        region: 'Noord-Holland',
        postalCode: '1234AB',
        country: 'DE',
        givenName: 'Piet',
        familyName: 'Mondriaan',
        email: 'piet@mondriaan.com',
      ),
      products: products,
    );

    print("total : " + totalAmount.toStringAsFixed(2));

    return o;
  }

  Future<String> createOrder() async {
    while (initPayments().amount.value.isEmpty) {}

    print(initPayments().toJson());
    var res = await http.post("https://api.mollie.com/v2/orders",
        headers: client.headers, body: initPayments().toJson());

    var createdOrder = MollieOrderResponse.build(json.decode(res.body));

    return createdOrder.checkoutUrl;
  }
}

class MollieOrderResponse {
  String id;
  String checkoutUrl;

  MollieOrderResponse.build(dynamic data) {
    id = data["id"];

    if (data["_links"].containsKey("checkout")) {
      checkoutUrl = data["_links"]["checkout"]["href"];
    }
  }
}
