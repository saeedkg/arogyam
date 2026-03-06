import '../../network/entities/api_request.dart';
import '../../network/exceptions/api_exception.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../../common_services/constants/common_urls.dart';
import '../entities/search/search_suggestion.dart';
import '../entities/popular_searches.dart';


class EnhancedSearchService {
  final NetworkAdapter _networkAdapter;

  EnhancedSearchService({NetworkAdapter? networkAdapter})
      : _networkAdapter = networkAdapter ?? AROGYAMAPI();

  /// Get autocomplete suggestions
  Future<List<SearchSuggestion>> getAutocomplete(
    String query, {
    int limit = 10,
  }) async {
    final url = CommonUrls.getAutocompleteUrl(query, limit: limit);
    final apiRequest = APIRequest(url);

    try {
      final res = await _networkAdapter.get(apiRequest);
      return _parseAutocompleteResponse(res.data);
    } on NetworkFailureException {
      throw NetworkFailureException();
    } on APIException catch (exception) {
      if (exception is HTTPException) {
        if (exception.responseData != null &&
            exception.responseData is Map<String, dynamic> &&
            (exception.responseData as Map<String, dynamic>)["message"] !=
                null) {
          final responseMap = exception.responseData as Map<String, dynamic>;
          final message = responseMap["message"] as String;
          final errorCode = responseMap["errorCode"] ?? exception.httpCode;
          throw ServerSentException(message, errorCode);
        }
        throw ServerSentException(
            'Failed to fetch autocomplete', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }

  /// Get popular searches
  Future<PopularSearches> getPopularSearches() async {
    final url = CommonUrls.getPopularSearchesUrl();
    final apiRequest = APIRequest(url);

    try {
      final res = await _networkAdapter.get(apiRequest);
      return _parsePopularSearchesResponse(res.data);
    } on NetworkFailureException {
      throw NetworkFailureException();
    } on APIException catch (exception) {
      if (exception is HTTPException) {
        if (exception.responseData != null &&
            exception.responseData is Map<String, dynamic> &&
            (exception.responseData as Map<String, dynamic>)["message"] !=
                null) {
          final responseMap = exception.responseData as Map<String, dynamic>;
          final message = responseMap["message"] as String;
          final errorCode = responseMap["errorCode"] ?? exception.httpCode;
          throw ServerSentException(message, errorCode);
        }
        throw ServerSentException(
            'Failed to fetch popular searches', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }

  // Response Parsing Methods

  List<SearchSuggestion> _parseAutocompleteResponse(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return [];
    }

    final map = data;

    // Handle success response structure
    if (map['success'] == true && map['data'] != null) {
      final dataMap = map['data'] as Map<String, dynamic>;
      final List<SearchSuggestion> allSuggestions = [];
      
      // Parse regular suggestions
      if (dataMap['suggestions'] is List) {
        final list = dataMap['suggestions'] as List<dynamic>;
        allSuggestions.addAll(
          list.map((e) => SearchSuggestion.fromJson(e as Map<String, dynamic>))
        );
      }
      
      // Parse did_you_mean suggestions
      if (dataMap['did_you_mean'] != null) {
        final didYouMeanData = dataMap['did_you_mean'];
        if (didYouMeanData is List) {
          // If it's an array
          allSuggestions.addAll(
            didYouMeanData.map((e) => SearchSuggestion.fromJson(e as Map<String, dynamic>))
          );
        } else if (didYouMeanData is Map) {
          // If it's an object with numbered keys
          allSuggestions.addAll(
            didYouMeanData.values.map((e) => SearchSuggestion.fromJson(e as Map<String, dynamic>))
          );
        }
      }
      
      return allSuggestions;
    }

    return [];
  }

  PopularSearches _parsePopularSearchesResponse(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid popular searches response format');
    }

    final map = data;

    // Handle success response structure
    if (map['success'] == true && map['data'] != null) {
      final dataMap = map['data'] as Map<String, dynamic>;
      return PopularSearches.fromJson(dataMap);
    }

    throw Exception('Invalid popular searches response format');
  }
}
