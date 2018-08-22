#!/bin/bash

mkdir todos

manifest=$1
ruby image_format_converter_make_todos.rb ${manifest} todos/
ruby image_format_converter_convert.rb todos/*.todo

rm -rf todos