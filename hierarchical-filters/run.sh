#!/bin/bash

docker-compose up -d

sleep 5

curl -XPUT --header "Content-Type: application/json" localhost:9200/series -d '  
{
    "mappings": {
        "properties": {
            "film_to_franchise": {
                "type": "join",
                "relations": {"franchise": "film"}
            }
        }
    }
}'

curl -s -H "Content-Type: application/x-ndjson" -XPOST localhost:9200/_bulk --data-binary @series.json


# Playing with the dataset. Search for all movies that belong to the franchise starwars
curl -XGET -H "Content-Type: application/x-ndjson" localhost:9200/series/_search -d '
{
    "query": {
        "has_parent":  {
            "parent_type": "franchise",
            "query": {
                "match": {
                    "title": "Star Wars"
                }
            } 
        }
    }
}'


# Playing with the dataset. Search for franchises that has the film "The Force Awakens"
curl -XGET -H "Content-Type: application/x-ndjson" localhost:9200/series/_search -d '
{
    "query": {
        "has_child":  {
            "type": "film",
            "query": {
                "match": {
                    "title": "The Force Awakens"
                }
            } 
        }
    }
}'