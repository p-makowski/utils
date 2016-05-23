#!/bin/bash

# Cleanup
ENVIRONMENT=$1

INSTANCES=$(aja project info -e $ENVIRONMENT -k instances)
FIRST_INSTANCE=$(echo $INSTANCES | grep -o "x[0-9]\{4,5\}")

echo "first: "$FIRST_INSTANCE

ADMIN_PASS=$(iec-adminpassword $FIRST_INSTANCE)
echo $ADMIN_PASS

exit 0;