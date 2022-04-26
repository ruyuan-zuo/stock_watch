import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// import 'show_stock.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompanyDetail {
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
  final double marketCap;

  CompanyDetail(
      {required this.name,
      required this.symbol,
      required this.startDate,
      required this.industry,
      required this.website,
      required this.exchange,
      required this.marketCap});

  factory CompanyDetail.fromJson(Map<String, dynamic> json) {
    return CompanyDetail(
      name: json["name"],
      symbol: json["ticker"],
      startDate: json["ipo"],
      industry: json["finnhubIndustry"],
      website: json["weburl"],
      exchange: json["exchange"],
      marketCap: json["marketCapitalization"],
    );
  }
}

class Stock {
  //https://finnhub.io/api/v1/quote?symbol=symbol&token=c9guatqad3iblo2fo3e0
  final double currentPrice;
  final double dchange;
  final double dpercentChange;
  final double highPriceOfDay;
  final double lowPriceOfDay;
  final double openPriceOfDay;
  final double previousClosePrice;
  final int t;

  Stock(
      {required this.currentPrice,
      required this.dchange,
      required this.dpercentChange,
      required this.highPriceOfDay,
      required this.lowPriceOfDay,
      required this.openPriceOfDay,
      required this.previousClosePrice,
      required this.t});

  bool checknullValue() {
    return [
      currentPrice,
      dchange,
      openPriceOfDay,
      highPriceOfDay,
      lowPriceOfDay,
      previousClosePrice
    ].contains(null);
  }

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      currentPrice: json["c"],
      dchange: json["d"],
      dpercentChange: json["dp"],
      highPriceOfDay: json["h"],
      lowPriceOfDay: json["l"],
      openPriceOfDay: json["o"],
      previousClosePrice: json["pc"],
      t: json["t"],
    );
  }
}

class InforPage {
  //https://finnhub.io/api/v1/quote?symbol=symbol&token=c9guatqad3iblo2fo3e0
  final double currentPrice;
  final double dchange;
  final double dpercentChange;
  final double highPriceOfDay;
  final double lowPriceOfDay;
  final double openPriceOfDay;
  final double previousClosePrice;
  final int t;
  final String name;
  final String symbol;
  final String startDate;
  final String industry;
  final String website;
  final String exchange;
  final double marketCap;
   InforPage(
      {required this.currentPrice,
      required this.dchange,
      required this.dpercentChange,
      required this.highPriceOfDay,
      required this.lowPriceOfDay,
      required this.openPriceOfDay,
      required this.previousClosePrice,
      required this.t,
      required this.name,
      required this.symbol,
      required this.startDate,
      required this.industry,
      required this.website,
      required this.exchange,
      required this.marketCap,
      });
}

class SearchEntry {
  final String description;
  final String displaySymbol;

  const SearchEntry({required this.description, required this.displaySymbol});

  factory SearchEntry.fromJson(Map<String, dynamic> json) {
    return SearchEntry(
      description: json["description"] as String,
      displaySymbol: json["displaySymbol"] as String,
    );
  }

  static Map<String, dynamic> toMap(SearchEntry entry) => {
        'description': entry.description,
        'displaySymbol': entry.displaySymbol,
      };

  static String encode(List<SearchEntry> entries) => json.encode(
        entries
            .map<Map<String, dynamic>>((entry) => SearchEntry.toMap(entry))
            .toList(),
      );
}

class CompeletSearch {
  final int number;
  final List<SearchEntry> listOfRes;

  CompeletSearch({required this.number, required this.listOfRes});

  factory CompeletSearch.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['result'] as List;
    print(list.runtimeType); //returns List<dynamic>
    List<SearchEntry> entryList =
        list.map((i) => SearchEntry.fromJson(i)).toList();
    return CompeletSearch(number: parsedJson['count'], listOfRes: entryList);
  }
}

Future<CompeletSearch> fetchSearchList(String url_sub) async {
  try {
    String url = "https://finnhub.io/api/v1/search?q=" +
        url_sub +
        "&token=c9guatqad3iblo2fo3e0";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      print(response.body);
      return CompeletSearch.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load');
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future<Stock> fetchCompStock(String compSymbol) async {
  try {
    //https://finnhub.io/api/v1/quote?symbol=AAPL&token=c9guatqad3iblo2fo3e0

    String url = "https://finnhub.io/api/v1/quote?symbol=" +
        compSymbol +
        "&token=c9guatqad3iblo2fo3e0";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      print(response.body);
      return Stock.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load');
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future<CompanyDetail> fetchCompDetail(String compSymbol) async {
  try {
    //https://finnhub.io/api/v1/stock/profile2?symbol=AAPL&token=c9guatqad3iblo2fo3e0
    String url = "https://finnhub.io/api/v1/stock/profile2?symbol=" +
        compSymbol +
        "&token=c9guatqad3iblo2fo3e0";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      print(response.body);
      return CompanyDetail.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load');
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}

/*
block function sto load fav list ;
 */
late final SharedPreferences prefs;


// List<SearchEntry> favlists =[];
final String asySharedKey = "stock";

addStringToSF(val) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? stringValue = prefs.getString(asySharedKey);

  await prefs.setString(asySharedKey, val);
}

Future<String?> getStringValuesSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Return String

  print(prefs.getString(asySharedKey));
  String? stringValue = prefs.getString(asySharedKey);
  return stringValue;
}

// List<SearchEntry> decode(String musics) {
//   return (json.decode(musics) as List<dynamic>)
//       .map<SearchEntry>((item) => SearchEntry.fromJson(item))
//       .toList();
// }

Future<List<SearchEntry>> decode(String entries) async {
  return (json.decode(entries) as List<dynamic>)
      .map<SearchEntry>((item) => SearchEntry.fromJson(item))
      .toList();
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Future<List<SearchEntry>> _getSharedPref() async {
  //
  //   String? stockEntryString = await getStringValuesSF();
  //   // print(stockEntryString);
  //   favlists = await decode(stockEntryString!);
  //   return favlists;
  //
  // }

  late List<SearchEntry> favlists;
   late Future<List<SearchEntry>> Fu;
   Future<List<SearchEntry>> _getSharedPref() async {

    String? stockEntryString = await getStringValuesSF();
    // print(stockEntryString);
    Fu =  decode(stockEntryString!); // updates our global favlists gives s list
    return Fu;
  }
  @override
  void initState() {
    super.initState();
    Fu = _getSharedPref(); // reset
    // _loadFav();
    // Fetch and decode data
  }

  @override
  void didChangeDependencies() {
    print('didChangeDependencies');
    update();          // OK
    super.didChangeDependencies();
  }

  void update(){
    setState(() {
      Fu = _getSharedPref();
      // _loadFav();
    });
  }

  void _loadFav(){
     getFavList().then((value) => favlists=value);
  }

  @override
  Widget build(BuildContext context) {
    // var curData = InheritedDataProvider.of(context).data;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Stock'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(),
                  // Pass the arguments as part of the RouteSettings. The
                  // DetailScreen reads the arguments from these settings.
                  // settings: RouteSettings(
                  //   arguments: compList[index],
                  // ),
                ),
              ).then((value) {
                update();
              });;
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("Fav Lits"),
          // favlists.length == 0? Text("FAVES") : renderFavList(favlists),
          FutureBuilder(
            future: Fu,
            builder: (context, snapshot) {
              // Checking if future is resolved or not
              if (snapshot.connectionState == ConnectionState.done) {
                // If we got an error
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '${snapshot.error} occured',
                      style: TextStyle(fontSize: 18),
                    ),
                  );

                  // if we got our data
                } else if (snapshot.hasData) {
                  // Extracting data from snapshot object
                  final data = snapshot.data as List<SearchEntry>;
                  return Expanded(
                      child: ListView.builder(
                    itemCount: favlists.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(favlists[index].displaySymbol),
                      );
                    },
                  ));
                }
              }

              // Displaying LoadingSpinner to indicate waiting state
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          )
        ],
      ),
    );
  }
}

Future<List<SearchEntry>> getFavList() async{
  String? encode_str =  await getStringValuesSF();
  List<SearchEntry> favlists = await decode(encode_str!);
  return favlists;
}

Future<bool> getIsIn(String s ) async{
  List<SearchEntry> favlists = await getFavList();
  if(favlists.length==0) return false;
  bool isIn = false;
  for(SearchEntry e in favlists){
    if(e.displaySymbol == s) isIn = true;
  }
  return isIn;
}


Widget _builContent(List<SearchEntry> searchEntries) {
  // CompanyDetail compD = compList[index];

  return ListView.builder(
    itemCount: searchEntries.length,
    itemBuilder: (context, index) {
      return ListTile(
        title: Text(searchEntries[index].displaySymbol +
            " | " +
            searchEntries[index].description),
        // When a user taps the ListTile, navigate to the DetailScreen.
        // Notice that you're not only creating a DetailScreen, you're
        // also passing the current
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StockDetail(
                entryDetail: searchEntries[index],
              ),
              // Pass the arguments as part of the RouteSettings. The
              // DetailScreen reads the arguments from these settings.
              // settings: RouteSettings(
              //   arguments: compList[index],
              // ),
            ),
          );
        },
      );
    },
  );
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final myController = TextEditingController();

  // String q = "";
  // @override
  // void dispose() {
  //   // Clean up the controller when the widget is disposed.
  //   myController.dispose();
  //   super.dispose();
  // }
  // late Future<CompeletSearch> searchRes;
  List<SearchEntry> searchEntries = [];

  void sendSearchResults(String query) {
    // print(query);
    fetchSearchList(query).then((result) {
      // Once we receive our name we trigger rebuild.
      setState(() {
        searchEntries = result.listOfRes;
      });
    });
    // print(futureAlbum);
  }

  @override
  Widget build(BuildContext) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Center(
            child: TextField(
              onChanged: (value) {
                sendSearchResults(value);
              },
              controller: myController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    myController.clear();
                  },
                ),
                hintText: 'Search',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
      body: searchEntries.isEmpty
          ? Center(child: Text('No suggestions Found'))
          : _builContent(searchEntries),
    );
  }
}

class StockDetail extends StatefulWidget {
  final SearchEntry entryDetail;

  const StockDetail({Key? key, required this.entryDetail}) : super(key: key);

  @override
  _StockDetailState createState() => _StockDetailState();
}

class _StockDetailState extends State<StockDetail> {
  String url =
      "https://finnhub.io/api/v1/quote?symbol=symbol&token=c9guatqad3iblo2fo3e0";

  late CompanyDetail compDetail;
  late Stock stockDetail;

  late InforPage info;

  late List<SearchEntry> favList;
  @override
  void initState() {
    super.initState();
 }

  // Future
  // update the view when state change
  Future<InforPage> _getStockInfo(String query) async {
    stockDetail = await fetchCompStock(query);
    compDetail = await fetchCompDetail(query);

    info = InforPage(
        currentPrice: stockDetail.currentPrice,
        dchange: stockDetail.dchange,
        dpercentChange: stockDetail.dpercentChange,
        highPriceOfDay: stockDetail.highPriceOfDay,
        lowPriceOfDay: stockDetail.lowPriceOfDay,
        openPriceOfDay: stockDetail.openPriceOfDay,
        previousClosePrice: stockDetail.previousClosePrice,
        t: stockDetail.t,
        name: compDetail.name,
        symbol: compDetail.symbol,
        startDate: compDetail.startDate,
        industry: compDetail.industry,
        website: compDetail.website,
        exchange: compDetail.exchange,
        marketCap: compDetail.marketCap,
    );

    return info;
  }



  @override
  Widget build(BuildContext context) {


    return   Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Details'),
        ),
        leading: BackButton(
          onPressed: () {
            // Navigate back to the first screen by popping the current route
            // off the stack.
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() async {
                if(isIn) {
                  List<SearchEntry> favlists = await getFavList();
                  favlists.add(widget.entryDetail);
                  final String encodedData =
                  SearchEntry.encode(favlists);
                  print(encodedData);
                  print("\n");
                  addStringToSF(encodedData);
                }
                else{
                  List<SearchEntry> favlists = await getFavList();

                  favlists.remove(widget.entryDetail);
                  final String encodedData =
                  SearchEntry.encode(favlists);
                  print(encodedData);
                  print("\n");
                  addStringToSF(encodedData);
                }
              });

            },
            icon : isIn ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
          ),
        ],
      ),
      // body: stockDetail.checknullValue() ? Center(child: Text('Failed to Fetch Stock Data'))
      //     : _buildContext(stockDetail, compDetail), // for each stock/Company render the view
      body: Column(children: <Widget>[


      FutureBuilder(
      future: _getStockInfo(widget.entryDetail.displaySymbol),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to Fetch Stock Data'),
            );

            // if we got our data
          } else if (snapshot.hasData) {
            // Extracting data from snapshot object
            final info = snapshot.data as InforPage;
            return Text("Hi");
          }
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    ),

        // favlists.length == 0? Text("FAVES") : renderFavList(favlists),
      ]),
    );





  }
}

Widget titleSection(InforPage info) {
  return Container(
    padding: const EdgeInsets.all(32),
    child: Row(
      children: [
        Text(info.symbol),
        Text(info.name),
      ],
    ),
  );
}

Widget stockPriceSection(InforPage info) {
  return Container(
    padding: const EdgeInsets.all(32),
    child: Row(
      children: [
        Text(info.currentPrice.toString()),
        const SizedBox(
          width: 10,
        ),
        Text(info.dchange.toString()),
      ],
    ),
  );
}

Widget stockStatSection(InforPage info) {
  return Container(
    padding: const EdgeInsets.all(32),
    child: Column(
      children: [
        Text("Stats"),
        Column(
          children: [
            Row(
              children: [
                Text("Open"),
                const SizedBox(
                  width: 10,
                ),
                Text(info.openPriceOfDay.toString()),
                const SizedBox(
                  width: 10,
                ),
                Text("High"),
                const SizedBox(
                  width: 10,
                ),
                Text(info.highPriceOfDay.toString()),
              ],
            ),
          ],
        ),
        Column(
          children: [
            Row(
              children: [
                Text("Low"),
                const SizedBox(
                  width: 10,
                ),
                Text(info.lowPriceOfDay.toString()),
                const SizedBox(
                  width: 10,
                ),
                Text("Prev"),
                const SizedBox(
                  width: 10,
                ),
                Text(info.previousClosePrice.toString()),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

Widget aboutSection(InforPage info) {
  return Container(
    padding: const EdgeInsets.all(32),
    child: SizedBox(
      height: 200, // Some height
      child: Column(
        children: [
          Text("About"),
          Column(
            children: [
              Text("Start Date"),
              Text(info.startDate),
            ],
          ),
          Column(
            children: [
              Text("Industry"),
              Text(info.industry),
            ],
          ),
          Column(
            children: [
              Text("Website"),
              Text(info.website),
            ],
          ),
          Column(
            children: [
              Text("Exchange"),
              Text(info.exchange),
            ],
          ),
          Column(
            children: [
              Text("Market Cap"),
              Text(info.marketCap.toString()),
            ],
          ),
        ],
      ),
    ),
  );
}

// return three widgets for the list view
Widget _buildStockContext(InforPage info) {
  return Column(children: <Widget>[
    Expanded(
      child: ListView(
        children: [
          // Text(info.currentPrice.toString()),
          // titleSection(info),
          // stockPriceSection(info),
          // stockStatSection(info),
          // aboutSection(info),
        ],
      ),
    ),
  ]);
}
