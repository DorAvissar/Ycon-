#!/bin/bash
echo 'Hello from Assignment'
echo "Listing /home/user contents:"
ls -l /home/user
echo "About to run node on /home/user/docker-test.js"
exec node /home/user/docker-test.js
