# make and install  
``make``  
# run appclient  
``./app/appclient ip port data_size``  

# server: 
- 安装虚拟网卡:  
``cd server/tunnel && sudo sh tun.sh``   
- 编译:   
    ``cd server && make``  
    ``cd tunnel && make``
- 运行:  
    ``tcptunnel: cd server/tunnel && ./tcpserver``  
    ``udptunnel: cd server/tunnel && ./udpserver``  
    ``udttunnel: cd server/app && ./udtserver``   
- iperf3测试:  
    ``iperf3 -s --bind 2.8.0.1``  


# client: 
- 安装虚拟网卡:  
``cd client/tunnel && sudo sh tun.sh``   
- 修改以下代码中的ip地址为server绑定的ip:    
    ``client/tunnel/tcp_client.c``  
    ``client/tunnel/udp_client.c``  
    ``client/app/udtclient.c`` 
- 编译:   
    ``cd client && make``  
    ``cd tunnel && make``
- 运行:  
    ``tcptunnel: cd client/tunnel && ./tcpclient``  
    ``udptunnel: cd client/tunnel && ./udpclient``  
    ``udttunnel: cd client/app && ./udtclient``   
- iperf3测试:  
    ``iperf3 -c 2.8.0.1``  


- TC模拟网络环境：
sudo tc qdisc del dev tun1 root 
sudo tc qdisc add dev tun1 netem loss 10% rate 1mbit delay 10ms
sudo tc qdisc replace dev tun1 netem

sudo tc qdisc add dev enp0s8 netem loss 10%

sudo tc qdisc del dev enp0s8 root
sudo tc qdisc add dev enp0s8 root handle 1: htb default 10
sudo tc class add dev enp0s8 parent 1: classid 1:10 htb rate 100mbit
sudo tc qdisc add dev enp0s8 parent 1:10 handle 20: netem loss 20%

- iperf3以kbits显示
iperf -c 2.8.0.1 -f k
-u 测量udp

sudo tc qdisc add dev tun2 root netem delay 100ms loss 1%
sudo tc qdisc del dev tun2 root
sudo tc qdisc add dev tun2 root netem delay 100ms loss 1% rate 1mbit
sudo nmcli networking on
sudo bash tctest.sh