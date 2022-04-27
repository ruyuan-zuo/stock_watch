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
      required this.marketCap});
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
// late final SharedPreferences prefs;
//
// void loadSharedPref() async{
//    prefs = await SharedPreferences.getInstance();
// }
// List<SearchEntry> favlists =[];

final String asySharedKey = "stock";

addStringToSF(val) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String? stringValue = prefs.getString(asySharedKey);

  await prefs.setString(asySharedKey, val);
  print("updated prefs: " + val);
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
  late Future<List<SearchEntry>> Fu;

  Future<List<SearchEntry>> _getSharedPref() async {
    String? stockEntryString = await getStringValuesSF();
    // print(stockEntryString);
    Fu = decode(stockEntryString!); // updates our global favlists gives s list
    return Fu;
  }

  @override
  void initState() {
    super.initState();
    Fu = _getSharedPref(); // reset
    // loadSharedPref();
    // _loadFav();
    // Fetch and decode data
  }

  @override
  void didChangeDependencies() {
    print('didChangeDependencies');
    update(); // OK
    super.didChangeDependencies();
  }

  void update() {
    setState(() {
      Fu = _getSharedPref();
      // _loadFav();
    });
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
              });
              ;
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
                final data = snapshot.data as List<SearchEntry>;

                if (snapshot.hasData) {
                  // Extracting data from snapshot object
                  return Expanded(
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StockDetail(
                                    entryDetail: data[index],
                                  ),
                                  // Pass the arguments as part of the RouteSettings. The
                                  // DetailScreen reads the arguments from these settings.
                                  // settings: RouteSettings(
                                  //   arguments: compList[index],
                                  // ),
                                ),
                              );
                            },
                            child: Text(data[index].displaySymbol),
                          );
                        }),
                  );
                }
                else if(data == null) {
                  return Center(
                    child: Text(" "),
                  );

                  // if we got our data
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

Future<List<SearchEntry>> getFavList() async {
  String? encode_str = await getStringValuesSF();
  List<SearchEntry> favlists = await decode(encode_str!);
  return favlists;
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

  late CompanyDetail compDetail; // fetched object in future
  late Stock stockDetail; //fetched future object i
  late InforPage info; // load with future

  bool isInFavList = false;
  List<SearchEntry> favList = []; // get the list of fav lists

  /* Method for load local instance of fav list
   */
  void loadFavList(List<SearchEntry> favlists) async {
    favlists = await getFavList();
  }
  // ().then
/* Method for get isIn
 */
  Future<bool> getIsIn(String tar) async {
    favList = await getFavList();
    bool isIn = false;
    if (favList.length == 0) false;
    for (SearchEntry e in favList) {
      if (e.displaySymbol == tar) {
        // setState(() {
          isIn = true;
        // });
      }
    }
    return isIn;
  }

  @override
  void initState() {
    super.initState();
    String tar = widget.entryDetail.displaySymbol;
    // loadFavList(favList);
    getIsIn(tar).then((value) => setState(() {
      isInFavList = value;
    }));

  }

  void updateFavListInMem(String newEncFavList) async {
    addStringToSF(newEncFavList); //send back to memory
  }

  // Future
  // update the view when state change
  Future<InforPage> _getStockInfo(String query) async {
    // getIsIn(widget.entryDetail.displaySymbol).then((value) => setState(() {
    //   isInFavList = value;
    // }));

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
    // if(isInFavList){
    //   setState(() {
    //     isInFavList = true;
    //   });
    // }


    return info;
  }

  void removeEntryFromFavList(String symbol) {
    int index =
        favList.indexWhere((element) => element.displaySymbol == symbol);

    print(index);
    print(favList[index]);
    favList.removeAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
            return Scaffold(
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
                      setState(() {

                        if (isInFavList == false) {
                          // List<SearchEntry> favlists = await getFavList();
                          favList.add(widget.entryDetail);
                          isInFavList = true;
                        } else {
                          // List<SearchEntry> favlists = await getFavList();
                          removeEntryFromFavList(
                              widget.entryDetail.displaySymbol);
                          isInFavList = false;
                        }
                        final String encodedData = SearchEntry.encode(favList);
                        print(encodedData);
                        print("\n");
                        updateFavListInMem(encodedData);
                      });
                    },
                    icon: isInFavList
                        ? Icon(Icons.favorite)
                        : Icon(Icons.favorite_border),
                  ),
                ],
              ),
              // body: stockDetail.checknullValue() ? Center(child: Text('Failed to Fetch Stock Data'))
              //     : _buildContext(stockDetail, compDetail), // for each stock/Company render the view
              body: Column(children: <Widget>[
                Text(widget.entryDetail.displaySymbol),

                // favlists.length == 0? Text("FAVES") : renderFavList(favlists),
              ]),
            );
          }
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
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
