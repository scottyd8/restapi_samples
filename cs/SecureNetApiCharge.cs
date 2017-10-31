using System;
using System.Text;
using System.Web;
using System.Net;
using System.IO;
using System.Text.RegularExpressions;

public class Foo
{
    static void Main(string[] args)
    {
        string secureNetID = "8011012";
        string secureKey = "B5x1LwTHFaNn";
        string url = "https://gwapi.demo.securenet.com/api/payments/charge";
        string data = @"{
            'amount': 1.23,
            'card': {
                'number': '4111111111111111',
                'cvv': '123',
                'expirationDate': '07/2018',
            },
            'developerApplication': {
                'developerId': 12345678,
                'version': '1.2'
            }
        }";

        HttpWebRequest request = (HttpWebRequest) WebRequest.Create(url);
        string basicAuth = Convert.ToBase64String(ASCIIEncoding.ASCII.GetBytes(secureNetID + ":" + secureKey));
        request.Headers.Add("Authorization", "Basic " + basicAuth);
        request.Method = "POST";
        request.ContentType = "application/json";
        request.ContentLength = data.Length;

        using (Stream webStream = request.GetRequestStream())
        using (StreamWriter requestWriter = new StreamWriter(webStream, System.Text.Encoding.ASCII))
        {
            requestWriter.Write(data);
        }

        WebResponse webResponse = request.GetResponse();
        using (Stream webStream = webResponse.GetResponseStream())
        using (StreamReader responseReader = new StreamReader(webStream))
        {
            string response = responseReader.ReadToEnd();
            var m1 = Regex.Match(response, @"\""message\"":\""(.*?)\""");
            Console.WriteLine("message: {0}", m1.Groups[1].Value);
            var m2 = Regex.Match(response, @"\""transactionId\"":(.*?),");
            Console.WriteLine("transactionId: {0}", m2.Groups[1].Value);
        }
    }
}
