import 'package:googleapis_auth/auth_io.dart';

class GetServerKey {
  Future<String> servertoken() async {
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "insta-wash01",
          "private_key_id": "84ad0e3d6a55be661bc993162a1f6cdd8ba7fa45",
          "private_key":
              "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDOF4XFQmvIpKI1\n5ilyMC6vbU51pSMM7ZOswQ9nxfiFRys5DYy0CSHYrJUqCVH7ejOkicqK1NMqjPO5\nzQJS9QnLT8o5LB76DWl7MqC+fuLSQkdkq+e8/ChwxkSjM0+GE3dqHyjgKnrpgZGa\nSoY5jrytPnEGWYrofHGBBK3DdT6jiBgryxI6WTcKPALzgE+qBMQZUajVjMuOsJnU\nPjqWU4rgV2pJr3TiJ2jdoMA8+QPEnSb1/Xe+qrMGbaJDZVe0zFK90BrRahTx1Z9F\nZqEFhzxnihKAlnLiJjJLsKjSpFetHNbmeLG3trMdUcQnWUsk/GsY+mhUn9VElThk\n62jKGYT9AgMBAAECggEACkameyI3dRruYqEeDm1EGqeo2plYENA0xY+fyMUYge69\nQzw/eIefCip6yoyJ66/ZbNoZAQihGdVK3sgP1lqU+S/6jZS7W6z5BjVNSgpSHXlE\nDYs7xBLPomXkbL3FeJI2aVJx65F6rPNyst6F6E9LbZj4MkCbOkHgN/ZngqAxNh6f\naArNg9eE9u+0BVvPoCH3dPldNMoyBzDuSwebeAJdD1QSdKUi986/kSVdu9Qd7dTV\ntoRcEZbqiasX3w9M5NTmss+tGbl2c/UHXyhW9EUjgVYvyXHlQDRf0vQxJ/y6IheV\nzjVfDgw1aIVPeT9I16CO9M96AnQS8DCwNK0eqpyi4QKBgQDdbxTbhrdMzu/Vfa+Y\nI31bVvPfehzgKgjCBNJkig6+D0HTxnhk6AYB9SD/NWaAUgAHI4ZxmKZyqh1noBy5\nzQAlIrhHbs010Dl7Pd80nmHFraPSXmaGacPaW+mVNOhLtTDxqhb3nswURpS7Anha\nY9sjvz3HPRVHItzE9o2BiCtL4QKBgQDuQ1g4GbppbBxVfOESZ+jq6JJg74eXxc1Z\npQHXIrUExs+vaHlPjjLDsTcA/+gUy2mhhyJPiewwzZ+5DJmlH0J9p3EQPqEqnpXe\nBEzpzJxYRdxerSaG6ZPfYfp/xZ6UujrpJkaPn4GCZwuw3k/iZ8AR85rCvrwYUyTd\nKdTvkCt8nQKBgQCWNak3db5YKzSEZVs9YC3ETUrnuSVnZvxD6RNzwjdX9G+aIlM/\nWCnjIA7/MJFU0MtWDGJCIuQeeomx5uo1m/vSNSg+xMoODC9CC+mi/yGiADVWGlWA\nLrT+JkVgwuAlo0cNWG12ElGsG2j/JyDPaFeaezuEMUqC1AJg1kONr/p24QKBgQCU\nV2N+ki4oYsIFS5nJ3t36G1C/f4JZMTLX5E8QBbDUR3+Ywx/8MxlSE2yed7Wj9L1Q\nbxUilklyXSNbkAe88YhxOSXAqm2nXlMKhnzod5bDssMwQveguZ5yTssqb/x6trPk\n4wq9ct6sNMHnnZH48QV5Z8TsCNqM/n8OH3ROruEUVQKBgG9C1Q2ITQ6eTDN8kKpi\nAjFKKTcNlqZSkq7DPXYe73GXu5glcSWfJb3gzPGNMRYKtMWK+tt3/Kqipgj0hLQP\n0cQTyUDOkHKvLaILfWXhZQ/cKJEIm4Snuj2HVfo5S3RbSgGfMfepqcxhd6h6jKJc\nl3EJCrxQiP+AuVeZVk+5cVz/\n-----END PRIVATE KEY-----\n",
          "client_email":
              "firebase-adminsdk-41opz@insta-wash01.iam.gserviceaccount.com",
          "client_id": "107505909482166400287",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url":
              "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url":
              "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-41opz%40insta-wash01.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        scopes);
    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
}
