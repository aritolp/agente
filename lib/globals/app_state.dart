import 'package:flutter/material.dart';
import 'package:tvplus/globals/themes.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:tvplus/models/lista_de_canales.dart';
import 'package:provider/provider.dart';

@NowaGenerated()
class AppState extends ChangeNotifier {
  AppState();

  factory AppState.of(BuildContext context, {bool listen = true}) {
    return Provider.of<AppState>(context, listen: listen);
  }

  ThemeData _theme = lightTheme;

  ThemeData get theme {
    return _theme;
  }

  int? _selectedChannelId;

  int? get selectedChannelId {
    return _selectedChannelId;
  }

  listaDeCanales? _selectedChannel;

  listaDeCanales? get selectedChannel {
    return _selectedChannel;
  }

  void changeTheme(ThemeData theme) {
    _theme = theme;
    notifyListeners();
  }

  void setSelectedChannelId(int? id) {
    _selectedChannelId = id;
    notifyListeners();
  }

  void setSelectedChannel(listaDeCanales? channel) {
    _selectedChannel = channel;
    if (channel != null) {
      _selectedChannelId = channel.id;
    }
    notifyListeners();
  }
}
