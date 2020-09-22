# Rasp-VPN-CustomFW

#### Description ####
I share this repo since I faced some problems deploing the openvpn server with the redirect-gateway config set to have client that redirect all the traffic to the VPN, in particular I run the openvpn server on a Raspberry PI beyond a private router this generated some problems managing network packets, and made necesary the second iptables rule, that despite the first was not so well documented. 
This Repo contains all the configurations needed to start an openvpn server that makes the client redirect all the traffic through the VPN when connected. 
It does not contain the security files that must be create with a Public Key Infrastructure.  



#### These are the steps to deploy the solution ####
1. Clone the repo
2. Install OpenVpn and iptables (depending on the your OS you can use: `sudo apt-get install openvpn iptables`, or `sudo yum install openvpn iptables`, etc..)
3. Create a link to the custom_fw service in /etc/systemd/system (`ln -s $pwd/custom_fw.service /etc/systemd/system/custom_fw.service`)
4. Either change your openvpn service definition, or overwrite the standard file with the one in the repo. I've added/modified the following configurations:
    * After=custom_fw.service
    * Wants=custom_fw.service
    * WorkingDirectory=/etc/openvpn/server
    * Restarts=on-failure
    * ExecStart=/usr/sbin/openvpn --config %i.conf --auth-nocache 
5. Eventually change the server.conf according with your preferences. Pay attention to:
    * Protocol exposed (I'changed the default from udp to tcp)
    * The networks used and the ip assigned to the openvpn server.
    * The maxclient that in my case is set to 3. 
    * The askpass to avoid the password prompt
    * The config pushed to the clients, in my case the redirect-gateway makes the client to redirect toward the VPN all the network traffic. This config makes necessary one of the iptables rule (the FORWARD one)
6. Eventually change the POSTROUTING rule according to the subnet choosen as vpn and defined in the server.conf file. 
7. Move/Link the server.conf file in the /etc/openvpn/server/ dir (`ln -s $pwd/server.conf /etc/openvpn/server/server.conf`)
8. Create the files needed by the openvpn server:
    * ca.key
    * server.key
    * server.crt
    * dh2048.pem 
    * auth.txt
9. Submit the command: `systemctl daemon-reload`

#### These are the commands to start the OpenVPN server ####
If everything is ok you can start the openvpn server with the command:

- `systemctl start openvpn-server@server` 

After that you can check that both the services created are active with the commands: 

- `systemctl status custom_fw.service` 
- `systemctl status openvpn-server@server`

#### Config of the clients ####
Since I found preferable to push the client config from the server the client.conf remained the same, but the protocol and the references to the openvpn server.

##### This version of the repo is vulnerable to man in the middle as described at http://openvpn.net/howto.html#mitm more config are needed to avoid this risk, but seems well documented. 
