#!/bin/bash

gcc -Wall -Wextra -g example1.c libinjection_sqli.c  

./a.out "-1' and 1=1 union/* foo */select load_file('/etc/passwd')--"
