#!/bin/bash
if ! test -d ./data/blockchain/xuper; then
	./xchain-cli createChain
fi
./xchain
