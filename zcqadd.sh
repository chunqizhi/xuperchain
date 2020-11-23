#!/bin/bash
# Usage
# ./zcqadd.sh 3
# ./zcqadd.sh 3 192.168.40.136
i=1
a=3
if test -n "$1"; then
	a=$1
fi
echo "创建 ${a} 个节点的联盟链"
# 配置 ${a} 个节点的联盟链
while (( ${i}<=${a} ))
do
	mkdir node${i}
	cp -r output/* node${i}/
	rm -rf node${i}/data/keys node${i}/data/netkeys
	let i++
done


j=1
# 生成 ${a} 个节点的账号和P2P节点地址
while (( ${j}<=${a} ))
do
	echo "===================node"${j}"==================="
	cd node${j}
	./xchain-cli account newkeys -f
	sleep 1
	./xchain-cli netURL gen
	cd -
	let j++
done


k=1
# 获取 ${a} 个节点的账号地址
while (( ${k}<=${a}))
do
	addr=`more node${k}/data/keys/address`
	array_addrs[${k}]=`echo \"${addr}\"`
	let k++
done
# 修改预分配地址
sed -i "s/\"address\": \"dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN\"/\"address\": ${array_addrs[1]}/" node1/data/config/xuper.json
as=`echo ${array_addrs[*]}`
allAddrs=`echo ${as// /,}`
# 修改初始挖矿节点
sed -i "s/\"dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN\"/${allAddrs}/" node1/data/config/xuper.json
# 修改 proposer_num 的值
sed -i "s/\"proposer_num\": \"1\"/\"proposer_num\": \"${a}\"/" node1/data/config/xuper.json
# 是否是无币区块链
sed -i "s/\"nofee\": false/\"nofee\": true/" node1/data/config/xuper.json
p=1
# 删除创世区块文件的 init_proposer_neturl 部分
while (( ${p}<=5 ))
do
	sed -i '37d' node1/data/config/xuper.json
	let p++
done

# 支持群组合约
sed -i "/new_account_resource_amount/a\\    \"group_chain_contract\": {\n        \"module_name\": \"wasm\",\n        \"contract_name\": \"group_chain\",\n        \"method_name\": \"list\",\n        \"args\":{}\n    }," node1/data/config/xuper.json

o=2
# 公用创建区块文件
while (( ${o}<=${a} ))
do
	cp node1/data/config/xuper.json node${o}/data/config
	let o++
done

k=2
# 单机多实例的时候修改端口
while (( ${k}<=${a} ))
do
	sed -i "s/37101/3710${k}/" node${k}/conf/xchain.yaml
	sed -i "s/37200/3720${k}/" node${k}/conf/xchain.yaml
	sed -i "s/47101/4710${k}/" node${k}/conf/xchain.yaml
	let k++
done

# 获取第一个节点的 p2p 地址
cd node1
node1=`./xchain-cli netURL preview`
node1=`echo \"${node1}\"`
if test -n "$2"; then
	node1=${node1/127.0.0.1/$2}
fi
cd -
k=2
# 增加其他节点的 bootNodes 节点
while (( ${k}<=${a} ))
do
	sed -i "s! #bootNodes:! bootNodes:\n    - ${node1}!" node${k}/conf/xchain.yaml
	let k++
done

#exit

# 本地测试
# 1.先启动 node1
# 2.再启动其他节点
cd node1
./xchain-cli createChain > /dev/null 2>&1
sleep 1
nohup ./xchain > node1.log 2>&1 &
cd -

k=2
while (( ${k}<=${a} ))
do
	cd node${k}
	./xchain-cli createChain > /dev/null 2>&1
	sleep 1
	nohup ./xchain > node${k}.log 2>&1 &
	sleep 1
	cd -
	let k++
done
