import 'package:INSUL/core/utils/hive_db_utils.dart';
import 'package:dio/dio.dart';
import '../../data/models/nutrition_donut_model.dart';
import '../../data/models/search_meal_model.dart';
import 'api_config.dart';

Future<List<FoodItem>> fetchFoodItem(String foodName) async {
  final dio = Dio();
  final response = await dio.get(
    searchMealData,
    queryParameters: {'food': foodName},
  );

  if (response.statusCode == 200) {
    var data = response.data['data'];
    var filteredData =
        (data as List).where((item) => item['Carbs'] != '0.00g').toList();
    return filteredData.map((item) => FoodItem.fromJson(item)).toList();
    // return (data as List).map((item) => FoodItem.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load food items');
  }
}

Future<List<NutritionDonutDataItem>> fetchNutritionDonutData(
    String filterName) async {
  print('coming filtername $filterName');
  final dio = Dio();
     final _hivedb = HiveDbHelper();
 final String? userId = await _hivedb.getString('userId');
  try {
    final response = await dio.get(
      '$fetchNutritionDataChart/$userId',
      queryParameters: {'filter': filterName.toLowerCase()},
    );

    if (response.statusCode == 200) {
      var data = response.data['data'];
print(response);
      return (data as List)
          .map((item) => NutritionDonutDataItem.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load food items');
    }
  } catch (e) {
    print('Error fetching data: $e');
    rethrow;
  }
}



