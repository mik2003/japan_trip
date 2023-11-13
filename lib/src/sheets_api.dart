import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/googleapis_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';


Future<List<List<Object?>>> getSheetData() async {
  const sheetId = '1Tv_bH1t-fGCh_8F-QrGd2shIVKbCExNS3RhMZ6b0UQg';
  const range = 'Main!C:D';
  const apiKey = 'AIzaSyBtdA6mFTTS7HyrtrmBt_imjeI0bwHie1M';

  final client = clientViaApiKey(apiKey);
  final sheetsApi = SheetsApi(client);
  final locations = await sheetsApi.spreadsheets.values.get(sheetId, range);

  return locations.values!;
}


GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    SheetsApi.spreadsheetsScope,
  ],
);

Future<void> _handleSignIn() async {
  try {
    await _googleSignIn.signIn();
  } catch (error) {
    print(error);
  }
}
