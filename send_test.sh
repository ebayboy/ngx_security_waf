#!/bin/bash

#403 forbidden
curl -i http://localhost/foo?testparam=dalongtest

#200 OK
#curl -i http://localhost/foo?testparam=dalong
