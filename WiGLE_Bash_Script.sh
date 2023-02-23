#!/bin/bash

# Here's a brief overview of what this script does:
# 1. Set the API URL and pagination limit.
# 2. Set the initial searchAfter value to start pagination.
# 3. Set the initial output file number to 1.
# 4. Enter a loop that will continue until there are no more results.
# 5. Build the API URL with the current searchAfter value.
# 6. Make an API request using curl and save the output to a file with the current file number.
# 7. Parse the output JSON file to get the next searchAfter value.
# 8. Check if the searchAfter value is null, which indicates the end of the results.
# 9. If not null, increment the file number for the next iteration.
# 10. Repeat from step 5.
# 11. Convert all JSON outputs (output*.json) to concatted CSV with headers (output_concatted.csv)

# Set API URL and pagination limit (pagination limited at 100 & "ssidlike" is set to "wizardry" here)
API_URL="https://api.wigle.net/api/v2/network/search?onlymine=false&freenet=false&paynet=false&ssidlike=%25wizardry%25&resultsPerPage=100"

# Set initial searchAfter value (do a query yourself to get the first number, then insert it here)
searchAfter="############"

# Set initial output file number
file_num=1

# Loop until there are no more results
while true; do
  # Build API URL with searchAfter value
  url="$API_URL&searchAfter=$searchAfter"

  # Make API request and save output to file
  curl -X GET "$url" -H "accept: application/json" -u USER:PASS > "output$file_num.json"

  # Parse output JSON file for searchAfter value
  searchAfter=$(jq -r '.searchAfter' "output$file_num.json")

  # If theres no searchAfter value, weve reached the end of the results
  if [ "$searchAfter" == "null" ]; then
    break
  fi

  # Increment file number for next iteration
  ((file_num++))
  sleep 2
done

# jq command for parsing these results from JSON to CSV (with headers at top of CSV):
# jq -r '["trilat", "trilong", "ssid", "qos", "transid", "firsttime", "lasttime", "lastupdt", "netid", "name", "type", "comment", "wep", "bcninterval", "freenet", "dhcp", "paynet", "userfound", "channel", "encryption", "country", "region", "city", "housenumber", "road", "postalcode"], (.results[] | [.trilat, .trilong, .ssid, .qos, .transid, .firsttime, .lasttime, .lastupdt, .netid, .name, .type, .comment, .wep, .bcninterval, .freenet, .dhcp, .paynet, .userfound, .channel, .encryption, .country, .region, .city, .housenumber, .road, .postalcode]) | @csv' output*.json > output_concatted.csv
