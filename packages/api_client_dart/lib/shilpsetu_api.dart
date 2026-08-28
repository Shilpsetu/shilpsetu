// GENERATED FILE — DO NOT EDIT.
//
// Source: packages/api_client_dart/openapi.json
// Schema sha256: b009074517a7d3b6
// Regenerate: python tools/gen_dart_client.py

// ignore_for_file: type=lint

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';

class AttributesOut {
  const AttributesOut({
    this.colours = const [],
    this.craftId,
    this.dimensions,
    this.hoursToMake,
    this.materials = const [],
    this.missing = const [],
    this.productType,
    this.quantityAvailable,
    this.technique,
  });

  factory AttributesOut.fromJson(Map<String, dynamic> json) => AttributesOut(
        colours: (json['colours'] as List<dynamic>).map((e) => e as String).toList(),
        craftId: json['craft_id'] == null ? null : json['craft_id'] as String,
        dimensions: json['dimensions'] == null ? null : json['dimensions'] as String,
        hoursToMake: json['hours_to_make'] == null ? null : (json['hours_to_make'] as num).toDouble(),
        materials: (json['materials'] as List<dynamic>).map((e) => e as String).toList(),
        missing: (json['missing'] as List<dynamic>).map((e) => e as String).toList(),
        productType: json['product_type'] == null ? null : json['product_type'] as String,
        quantityAvailable: json['quantity_available'] == null ? null : json['quantity_available'] as int,
        technique: json['technique'] == null ? null : json['technique'] as String,
      );

  final List<String> colours;
  final String? craftId;
  final String? dimensions;
  final double? hoursToMake;
  final List<String> materials;
  final List<String> missing;
  final String? productType;
  final int? quantityAvailable;
  final String? technique;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'colours': colours,
        'craft_id': craftId,
        'dimensions': dimensions,
        'hours_to_make': hoursToMake,
        'materials': materials,
        'missing': missing,
        'product_type': productType,
        'quantity_available': quantityAvailable,
        'technique': technique,
      };
}

class CatalogOut {
  const CatalogOut({
    required this.attributes,
    required this.descriptions,
    required this.language,
    required this.transcript,
  });

  factory CatalogOut.fromJson(Map<String, dynamic> json) => CatalogOut(
        attributes: AttributesOut.fromJson(json['attributes'] as Map<String, dynamic>),
        descriptions: (json['descriptions'] as List<dynamic>).map((e) => DescriptionOut.fromJson(e as Map<String, dynamic>)).toList(),
        language: json['language'] as String,
        transcript: json['transcript'] as String,
      );

  final AttributesOut attributes;
  final List<DescriptionOut> descriptions;
  final String language;
  final String transcript;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'attributes': attributes.toJson(),
        'descriptions': descriptions.map((e) => e.toJson()).toList(),
        'language': language,
        'transcript': transcript,
      };
}

class CraftOut {
  const CraftOut({
    required this.cluster,
    required this.collection,
    required this.giTagged,
    required this.id,
    required this.name,
    required this.state,
    required this.unit,
  });

  factory CraftOut.fromJson(Map<String, dynamic> json) => CraftOut(
        cluster: json['cluster'] as String,
        collection: json['collection'] as String,
        giTagged: json['gi_tagged'] as bool,
        id: json['id'] as String,
        name: json['name'] as String,
        state: json['state'] as String,
        unit: json['unit'] as String,
      );

  final String cluster;
  final String collection;
  final bool giTagged;
  final String id;
  final String name;
  final String state;
  final String unit;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'cluster': cluster,
        'collection': collection,
        'gi_tagged': giTagged,
        'id': id,
        'name': name,
        'state': state,
        'unit': unit,
      };
}

class DescriptionOut {
  const DescriptionOut({
    required this.body,
    required this.keywords,
    required this.locale,
    required this.title,
  });

  factory DescriptionOut.fromJson(Map<String, dynamic> json) => DescriptionOut(
        body: json['body'] as String,
        keywords: (json['keywords'] as List<dynamic>).map((e) => e as String).toList(),
        locale: json['locale'] as String,
        title: json['title'] as String,
      );

  final String body;
  final List<String> keywords;
  final String locale;
  final String title;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'body': body,
        'keywords': keywords,
        'locale': locale,
        'title': title,
      };
}

class HTTPValidationError {
  const HTTPValidationError({
    this.detail,
  });

  factory HTTPValidationError.fromJson(Map<String, dynamic> json) => HTTPValidationError(
        detail: json['detail'] == null ? null : (json['detail'] as List<dynamic>).map((e) => ValidationError.fromJson(e as Map<String, dynamic>)).toList(),
      );

  final List<ValidationError>? detail;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'detail': detail == null ? null : detail.map((e) => e.toJson()).toList(),
      };
}

class PriceIn {
  const PriceIn({
    required this.craftId,
    required this.hours,
    required this.materialCost,
    required this.state,
    this.finishScore = 0.5,
  });

  factory PriceIn.fromJson(Map<String, dynamic> json) => PriceIn(
        craftId: json['craft_id'] as String,
        hours: Decimal.parse(json['hours'] as String),
        materialCost: Decimal.parse(json['material_cost'] as String),
        state: json['state'] as String,
        finishScore: (json['finish_score'] as num).toDouble(),
      );

  final String craftId;
  final Decimal hours;
  final Decimal materialCost;
  final String state;
  final double finishScore;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'craft_id': craftId,
        'hours': hours.toString(),
        'material_cost': materialCost.toString(),
        'state': state,
        'finish_score': finishScore,
      };
}

class PriceOut {
  const PriceOut({
    required this.bandHigh,
    required this.bandLow,
    required this.floor,
    required this.labourCost,
    required this.materialCost,
    required this.overhead,
    required this.position,
    required this.rationale,
    required this.stretch,
    required this.suggested,
    this.currency = 'INR',
  });

  factory PriceOut.fromJson(Map<String, dynamic> json) => PriceOut(
        bandHigh: Decimal.parse(json['band_high'] as String),
        bandLow: Decimal.parse(json['band_low'] as String),
        floor: Decimal.parse(json['floor'] as String),
        labourCost: Decimal.parse(json['labour_cost'] as String),
        materialCost: Decimal.parse(json['material_cost'] as String),
        overhead: Decimal.parse(json['overhead'] as String),
        position: json['position'] as String,
        rationale: json['rationale'] as String,
        stretch: Decimal.parse(json['stretch'] as String),
        suggested: Decimal.parse(json['suggested'] as String),
        currency: json['currency'] as String,
      );

  final Decimal bandHigh;
  final Decimal bandLow;
  final Decimal floor;
  final Decimal labourCost;
  final Decimal materialCost;
  final Decimal overhead;
  final String position;
  final String rationale;
  final Decimal stretch;
  final Decimal suggested;
  final String currency;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'band_high': bandHigh.toString(),
        'band_low': bandLow.toString(),
        'floor': floor.toString(),
        'labour_cost': labourCost.toString(),
        'material_cost': materialCost.toString(),
        'overhead': overhead.toString(),
        'position': position,
        'rationale': rationale,
        'stretch': stretch.toString(),
        'suggested': suggested.toString(),
        'currency': currency,
      };
}

class TranscribeIn {
  const TranscribeIn({
    required this.audioBase64,
    required this.language,
  });

  factory TranscribeIn.fromJson(Map<String, dynamic> json) => TranscribeIn(
        audioBase64: json['audio_base64'] as String,
        language: json['language'] as String,
      );

  final String audioBase64;
  final String language;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'audio_base64': audioBase64,
        'language': language,
      };
}

class ValidationError {
  const ValidationError({
    required this.loc,
    required this.msg,
    required this.type,
    this.ctx,
    this.input,
  });

  factory ValidationError.fromJson(Map<String, dynamic> json) => ValidationError(
        loc: (json['loc'] as List<dynamic>).map((e) => e).toList(),
        msg: json['msg'] as String,
        type: json['type'] as String,
        ctx: json['ctx'] == null ? null : json['ctx'] as Map<String, dynamic>,
        input: json['input'],
      );

  final List<dynamic> loc;
  final String msg;
  final String type;
  final Map<String, dynamic>? ctx;
  final dynamic input;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'loc': loc,
        'msg': msg,
        'type': type,
        'ctx': ctx,
        'input': input,
      };
}

/// Typed client for the Shilpsetu API.
///
/// Construct with a configured [Dio] so callers control the base URL,
/// timeouts and interceptors:
///
/// ```dart
/// final api = ShilpsetuApi(Dio(BaseOptions(
///   baseUrl: 'http://10.0.2.2:8000',
/// )));
/// ```
class ShilpsetuApi {
  const ShilpsetuApi(this._dio);

  final Dio _dio;

  /// `POST /v1/catalog/from-voice`
  Future<CatalogOut> catalogFromVoice(TranscribeIn body) async {
    final response = await _dio.request<dynamic>(
      '/v1/catalog/from-voice',
      options: Options(method: 'POST'),
      data: body.toJson(),
    );
    final data = response.data;
    return CatalogOut.fromJson(data as Map<String, dynamic>);
  }

  /// `GET /v1/crafts`
  Future<List<CraftOut>> listCrafts() async {
    final response = await _dio.request<dynamic>(
      '/v1/crafts',
      options: Options(method: 'GET'),
    );
    final data = response.data;
    return (data as List<dynamic>).map((e) => CraftOut.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// `GET /v1/health`
  Future<Map<String, dynamic>> health() async {
    final response = await _dio.request<dynamic>(
      '/v1/health',
      options: Options(method: 'GET'),
    );
    final data = response.data;
    return data as Map<String, dynamic>;
  }

  /// `POST /v1/pricing/quote`
  Future<PriceOut> quotePrice(PriceIn body) async {
    final response = await _dio.request<dynamic>(
      '/v1/pricing/quote',
      options: Options(method: 'POST'),
      data: body.toJson(),
    );
    final data = response.data;
    return PriceOut.fromJson(data as Map<String, dynamic>);
  }

}
