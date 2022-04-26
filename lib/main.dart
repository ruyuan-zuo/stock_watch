// search with keyword
//https://finnhub.io/api/v1/search?q=apple&token=c9guatqad3iblo2fo3e0 get search the list of companies

// detal for company AAPL
//https://finnhub.io/api/v1/stock/profile2?symbol=symbol&token=c9guatqad3iblo2fo3e0

// detail for stock

//https://finnhub.io/api/v1/quote?symbol=symbol&token=c9guatqad3iblo2fo3e0

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'home_screen.dart';

void main() {
  runApp(MyApp());
}

class CompanyDetail{
  //https://finnhub.io/api/v1/stock/profile2?symbol=AAPL&token=c9guatqad3iblo2fo3e0
  /*
  {"country":"US","currency":"USD","exchange":"NASDAQ NMS - GLOBAL MARKET",
  "finnhubIndustry":"Technology","ipo":"1980-12-12","logo":"https://static.finnhub.io/logo/87cb30d8-80df-11ea-8951-00000000092a.png",
  "marketCapitalization":2693850,"name":"Apple Inc","phone":"14089961010.0",
  "shareOutstanding":16319.44,"ticker":"AAPL","weburl":"https://www.apple.com/"}
   */
  final String name;
  final String symbol;
  final String startDate;
  final String industry;
  final String website;
  final String exchange;
  final int marketCap;
  CompanyDetail(this.name, this.symbol, this.startDate, this.industry, this.website, this.exchange, this.marketCap);
}

class MyApp extends StatelessWidget {
  // CompanyDetail  applDetail= CompanyDetail("Apple Inc", "AAPL", "1980-12-12", "Technology", "https://www.apple.com/", "NASDAQ NMS - GLOBAL MARKET", 2693850);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.purple,
      ),
      home: HomeScreen(),

      // home:StockDetail(applDetail),
    );
  }
}
