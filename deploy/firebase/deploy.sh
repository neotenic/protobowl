#!/bin/bash

cp -r ../../build/release/* public/
# cp ../nfsn/index.html public/
firebase deploy


curl -X POST "https://api.cloudflare.com/client/v4/zones/3c3c51b14a50ddd360f112a25504b1ae/purge_cache" \
     -H "Authorization: Bearer i6m4nH4ePe4hbTiYFpNMqFAcBOep1IFN27DmlHxo" \
     -H "Content-Type: application/json" \
     --data '{"purge_everything":true}'