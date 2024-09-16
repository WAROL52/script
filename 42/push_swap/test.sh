#!/bin/bash


if [ -f ./checker_linux ]; then
    echo -e "./checker_linux OK"
else
    wget https://cdn.intra.42.fr/document/document/27680/checker_linux
    chmod 777 ./checker_linux
fi

curl https://raw.githubusercontent.com/hu8813/tester_push_swap/main/pstester.py | python3 -
