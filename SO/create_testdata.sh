#!/bin/bash

mkdir -p d6_test

cd d6_test
# ./d6_test/
mkdir -p a
mkdir -p b
mkdir -p .c
mkdir -p -- "rm -rf"
mkdir -p chmod

cd a
# ./d6_test/a/
touch hello..out
touch helloout
touch do_not_delete.txt

cd ../b
# ./d6_test/b/
mkdir -p bb
mkdir -p .bc

touch bb/maybe_delete.ou
touch bb/do.not.delete.me.out.
touch .bc/hello.123

cd ../.c
# ./d6_test/.c/
mkdir -p ...hello
touch ...hello/.im_hidden.out

cd ../rm\ -rf
touch remove_filesystem.out
touch do_nat_remove_me.ou
