#!/bin/bash

DIR="$(mktemp -d)"
claat export -o $DIR walkthrough.md

cp -r $DIR/sym_lambda_quickstart/ ../docs
