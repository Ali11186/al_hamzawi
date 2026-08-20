import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class VodafoneService {
  static const String _configUrl =
      'https://alaarafeek5522-ai.github.io/card_vf_v1_config/config.json';

  static Future<Map<String, dynamic>> fetchRemoteConfig() async {
    try {
      final res = await http
          .get(
            Uri.parse(_configUrl),
            headers: {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
          )
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return {};
  }

  static Future<bool> isVodafoneNetwork() async {
    try {
      final res = await http.get(
        Uri.parse(
            'http://mobile.vodafone.com.eg/checkSeamless/realms/vf-realm/protocol/openid-connect/auth?client_id=ana-vodafone-app-seamless'),
        headers: {
          'User-Agent': 'okhttp/4.12.0',
          'clientId': 'AnaVodafoneAndroid',
          'x-agent-version': '2026.4.1',
          'x-agent-build': '1139',
          'digitalId': '24S0M31T0I9RK',
          'x-agent-device': 'Xiaomi M2101K9AG',
          'x-agent-operatingsystem': '13',
          'Accept-Language': 'ar',
          'Accept-Encoding': 'gzip',
        },
      ).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['msisdn'] != null;
      }
    } catch (_) {}
    return false;
  }

  static Future<Map<String, dynamic>> getSeamlessData() async {
    final res = await http.get(
      Uri.parse(
          'http://mobile.vodafone.com.eg/checkSeamless/realms/vf-realm/protocol/openid-connect/auth?client_id=ana-vodafone-app-seamless'),
      headers: {
        'User-Agent': 'okhttp/4.12.0',
        'Connection': 'Keep-Alive',
        'Accept-Encoding': 'gzip',
        'x-agent-operatingsystem': '13',
        'clientId': 'AnaVodafoneAndroid',
        'Accept-Language': 'ar',
        'x-agent-device': 'Xiaomi M2101K9AG',
        'x-agent-version': '2026.4.1',
        'x-agent-build': '1139',
        'digitalId': '24S0M31T0I9RK',
      },
    );
    return jsonDecode(res.body);
  }

  static Future<String?> getAccessToken(String seamlessToken) async {
    final res = await http.post(
      Uri.parse(
          'https://mobile.vodafone.com.eg/auth/realms/vf-realm/protocol/openid-connect/token'),
      headers: {
        'User-Agent': 'okhttp/4.12.0',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Encoding': 'gzip',
        'seamlessToken': seamlessToken,
        'x-agent-operatingsystem': '13',
        'clientId': 'AnaVodafoneAndroid',
        'Accept-Language': 'ar',
        'x-agent-device': 'Xiaomi M2101K9AG',
        'x-agent-version': '2026.4.1',
        'x-agent-build': '1139',
        'digitalId': '24S0M31T0I9RK',
      },
      body: {
        'grant_type': 'password',
        'client_secret': 'b86e30a8-ae29-467a-a71f-65c73f2ff5e3',
        'client_id': 'cash-app',
      },
    );
    return jsonDecode(res.body)['access_token'];
  }

  static Future<Map<String, dynamic>> chargeCard({
    required String productId,
    required String receiver,
    required String pin,
    required String senderMsisdn,
    required String accessToken,
    required double price,
  }) async {
    final requestId = const Uuid().v4().replaceAll('-', '');
    final digitalId = '2991T3UY1XA${const Uuid().v4().toString().substring(0, 4).toUpperCase()}';
    
    final senderMsisdnWithZero = senderMsisdn.startsWith('0') ? senderMsisdn : '0$senderMsisdn';
    final receiverWithZero = receiver;

    final payload = {
      "payment": [
        {
          "characteristics": [
            {
              "name": "authorizationCode",
              "value": pin
            },
            {
              "name": "digitalTransactionId",
              "value": digitalId
            }
          ],
          "@type": "digitalWallet"
        }
      ],
      "productOrderItem": [
        {
          "action": "insert",
          "characteristics": [
            {
              "name": "MSISDN",
              "@type": "receiver",
              "value": receiverWithZero
            },
            {
              "name": "MSISDN",
              "@type": "sender",
              "value": senderMsisdnWithZero
            }
          ],
          "itemTotalPrice": [
            {
              "price": {
                "taxIncludedAmount": {
                  "unit": "EGP",
                  "value": price
                }
              }
            }
          ],
          "product": {
            "id": productId,
            "productCharacteristic": [],
            "type": "product"
          }
        }
      ],
      "@type": "paymentFakka"
    };

    final res = await http.post(
      Uri.parse('https://mobile.vodafone.com.eg/services/dxl/orderor/productOrder'),
      headers: {
        'User-Agent': 'okhttp/4.12.0',
        'Connection': 'close',
        'Accept': 'application/json',
        'Accept-Encoding': 'gzip',
        'X-Request-ID': requestId,
        'X-App-StackTrace': '',
        'device-id': 'd26ba4b35efd709d',
        'api-version': 'v2',
        'msisdn': senderMsisdnWithZero,
        'Authorization': 'Bearer $accessToken',
        'Accept-Language': 'ar',
        'x-agent-operatingsystem': '13',
        'x-agent-device': 'Xiaomi M2101K9AG',
        'x-agent-version': '2026.4.1',
        'x-agent-build': '1139',
        'digitalId': digitalId,
        'clientId': 'AnaVodafoneAndroid',
        'X-Network-StackTrace': 'Proceeding with request#createService called with service#Retrofit instance created for service#service created#createService called with service#Retrofit instance created for service#service created#Interceptor started for request#Building request for URL#Added X-Request-ID#Fetched new token#Building token headers for MSISDN#Adding DXL headers#Finished building request',
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(payload),
    );
    return jsonDecode(res.body);
  }
}
