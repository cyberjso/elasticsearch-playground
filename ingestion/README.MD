# Index Mappings

The basics to create indexes on Elasticsearch


Add an index mapping an year field using date type:

```
curl -XPUT --header "Content-Type: application/json" localhost:9200/movies -d '  
{
    "mappings": {
        "properties": {
            "year": {
                "type": "date"
            }
        }
    }
}'

```

Query the and ensure mapping went all right

```
curl localhost:9200/movies/_mapping 
```

## Single record ingestion

Add a document using the index created. By default, fields are ingested as string except the date field specified when creating the index.

```
curl -XPOST --header "Content-Type: application/json" localhost:9200/movies/_doc/109487 -d '  
{
    "genre": ["IMAX", "Sci-Fi"], 
    "title": "Interstellar", 
    "year": 2014
}'
```

Query the index and check the ingested document

``` 
curl localhost:9200/movies/_search
```

## Bulk Ingestion

Bulk ingestion is a technique to ingest several documents in batch rather than document by document.

```
curl -XPOST --header "Content-Type: application/json" localhost:9200/_bulk --data-binary @movies.json
```

Query the index and check the ingested documents

``` 
curl localhost:9200/movies/_search
```

