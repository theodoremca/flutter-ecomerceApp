import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/i18n.dart';
import '../controllers/mollie_controller.dart';
import '../models/route_argument.dart';
import 'package:mollie/mollie.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

// ignore: must_be_immutable
class MolliePaymentWidget extends StatefulWidget {
  RouteArgument routeArgument;

  MolliePaymentWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _MolliePaymentWidgetState createState() => _MolliePaymentWidgetState();
}

class _MolliePaymentWidgetState extends StateMVC<MolliePaymentWidget> {
  MollieController _con;
  String url;

  _MolliePaymentWidgetState() : super(MollieController()) {
    _con = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _con.scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Mollie Payment",
            style: Theme.of(context)
                .textTheme
                .headline6
                .merge(TextStyle(letterSpacing: 1.3)),
          ),
        ),
        body: _loadPaymentScreen());
  }

  Widget _loadPaymentScreen() {
    return FutureBuilder<String>(
      future: _con.createOrder(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          return Stack(
            children: <Widget>[
              InAppWebView(
                initialUrl: snapshot.data,
                initialHeaders: {},
                initialOptions: new InAppWebViewWidgetOptions(
                    androidInAppWebViewOptions:
                        AndroidInAppWebViewOptions(textZoom: 120)),
                onWebViewCreated: (InAppWebViewController controller) {
                  _con.webView = controller;
                },
                onLoadStart: (InAppWebViewController controller, String url) {
                  print("url: " + url);
                  setState(() {
                    _con.url = url;
                  });
                },
                onProgressChanged:
                    (InAppWebViewController controller, int progress) {
                  setState(() {
                    _con.progress = progress / 100;
                  });
                },
              ),
              _con.progress < 1
                  ? SizedBox(
                      height: 3,
                      child: LinearProgressIndicator(
                        value: _con.progress,
                        backgroundColor:
                            Theme.of(context).accentColor.withOpacity(0.2),
                      ),
                    )
                  : SizedBox(),
            ],
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     key: _con.scaffoldKey,
  //     body: MollieCheckout(
  //       style: CheckoutStyle(appBar: AppBar(
  //       backgroundColor: Colors.transparent,
  //       elevation: 0,
  //       centerTitle: true,
  //       title: Text(
  //         "Mollie Payment",
  //         style: Theme.of(context)
  //             .textTheme
  //             .headline6
  //             .merge(TextStyle(letterSpacing: 1.3)),
  //       ),
  //     )) ,
  //       order: _con.initPayments(),
  //       onMethodSelected: (order) {
  //         //_con.createOrder(order);
  //         return  InAppWebView(
  //           initialUrl: _con.url,
  //           initialHeaders: {},
  //           initialOptions: new InAppWebViewWidgetOptions(androidInAppWebViewOptions: AndroidInAppWebViewOptions(textZoom: 120)),
  //           onWebViewCreated: (InAppWebViewController controller) {
  //             _con.webView = controller;
  //           },
  //           onLoadStart: (InAppWebViewController controller, String url) {
  //             setState(() {
  //               _con.url = url;
  //             });
  //             if (url == "${GlobalConfiguration().getString('base_url')}payments/razorpay") {
  //               Navigator.of(context).pushReplacementNamed('/Pages', arguments: 3);
  //             }
  //           },
  //           onProgressChanged: (InAppWebViewController controller, int progress) {
  //             setState(() {
  //               _con.progress = progress / 100;
  //             });
  //           },
  //         ),
  //       },
  //       useCredit: false,
  //       usePaypal: false,
  //       useApplePay: false,
  //       useSofort: false,
  //       useSepa: false,
  //       useIdeal: true,
  //     ),
  //   );
  // }
}
