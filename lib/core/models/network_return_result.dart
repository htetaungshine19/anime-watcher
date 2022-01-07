enum NetworkState { success, error }

class NetworkResult<T> {
  final NetworkState state;
  T data;
  NetworkResult({required this.state, required this.data});

  NetworkResult copyWith({
    NetworkState? state,
    T? data,
  }) {
    return NetworkResult(
      state: state ?? this.state,
      data: data ?? this.data,
    );
  }
}
