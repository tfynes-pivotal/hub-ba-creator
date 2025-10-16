#!/bin/bash
#!/usr/bin/env bash
GOOD_RESPONSE="HTTP/1.1 200 OK\r\nConnection: close\r\nContent-Length: 0\r\n\r\n${2:-"OK"}\r\n"
BAD_RESPONSE="HTTP/1.1 404 Not Found: url does not exist\r\nContent-Length: 0\r\nConnection: close\r\n\r\n${2:-"OK"}\r\n"

while 	{ 
	echo -en "$GOOD_RESPONSE"
	} | nc -l "${1:-8080}" ; do
  echo "================================================"
done