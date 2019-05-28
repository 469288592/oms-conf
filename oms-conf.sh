#!/bin/bash
#author:xuncetech.com

regex="\b(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\b"
ckStep1=`echo $1 | egrep $regex | wc -l`

if [ $# -ne 1 ];then
    echo -e "\033[31m [错误] 脚本需要传一个参数，参数为机器内网地址\033[0m"
    exit 1;
else
    if [ $ckStep1 -eq 0 ];then
        echo -e "\033[31m [错误] IP地址不符合规则，请重新输入\033[0m"
        exit 2;
    fi
fi

function NGINX_CONF(){
    IP=$1
    CONF=`ls /etc/nginx/conf.d | grep -v "upstream"`
    for nginx_name in $CONF
    do
    sed -i "s/192.168.0.28/${IP}/" /etc/nginx/conf.d/$nginx_name
    done
    /sbin/nginx -s reload
}

function PHP_CONF(){
    IP=$1
    CONF=`ls /data/config/rel/app`
    for php_name in $CONF
    do
    sed -i "s/192.168.0.28/${IP}/" /data/config/rel/app/$php_name
    done
}

function NODE_CONF(){
    IP=$1
    CONF=`ls /data/www/xc-live-tunnel/etc`
    for node_name in $CONF
    do
    sed -i "s/192.168.0.28/${IP}/" /data/www/xc-live-tunnel/etc/$node_name
    done
    sudo -H -u nginx bash  -c "cd /data/www/xc-live-tunnel&&/usr/bin/pm2 start etc/process.yaml" 
}

function REDIS_CONF(){
    IP=$1
    CONF=`ls /data/redis/conf`
    for redis_name in $CONF
    do
    sed -i "s/192.168.0.28/${IP}/" /data/redis/conf/$redis_name
    done
    systemctl restart redis-6380.service
    systemctl restart redis-6381.service
}

function main(){
    IP=$1
    REDIS_CONF $IP
    PHP_CONF $IP 
    NODE_CONF $IP
    NGINX_CONF $IP
}
main $*

