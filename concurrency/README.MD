# Concurrency

Elasticsearch uses an optmistic approach to deal with Concurrency. It means that by default It does not uses locks to guarantee consistency, instead It forces coonsumers to retry in case a document is updated at the same time. 

Every document on Elasticsearch has two attributes:
1. _seq_no: A sequencial number a document has. Every time a document is updated, this number increases
2. _primary_shard: the primary shard that owns the document and will deal with any changes on that.

These both attributes can be used to guarantee a consistent update even when thare concorrent threads trying to update  a single document at once. 
When sending these both attributes on the request payload, Elasticsearch will guarantee that if some of these values were changed by another thread at the same time, the write operation being requested is gonna fail.

Consider the folowing example: there is this document indexed with several attributes:

```
curl -XGET -H "Content-Type: application/x-ndjson" localhost:9200/series/_doc/122886 | jq .
```

This request returns the following response:

```
{
  "_index": "series",
  "_type": "_doc",
  "_id": "122886",
  "_version": 1,
  "_seq_no": 7,
  "_primary_term": 1,
  "_routing": "1",
  "found": true,
  "_source": {
    "id": "122886",
    "film_to_franchise": {
      "name": "film",
      "parent": "1"
    },
    "title": "Star Wars: Episode VII - The Force Awakens",
    "year": "2015",
    "genre": [
      "Action",
      "Adventure",
      "Fantasy",
      "Sci-Fi",
      "IMAX"
    ]
  }
}

``` 

Now, lets try to update that same document, but sending a different value on the sequence number.

```
curl -XPUT -H "Content-Type: application/x-ndjson" "localhost:9200/series/_doc/122886?if_seq_no=6&if_primary_term=1" -d ' 
{
    "title": "new Title"
}' 
```

The following response is received from the server:

```
{
  "error": {
    "root_cause": [
      {
        "type": "version_conflict_engine_exception",
        "reason": "[122886]: version conflict, required seqNo [6], primary term [1]. current document has seqNo [7] and primary term [1]",
        "index_uuid": "HW8CTa4iTnq5xpm5c0taFQ",
        "shard": "0",
        "index": "series"
      }
    ],
    "type": "version_conflict_engine_exception",
    "reason": "[122886]: version conflict, required seqNo [6], primary term [1]. current document has seqNo [7] and primary term [1]",
    "index_uuid": "HW8CTa4iTnq5xpm5c0taFQ",
    "shard": "0",
    "index": "series"
  },
  "status": 409
}

```

That is because the seq_no is different then It currently was when requesting the server to update. This way, Elasctiserch can protect Its data even when two records are trying to update the same document at the same time.

