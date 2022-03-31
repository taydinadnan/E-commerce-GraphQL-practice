import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

//query as a string in a variable
const productsGraphQL = """
query products {
  products(first: 10, channel: "default-channel") {
    edges {
      node {
        id
        name
        description
        thumbnail {
          url
        }
      }
    }
  }
}
""";

void main() {
  final HttpLink httpLink = HttpLink("https://demo.saleor.io/graphql/");

//configure GraphQLClient
  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(
        store: InMemoryStore(),
      ),
    ),
  );

//provide client to the app
  var app = GraphQLProvider(
    child: const MyApp(),
    client: client,
  );
  runApp(app);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Query(
        options: QueryOptions(document: gql(productsGraphQL)),
        builder: (QueryResult result, {fetchMore, refetch}) {
          //if exception occurs
          if (result.hasException) {
            return Text(result.exception.toString());
          }
          //data loading
          if (result.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final productList = result.data?['products']['edges'];

          //if data loaded display it
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Products",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              Expanded(
                child: GridView.builder(
                  itemCount: productList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 2.0,
                    mainAxisSpacing: 2.0,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (_, index) {
                    var product = productList[index]['node'];
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          width: 180,
                          height: 180,
                          child: Image.network(
                            product['thumbnail']['url'],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            product['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Text('\$4,50'),
                      ],
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
