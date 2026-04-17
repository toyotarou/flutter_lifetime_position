import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/position_model.dart';

class PositionRepository {
  static const String _baseUrl = 'http://49.212.175.205:8081';

  static Future<List<PositionModel>> fetchAll(int userId) async {
    try {
      final http.Response response = await http.get(Uri.parse('$_baseUrl/api/getLifetimeAllPosition'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = json['data'] as List<dynamic>;
        return data
            .map((dynamic e) => PositionModel.fromJson(e as Map<String, dynamic>))
            .where((PositionModel p) => p.userId == userId)
            .toList();
      }
    } catch (e) {
      debugPrint('fetchAll error: $e');
    }
    return <PositionModel>[];
  }
}
