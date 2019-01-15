#!/bin/bash
rm stats.txt

echo 'Number of chapters:' >> stats.txt
ack-grep --markdown '^\\label\{sec' -c -l chapters | grep -o '[0-9]\+' | awk '{ SUM += $1 } END { print SUM }' >> stats.txt

echo 'Number of info boxes:' >> stats.txt
ack-grep --markdown '\\begin\{aside\}' -c -l chapters | grep -o '[0-9]\+' | awk '{ SUM += $1 } END { print SUM }' >> stats.txt

echo 'Number of images:' >> stats.txt
ack-grep --markdown '\(images' -c -l chapters | grep -o '[0-9]\+' | awk '{ SUM += $1 } END { print SUM }' >> stats.txt

echo 'Number of footnotes:' >> stats.txt
ack-grep --markdown '^\[\^' -c -l chapters | grep -o '[0-9]\+' | awk '{ SUM += $1 } END { print SUM }' >> stats.txt

echo '--------------' >> stats.txt
echo 'Number of css codesnippets' >> stats.txt
ack-grep --markdown -i '```css' -c -l chapters | grep -o '[0-9]\+' | awk '{ SUM += $1} END { print SUM }' >> stats.txt

echo '--------------' >> stats.txt
echo 'Number of html codesnippets' >> stats.txt
ack-grep --markdown -i '```html' -c -l chapters | grep -o '[0-9]\+' | awk '{ SUM += $1} END { print SUM }' >> stats.txt

echo '--------------' >> stats.txt
echo 'Number of sh codesnippets' >> stats.txt
ack-grep --markdown -i '```sh' -c -l chapters | grep -o '[0-9]\+' | awk '{ SUM += $1} END { print SUM }' >> stats.txt

echo '--------------' >> stats.txt
echo 'Number of ruby codesnippets' >> stats.txt
ack-grep --markdown -i '```ruby' -c -l chapters | grep -o '[0-9]\+' | awk '{ SUM += $1} END { print SUM }' >> stats.txt

echo '--------------' >> stats.txt
echo 'Number of javascript codesnippets' >> stats.txt
ack-grep --markdown -i '```javascript' -c -l chapters | grep -o '[0-9]\+' | awk '{ SUM += $1} END { print SUM }' >> stats.txt

