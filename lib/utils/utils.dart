import 'package:geepay_pos/utils/config.dart';

export 'constants.dart';
export 'enums.dart';
export 'functions.dart';
export 'reusable_animations.dart';
export 'screen_size.dart';

const kAppStoreId = '1609047449';

// const baseUrl = 'http://95.179.210.39'; // production
// String baseUrl = 'http://${Config.dev().host}'; // uat
Config? config;
// final socket = SocketSource.init(config!.socketUrl, alwaysConnected: true);

String baseUrl = 'http://${Config.dev().host}'; // uat
