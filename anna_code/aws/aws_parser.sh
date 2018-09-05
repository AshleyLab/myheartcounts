#!/bin/bash
increment=10000
let end_section=$1+$increment
python aws_parser.py $1 $end_section declined
