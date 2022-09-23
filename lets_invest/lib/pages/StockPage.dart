// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_invest/api/BuilderAPI.dart';
import 'package:lets_invest/api/WebsocketAPI.dart';

import '../data/Crypto.dart';
import '../data/Stock.dart';

class StockPage extends StatefulWidget {
  @override
  State<StockPage> createState() => _StockPageState();

  static List<FlSpot> generateSampleData() {
    final List<FlSpot> result = [];
    final numPoints = 35;
    final maxY = 6;

    double prev = 0;

    for (int i = 0; i < numPoints; i++) {
      final next = prev +
          Random().nextInt(3).toDouble() % -1000 * i +
          Random().nextDouble() * maxY / 10;

      prev = next;

      result.add(
        FlSpot(i.toDouble(), next),
      );
    }

    return result;
  }
}

class _StockPageState extends State<StockPage> {
  static WebsocketAPI websocketAPI = WebsocketAPI();
  String portfolioValue = "";

  @override
  void initState() {
    super.initState();
    websocketAPI.initializeConnection();
    websocketAPI.sendMessageToWebSocket('sub ' +
        WebsocketAPI.randomNumber().toString() +
        ' {"type":"ticker","id":"XF000BTC0017.BHS"}');
    websocketAPI.sendMessageToWebSocket('sub ' +
        WebsocketAPI.randomNumber().toString() +
        ' {"type":"ticker","id":"XF000ETH0019.BHS"}');
    websocketAPI.sendMessageToWebSocket('sub ' +
        WebsocketAPI.randomNumber().toString() +
        ' {"type":"ticker","id":"US0378331005.LSX"}');
    websocketAPI.sendMessageToWebSocket('sub ' +
        WebsocketAPI.randomNumber().toString() +
        ' {"type":"ticker","id":"IE00B4L5Y983.LSX"}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 6, 6, 6),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 50.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 25.w),
                  child: BuilderAPI.buildText(
                      text: portfolioValue,
                      color: Colors.white,
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 25.w),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_upward,
                            color: Colors.green, size: 12.sp),
                        SizedBox(width: 5.w),
                        BuilderAPI.buildText(
                            text: "0,32€",
                            color: Colors.green,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold),
                        SizedBox(width: 5.w),
                        BuilderAPI.buildText(
                            text: "(0,15%)",
                            color: Colors.green,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold),
                        SizedBox(width: 10.w),
                        BuilderAPI.buildTranslatedText(context, "Heute",
                            Colors.grey, 12.sp, FontWeight.bold)
                      ],
                    )),
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h, left: 25.w),
                  child: BuilderAPI.buildText(
                      text: "Investments",
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold),
                ),
                StreamBuilder(
                    stream: WebsocketAPI.getCryptoValueStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return BuilderAPI.buildSearchSkeleton();
                      } else if (snapshot.hasData) {
                        List<Crypto> cryptoList =
                            (snapshot.data as List<Crypto>);
                        return SizedBox(
                          height: 300.h,
                          child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: cryptoList.length,
                              itemBuilder: (context, index) {
                                Crypto crypto = cryptoList[index];
                                return Row(
                                  children: [
                                    BuilderAPI.buildStock(
                                        context,
                                        crypto.isin,
                                        crypto.name,
                                        crypto.quantity.toString() + " Cryptos",
                                        crypto.quantity * crypto.bid["price"],
                                        crypto.quantity * crypto.boughtAT,
                                        35,
                                        40),
                                  ],
                                );
                              }),
                        );
                      } else {
                        return BuilderAPI.buildText(
                            text: "NOOOOO",
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.normal);
                      }
                    }),
                StreamBuilder(
                    stream: WebsocketAPI.getStockValueStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return BuilderAPI.buildSearchSkeleton();
                      } else if (snapshot.hasData) {
                        List<Stock> stockList = (snapshot.data as List<Stock>);
                        return SizedBox(
                          height: 300.h,
                          child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: stockList.length,
                              itemBuilder: (context, index) {
                                Stock stock = stockList[index];
                                return Row(
                                  children: [
                                    BuilderAPI.buildStock(
                                        context,
                                        stock.isin,
                                        stock.name,
                                        stock.quantity.toString() +
                                            " " +
                                            stock.type,
                                        stock.quantity * stock.bid["price"],
                                        stock.quantity * stock.boughtAT,
                                        35,
                                        40),
                                  ],
                                );
                              }),
                        );
                      } else {
                        return BuilderAPI.buildText(
                            text: "NOOOOO",
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.normal);
                      }
                    })
              ],
            ),
          ),
        ));
  }

  String ammount = "";
}
