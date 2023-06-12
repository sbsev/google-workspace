#!/bin/bash

GAM_EXC_PATH="/root/bin/gam/gam"

echo -n "Login"
read login

echo -n "Signature file path (defaults to board.html)"
read signPath

if [ ! -n "$signPath" ];
then
    signPath=/gmail/signatures/board.html
fi

echo -n "Firstname"
read firstName

echo -n "Lastname"
read lastName

echo -n "Department (defaults to BV)"
read department

if [ ! -n "$department" ];
then
    department="Bundesvorstand"
fi

echo -n "Jobtitle (e.g. IT)"
read jobTitle

$GAM_EXC_PATH user $login signature file $signPath html replace firstName $firstName replace lastname $lastName replace department $department replace jobtitle $jobTitle