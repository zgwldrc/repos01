#!/bin/bash
:> target.sh
ls [0-9]*| sort -n | xargs -i -n1 cat \{\}   >> target.sh 
