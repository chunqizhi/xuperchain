main node

make

cd output

rm -rf data/keys/ data/netkeys/

./xchain-cli account newkeys -f

./xchain-cli netURL gen

vi conf/xchain.yaml

more data/keys/address

将 dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN 替换成现在的

vi data/config/xuper.json

将 dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN 两处替换成现在的

将 init_proposer_neturl 部分删除

加入一下内容以支持群组
"group_chain_contract": {
    "module_name": "wasm",
    "contract_name": "group_chain",
    "method_name": "list",
    "args":{}
},

将 nofee 设置为 true

cd core/contractsdk/cpp/

./build.sh

docker build -f Dockerfile.mainNode -t zfq17876911936/chaojigongshi-xuperchain-mainnode:1.0-nofee .

docker run -d --network test --name xchain -p 37101:37101 zfq17876911936/chaojigongshi-xuperchain-mainnode:1.0-nofee


other node

vi conf/xchain.yaml

将 main node 的 netURL 值加入 bootNodes 值中

先将 main node 的 netURL 为 "/ip4/127.0.0.1/tcp/47101/p2p/QmVjW3yDBCdoNFVQQh8jUyJd8fKnFRZdWKSnqJBTnUwNFm" 换成

"/dns4/xchain/tcp/47101/p2p/QmVjW3yDBCdoNFVQQh8jUyJd8fKnFRZdWKSnqJBTnUwNFm"

然后再替换

docker build -f Dockerfile.otherNode -t zfq17876911936/chaojigongshi-xuperchain-othernode:1.0-nofee .

docker run -d --network test --name other -P zfq17876911936/chaojigongshi-xuperchain-othernode:1.0-nofee


httpgw

docker build -f Dockerfile.httpgw  -t zfq17876911936/chaojigongshi-xuperchain-httpgw:1.0

docker run -d --network test --name httpgw -p 8098:8098 zfq17876911936/chaojigongshi-xuperchain-httpgw:1.0 -gateway_endpoint xchain:37101 -allow_cros true -enable_endorser true

curl http://localhost:8098/v1/get_block_by_height -d '{"bcname":"xuper", "height":10}'


group_chain

创建合约账号

./xchain-cli account new --account 1111111111111111

部署群组管理合约到 root 链

./xchain-cli wasm deploy --account XC1111111111111111@xuper -n group_chain ./group_chain.wasm

使 HelloChain 具备群组特性

./xchain-cli wasm invoke group_chain --method addChain -a '{"bcname":"HelloChain"}'

添加节点

./xchain-cli wasm invoke group_chain --method addNode -a '{"bcname":"HelloChain","ip":"/ip4/127.0.0.1/tcp/47103/p2p/QmT97cYTBFzvfqZGpGxuQ9WqakY2dW1npFckpkkAPAbEsW","address":"R6MPzRvnQZks2euhQepgo2buqSSYGNz1C"}'

vi createChain.json

{
    "Module": "kernel",
    "Method": "CreateBlockChain",
    "Args": {
        "name": "HelloChain",
        "data": "{\"version\": \"1\", \"consensus\": {\"miner\":\"dXQWJAXw9ZV2Q2oJMUs4cU15bG42uXCf3\", \"type\":\"single\"},\"predistribution\":[{\"address\": \"b2grdYq48pYJpBHFHYPSmucR7vpEm8hH3\",\"quota\": \"1000000000000000\"}],\"maxblocksize\": \"128\",\"period\": \"3000\",\"award\": \"1000000\",\"nofee\": true}"
    }
}

创建平行链
./xchain-cli transfer --to HelloChain --desc createChain.json


提案

vi myprop.json

{
 "module": "proposal",
 "method": "Propose",
 "args" : {
   "min_vote_percent": 51,
   "stop_vote_height": 80
 },
 "trigger": {
      "height": 88,
      "module": "consensus",
      "method": "update_consensus",
      "args" : {
          "name": "tdpos",
           "config": {
              "version":"2",
              "proposer_num":"3",
              "period":"3000",
              "term_gap":"6000",
              "alternate_interval":"6000",
              "term_interval":"9000",
              "block_num":"10",
              "vote_unit_price":"1",
              "init_proposer": {
                "1":["hPus3Ypw2qUPantUn68hQUKCRXq3wkMXz","nEWYf18DUKjPnCeCAraErbN8DdRzhy7H6","V4yKrVt1T66ygq1zVhLEBEJeLVEKWbJLF"]
              },
              "init_proposer_neturl": {
                "1": ["/ip4/172.21.0.2/tcp/47101/p2p/QmSRe1kPZXfAqePMaLpoAbDxPn75LpPLAwZy1j1QdzNatq", "/ip4/172.21.0.4/tcp/47101/p2p/QmPAnHg6E71LokxmjtsyWvM9bE6R3a7GRTEKS7RdYzvju2", "/ip4/172.21.0.5/tcp/47101/p2p/QmYALDeacczRQcsixJsLWX6X7akj4p8LaMcaLeWzcYha5g"]
              }
            }
      }
  }
}

./xchain-cli transfer --to `cat data/keys/address` --desc ./myprop.json

./xchain-cli vote --amount 80000000000000000000 --frozen 99 3e2f4fbfd2c607c3e84fab5bafab91cf034a3eecc235b013ddf0043b6a96f7c9

