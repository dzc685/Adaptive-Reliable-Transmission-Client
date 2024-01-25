#!/bin/bash

# 定义网络接口
INTERFACE="tun2"

# 参数数组
#rates=("1mbit" "10mbit" "100mbit" "400mbit" "600mbit")
rates=("100mbit" "400mbit" "600mbit")
losses=("0%" "0.5%" "1%" "5%" "10%" "20%")
#losses=("0.5%")
delays=("10ms" "50ms" "100ms")
#delays=("10ms")

OUTPUT_FILE="iperf_bandwidth_results.txt"

# 清空之前的测试结果
> $OUTPUT_FILE

# 循环遍历所有组合
for rate in "${rates[@]}"
do
    for loss in "${losses[@]}"
    do
        for delay in "${delays[@]}"
        do
            echo "设置：带宽 $rate，丢包率 $loss，延迟 $delay"

            # 删除已存在的 tc 规则（如果有）
            sudo tc qdisc del dev $INTERFACE root 2> /dev/null

            # 添加新的 tc 规则
            sudo tc qdisc add dev $INTERFACE root netem delay $delay loss $loss rate $rate
            echo "规则已添加：延迟 $delay，丢包率 $loss，带宽 $rate"
            echo -n "rate: $rate, loss: $loss, delay: $delay, " >> $OUTPUT_FILE

            sleep 5
            # 运行 iperf3 测试
            echo "运行 iperf3 测试"
            iperf3 -c 2.8.0.1 -f k -t 120| awk '/sender$/ {sender_bandwidth=$7} /receiver$/ {receiver_bandwidth=$7} END {print "Sender Bandwidth: " sender_bandwidth " Kbits/sec, Receiver Bandwidth: " receiver_bandwidth " Kbits/sec"}' >> $OUTPUT_FILE
            #iperf3 -c 2.8.0.1 -f k

            # 删除 tc 规则
            sudo tc qdisc del dev $INTERFACE root
            echo "规则已删除"

            # 等待一段时间（例如5秒）在下一次迭代之前
            sleep 5
        done
    done
done

echo "操作完成"
