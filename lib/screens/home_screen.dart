import 'package:bitset/controllers/crypto_controller.dart';
import 'package:bitset/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chart_sparkline/chart_sparkline.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CryptoController controller = Get.put(CryptoController());
  int defaultValue = 10;
  String? selectedDropdownValue = '10';

  void onDropdownValueChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        selectedDropdownValue = newValue;
        defaultValue = int.parse(newValue);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 44, 45, 44),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          physics: const ScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Cryptocurrencies",
                  style: textStyle(MediaQuery.of(context).size.width * 0.08,
                      Colors.white, FontWeight.bold)),
              //Add widget here and make it be able to change default value
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DropdownButton<String>(
                    value: selectedDropdownValue,
                    onChanged: onDropdownValueChanged,
                    dropdownColor: Colors.black87,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    items: [
                      DropdownMenuItem<String>(
                        value: '10',
                        child: Text('Top 10',
                            style: textStyle(
                                MediaQuery.of(context).size.width * 0.05,
                                Colors.white,
                                FontWeight.bold)),
                      ),
                      DropdownMenuItem<String>(
                        value: '15',
                        child: Text('Top 15',
                            style: textStyle(
                                MediaQuery.of(context).size.width * 0.05,
                                Colors.white,
                                FontWeight.bold)),
                      ),
                      DropdownMenuItem<String>(
                        value: '30',
                        child: Text('Top 30',
                            style: textStyle(
                                MediaQuery.of(context).size.width * 0.05,
                                Colors.white,
                                FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
              Obx(
                () => controller.isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: defaultValue,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 60,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "${index + 1}.)",
                                        style: textStyle(
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                            Colors.white,
                                            FontWeight.w600),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.168,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.168,
                                        child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Image.network(controller
                                                .cryptoList[index].image)),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "${controller.cryptoList[index].name} (${controller.cryptoList[index].symbol.toUpperCase()})",
                                            style: textStyle(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.035,
                                                Colors.white,
                                                FontWeight.w600),
                                          ),
                                          Text(
                                            "${controller.cryptoList[index].priceChangePercentage24H.toStringAsFixed(2)}%",
                                            style: textStyle(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.035,
                                                _getColor(controller
                                                    .cryptoList[index]
                                                    .priceChangePercentage24H),
                                                FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "\$${controller.cryptoList[index].currentPrice.toStringAsFixed(2)}",
                                        style: textStyle(
                                            MediaQuery.of(context).size.width *
                                                0.035,
                                            Colors.white,
                                            FontWeight.w600),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.08,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                        child: Sparkline(
                                          data: controller.cryptoList[index]
                                              .sparklineIn7D.price,
                                          lineColor: _getColor(controller
                                              .cryptoList[index]
                                              .priceChangePercentage24H),
                                          lineWidth: 2,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _getColor(double percentage) {
  if (percentage > 0) {
    return Colors.green; // Positive percentage, display in green
  } else if (percentage < 0) {
    return Colors.red; // Negative percentage, display in red
  } else {
    return Colors
        .grey; // Zero percentage, display in grey or any other color you prefer
  }
}
