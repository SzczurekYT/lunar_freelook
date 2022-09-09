enum NetworkState {
  handshaking(-1),
  play(0),
  status(1),
  login(2);

  final int id;
  const NetworkState(this.id);

  static NetworkState byId(int id) {
    switch (id) {
      case (-1):
        return NetworkState.handshaking;
      case (0):
        return NetworkState.play;
      case (1):
        return NetworkState.status;
      case (2):
        return NetworkState.login;
    }
    throw Exception("Network state out of range!");
  }
}
