#!/bin/bash

manifest=$1
docker exec -it imageformatconverter_image_format_converter_1 mkdir -p /usr/src/app/todos
docker cp ${manifest} imageformatconverter_image_format_converter_1:/usr/src/app/.
docker exec -it imageformatconverter_image_format_converter_1 bundle exec ruby image_format_converter_make_todos.rb ${manifest} todos/
docker exec -it imageformatconverter_image_format_converter_1 bash -c "bundle exec ruby image_format_converter_convert.rb todos/*.todo"