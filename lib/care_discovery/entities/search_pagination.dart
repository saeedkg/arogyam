class SearchPagination {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  SearchPagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory SearchPagination.fromJson(Map<String, dynamic> json) {
    return SearchPagination(
      currentPage: json['current_page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      total: json['total'] ?? 0,
      lastPage: json['last_page'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'per_page': perPage,
      'total': total,
      'last_page': lastPage,
    };
  }

  bool get hasMorePages => currentPage < lastPage;
}
