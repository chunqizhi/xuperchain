main node

make

cd output

rm -rf data/keys/ data/netkeys/

./xchain-cli account newkeys -f

./xchain-cli netURL gen

vi conf/xchain.yaml

将 dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN 替换成现在的

vi data/config/xuper.json

将 dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN 两处替换成现在的

将 init_proposer_neturl 部分删除

cd core/contractsdk/cpp/

./build.sh

docker build -f Dockerfile.mainNode -t zfq17876911936/chaojigongshi-xuperchain-mainnode:1.0 .

docker run -d --network test --name xchain zfq17876911936/chaojigongshi-xuperchain-mainnode:1.0


other node

vi conf/xchain.yaml

将 main node 的 netURL 值加入 bootNodes 值中

先将 main node 的 netURL 为 "/ip4/127.0.0.1/tcp/47101/p2p/QmVjW3yDBCdoNFVQQh8jUyJd8fKnFRZdWKSnqJBTnUwNFm" 换成

"/dns4/xchain/tcp/47101/p2p/QmVjW3yDBCdoNFVQQh8jUyJd8fKnFRZdWKSnqJBTnUwNFm"

然后再替换

docker build -f Dockerfile.otherNode -t zfq17876911936/chaojigongshi-xuperchain-othernode:1.0 .

docker run -d --network test --name other zfq17876911936/chaojigongshi-xuperchain-othernode:1.0


httpgw

docker build -f Dockerfile.httpgw  -t zfq17876911936/chaojigongshi-xuperchain-httpgw:1.0

docker run -d --network test --name httpgw -p 8098:8098 zfq17876911936/chaojigongshi-xuperchain-httpgw:1.0 -gateway_endpoint xchain:37101 -allow_cros true -enable_endorser true

curl http://localhost:8098/v1/get_block_by_height -d '{"bcname":"xuper", "height":10}'
