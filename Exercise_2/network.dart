sealed class NetworkState {}

class Loading extends NetworkState {}

class Success extends NetworkState {
  final String data;
  Success(this.data);
}

class Error extends NetworkState {
  final String message;
  Error(this.message);
}

void handleState(NetworkState state) {
  switch (state) {
    case Loading():
      print('Loading...');
    case Success():
      print('Success: ${state.data}');
    case Error():
      print('Error: ${state.message}');
  }
}

void main() {
  List<NetworkState> states = [
    Loading(),
    Success('User data loaded'),
    Error('Network timeout'),
  ];

  for (var state in states) {
    handleState(state);
  }
}