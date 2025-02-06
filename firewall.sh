#!/bin/sh

# DIHE Firewall Rule for backup server  

IPT="iptables"

# Flush old rules, old custom tables
$IPT --flush
$IPT --delete-chain

# Set default policies for all three default chains
$IPT -P INPUT DROP
$IPT -P FORWARD DROP
$IPT -P OUTPUT ACCEPT

# Enable free use of loopback interfaces
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT

# All TCP sessions should begin with SYN
$IPT -A INPUT -p tcp ! --syn -m state --state NEW -s 10.0.0.0/8 -j DROP
$IPT -A INPUT -p tcp ! --syn -m state --state NEW -s 172.28.0.0/16 -j DROP
$IPT -A INPUT -p tcp ! --syn -m state --state NEW -s 172.29.0.0/16 -j DROP
$IPT -A INPUT -p tcp ! --syn -m state --state NEW -s 192.168.0.0/24 -j DROP

# Accept inbound TCP packets
$IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#FTP ip which are allow 
#$IPT -A INPUT -p tcp --dport 21 -m state --state NEW -m iprange --src-range 192.168.56.9-192.168.56.30 -j ACCEPT

#SSH for BCA Staffs
#$IPT -A INPUT -p tcp --dport 22 -m state --state NEW -m iprange --src-range 192.168.56.9-192.168.56.30  -j ACCEPT
$IPT -A INPUT -p tcp --dport 22 -m state --state NEW -s 192.168.56.81 -j ACCEPT #Karma BCA  
$IPT -A INPUT -p tcp --dport 22 -m state --state NEW -s 192.168.56.171 -j ACCEPT #Jampa BCA  
$IPT -A INPUT -p tcp --dport 22 -m state --state NEW -s 192.168.56.123 -j ACCEPT #Samdup BCA 

#SMTP For BCA Staffs 
$IPT -A INPUT -p tcp --dport 25 -m state --state NEW -m iprange --src-range 192.168.56.9-192.168.56.30 -j ACCEPT
$IPT -A INPUT -p tcp --dport 25 -m state --state NEW -s 192.168.56.81 -j ACCEPT #Tsetan la
$IPT -A INPUT -p tcp --dport 25 -m state --state NEW -s 192.168.56.82 -j ACCEPT #Rinchen la



#HTTP which are allow 
#$IPT -A INPUT -p tcp --dport 80 -m state --state NEW -m iprange --src-range 192.168.56.9-192.168.56.30 -j ACCEPT

#VPN
#$IPT -A INPUT -p tcp --dport 80 -m state --state NEW -s 10.81.234.0/24 -j ACCEPT #new vpn

#HTTP Access for BCA Staffs
$IPT -A INPUT -p tcp --dport 80 -m state --state NEW -s 192.168.56.10 -j ACCEPT #Tashi la
$IPT -A INPUT -p tcp --dport 80 -m state --state NEW -s 192.168.56.11 -j ACCEPT #Kunsang la
$IPT -A INPUT -p tcp --dport 80 -m state --state NEW -s 192.168.56.12 -j ACCEPT #kelsang la


##FOR BCOM Staffs

$IPT -A INPUT -p tcp --dport 80 -m state --state NEW -s 192.168.56.32 -j ACCEPT #For Dolma la 
$IPT -A INPUT -p tcp --dport 80 -m state --state NEW -s 192.168.56.33 -j ACCEPT #For Choekyi la 
$IPT -A INPUT -p tcp --dport 80 -m state --state NEW -s 192.168.56.34 -j ACCEPT #For Choedon la 
$IPT -A INPUT -p tcp --dport 80 -m state --state NEW -s 192.168.56.81 -j ACCEPT #BCA staff

# Accept inbound ICMP messages
$IPT -A INPUT -p ICMP --icmp-type 8 -s 192.168.56.81 -j ACCEPT #SHERAB BCA staff
$IPT -A INPUT -p ICMP --icmp-type 8 -s 1192.168.56.171 -j ACCEPT  #TASHI  BCA staff
$IPT -A INPUT -p ICMP --icmp-type 8 -s 192.168.56.123 -j ACCEPT  #SAMDUP  BCA staff
$IPT -A INPUT -p ICMP --icmp-type 8 -s 10.81.234.1/24 -j ACCEPT  #new vpn


