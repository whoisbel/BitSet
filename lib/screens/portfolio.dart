import 'package:flutter/material.dart';
import 'package:bitset/controllers/portfolio_controller.dart';
import 'package:bitset/model/portfolio_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bitset/utils.dart';
import 'package:bitset/controllers/crypto_controller.dart';
import 'package:get/get.dart';
import 'package:pie_chart/pie_chart.dart';

class PortfolioViewPage extends StatefulWidget {
  final dynamic cryptoData;

  PortfolioViewPage({Key? key, this.cryptoData}) : super(key: key);

  @override
  State<PortfolioViewPage> createState() => _PortfolioViewPageState();
}

class _PortfolioViewPageState extends State<PortfolioViewPage> {
  late PortfolioController _portfolioController;
  final CryptoController controller = Get.put(CryptoController());
  final GlobalKey<NavigatorState> myNavigatorKey = GlobalKey<NavigatorState>();
  @override
  void initState() {
    super.initState();
    _initializePortfolioController();
  }

  void _initializePortfolioController() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final portfolioController = PortfolioController(prefs);
    setState(() {
      _portfolioController = portfolioController;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cryptoName = widget.cryptoData?.name ?? 'No Name';
    final cryptoSymbol = widget.cryptoData?.symbol ?? 'No Symbol';
    final cryptoPrice = widget.cryptoData?.currentPrice ?? 'No Price';
    TextEditingController asset = TextEditingController();

    if (cryptoName != 'No Name' || cryptoSymbol != "No Symbol") {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {'/Portfolio': (context) => PortfolioViewPage()},
        home: Scaffold(
          backgroundColor: const Color.fromARGB(255, 44, 45, 44),
          body: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: AlertDialog(
                backgroundColor: const Color.fromARGB(255, 44, 45, 44),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Investment",
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Enter the amount you want to invest:",
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        style: TextStyle(color: Colors.white),
                        keyboardType:
                            TextInputType.number, // Allow numeric input
                        decoration: InputDecoration(
                          hintText: "Enter amount",
                          hintStyle: TextStyle(color: Colors.white54),
                        ),
                        controller: asset,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final double investmentAmount = double.parse(asset.text);
                      // You can use the investmentAmount as needed
                      _addAsset(
                        cryptoName,
                        cryptoSymbol.toString().toUpperCase(),
                        cryptoPrice,
                        investmentAmount,
                      );
                      print("User wants to invest: $investmentAmount");
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed('/Portfolio');
                    },
                    child: const Text(
                      "OK",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_portfolioController == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 44, 45, 44),
        body: Column(
          children: [
            _buildPieChart(),
            _buildPortfolioList(),
          ],
        ),
      );
    }
  }

  Widget _buildPieChart() {
    PortfolioModel? portfolioModel = _portfolioController.portfolioModel;

    if (portfolioModel != null && portfolioModel.assets.isNotEmpty) {
      Map<String, double> dataMap = {};
      for (var asset in portfolioModel.assets) {
        dataMap[asset.assetName] = asset.totalInvested;
      }

      return Center(
        child: Container(
          margin: const EdgeInsets.all(16.0),
          child: PieChart(
            dataMap: dataMap,
            animationDuration: const Duration(milliseconds: 1200),
            chartLegendSpacing: 32.0,
            chartRadius: MediaQuery.of(context).size.width / 1.5,
            colorList: _generateRandomColors(dataMap.length),
            centerText: "Total Balance\n \$${_getTotalInvest(portfolioModel)}",
            centerTextStyle: textStyle(24, Colors.white, FontWeight.bold),
            chartType: ChartType.ring,
            legendOptions: const LegendOptions(
              showLegendsInRow: true,
              legendPosition: LegendPosition.bottom,
              showLegends: true,
              legendShape: BoxShape.circle,
              legendTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            chartValuesOptions: const ChartValuesOptions(
              showChartValueBackground: false,
              showChartValues: false,
              showChartValuesInPercentage: true,
              showChartValuesOutside: true,
              decimalPlaces: 2,
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildPortfolioList() {
    PortfolioModel? portfolioModel = _portfolioController.portfolioModel;

    if (portfolioModel != null) {
      return Expanded(
        child: ListView.builder(
          itemCount: portfolioModel.assets.length,
          itemBuilder: (context, index) {
            final Asset asset = portfolioModel.assets[index];
            return Card(
              color: const Color.fromARGB(255, 44, 45, 44),
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                leading: Image.network(_getImageLink(controller, asset)),
                title: Text(
                  "${asset.assetName} (${asset.tickerSymbol})",
                  style: textStyle(
                    14,
                    Colors.white,
                    FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'QTY: ${asset.quantity.toStringAsFixed(8)}',
                  style: textStyle(
                    14,
                    Colors.white,
                    FontWeight.w600,
                  ),
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${asset.totalInvested}',
                      style: textStyle(
                        14,
                        Colors.white,
                        FontWeight.w600,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Button for buying more of the asset.
                            _showBuyDialog(asset);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Buy'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            // Button for selling the asset.
                            _showSellDialog(asset);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Sell'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } else {
      return const Center(
        child: Text('No data available.'),
      );
    }
  }

  void _addAsset(String asset, String ticker, double price, double amount) {
    final String assetName = asset;
    final String tickerSymbol = ticker;
    final double quantity = amount / price;
    final double totalInvested = amount;

    if (assetName.isNotEmpty &&
        tickerSymbol.isNotEmpty &&
        quantity > 0 &&
        totalInvested > 0) {
      final Asset newAsset = Asset(
        assetName: assetName,
        tickerSymbol: tickerSymbol,
        quantity: quantity,
        totalInvested: totalInvested,
      );

      _portfolioController.addAsset(newAsset);

      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid asset details.'),
        ),
      );
    }
  }

  void _showBuyDialog(Asset asset) {
    showDialog(
      context: context,
      builder: (context) {
        double amount = 0;
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 44, 45, 44),
          title: Text(
            'Buy ${asset.assetName}',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  amount = double.tryParse(value) ?? 0;
                },
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
              style: ElevatedButton.styleFrom(
                primary: Colors.grey,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _buyAsset(asset, amount);
                Navigator.of(context).pop();
              },
              child: const Text('Buy'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSellDialog(Asset asset) {
    showDialog(
      context: context,
      builder: (context) {
        double amount = 0;
        double quantity = 0;
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 44, 45, 44),
          title: Text(
            'Sell ${asset.assetName}',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  amount = double.tryParse(value) ?? 0;
                },
                style: TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
              style: ElevatedButton.styleFrom(
                primary: Colors.grey,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                quantity = amount / _getPrice(controller, asset);
                _sellAsset(asset, amount, quantity);
                Navigator.of(context).pop();
              },
              child: const Text('Sell'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  void _buyAsset(Asset asset, double amount) {
    if (amount > 0) {
      final double updatedQuantity =
          asset.quantity + (amount / _getPrice(controller, asset));
      final double updatedTotalInvested = asset.totalInvested + amount;

      final Asset updatedAsset = Asset(
        assetName: asset.assetName,
        tickerSymbol: asset.tickerSymbol,
        quantity: updatedQuantity,
        totalInvested: updatedTotalInvested,
      );

      _portfolioController.editAsset(updatedAsset);

      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please enter a valid quantity and total invested amount.'),
        ),
      );
    }
  }

  void _sellAsset(Asset asset, double amount, double quantity) {
    if (asset.totalInvested > 0) {
      final double updatedQuantity = asset.quantity - quantity;
      final double updatedTotalInvested = asset.totalInvested - amount;
      if (updatedTotalInvested <= 0) {
        _portfolioController.removeAsset(asset.tickerSymbol);
      } else {
        final Asset updatedAsset = Asset(
          assetName: asset.assetName,
          tickerSymbol: asset.tickerSymbol,
          quantity: updatedQuantity,
          totalInvested: updatedTotalInvested,
        );
        _portfolioController.editAsset(updatedAsset);
      }

      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please enter a valid quantity and total invested amount.'),
        ),
      );
    }
  }

  void _removeAsset(String tickerSymbol) {
    _portfolioController.removeAsset(tickerSymbol);

    setState(() {});
  }

  double _getTotalInvest(PortfolioModel model) {
    double result = 0;
    for (var i = 0; i < model.assets.length; i++) {
      result += model.assets[i].totalInvested;
    }
    return result;
  }

  double _getPrice(CryptoController control, Asset asset) {
    for (int i = 0; i < control.cryptoList.length; i++) {
      if (asset.assetName == control.cryptoList[i].name) {
        return control.cryptoList[i].currentPrice;
      }
    }

    return 0;
  }

  String _getImageLink(CryptoController control, Asset asset) {
    for (int i = 0; i < control.cryptoList.length; i++) {
      if (asset.assetName == control.cryptoList[i].name) {
        return control.cryptoList[i].image;
      }
    }
    return "No image";
  }

  void _navigateToPortfolio() {
    Navigator.of(context).pop();
    _initializePortfolioController();
  }
}

List<Color> _generateRandomColors(int count) {
  List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.amber,
    Colors.yellow,
    Colors.indigo,
    Colors.pink,
    Colors.cyan,
    Colors.brown,
  ];

  return colors.take(count).toList();
}
