#! /bin/sh

rm -rf Debug
rm -rf */Debug
rm -f */*.user

cp -a sf_decrunch "$1"
mv "$1/sf_decrunch.vcxproj" "$1/$1.vcxproj"
mv "$1/sf_decrunch.vcxproj.filters" "$1/$1.vcxproj.filters"
