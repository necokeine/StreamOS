#!/usr/bin/env bash

function run_bochs() {
	bochs -f scripts/bochs.cfg -q
}
