#!/bin/bash
if ! test -d ./data/blockchain/xuper; then
  ./xchain-cli createChain
  ./xchain-cli account newkeys -f
  ./xchain-cli netURL gen
fi
./xchain
