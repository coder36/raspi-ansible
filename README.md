Set of ansible playbooks for setting up a raspberry pi.

* openvpn with google authenticator
* dev environment

# Pre-requisites
* vanilla install of Raspbian  (You should be able to login using pi/raspberry)


# Ansible setup
To keep things simple, we're going to install directly onto the pi. Ansible is not available in the pi apt 
repositories, so we'll install it using pip:


Log in with pi/raspberry

    ssh-keygen    (go with defaults and no password)
    sudo apt-get update
    sudo apt-get install python-dev python-pip sshpass git
    sudo pip install ansible
    git clone https://github.com/coder36/raspi-ansible.git
    cd raspi-ansible


## bootstrap

The bootstrap playbook will install an ansible user, and give it the appropriate sudoers rights.

    cd ~/raspi-ansible
    ansible-playbook -i live bootstrap.yml -k     (provide password for pi user)

From here on in, you will not need to provide a password.  You have created effectively an ansible server, with the pi itself acting
as a ansible node.





# Dev tools

Installs tmux, vim, zsh and git

    ansible-playbook -i live dev-tools.yml




# Openvpn

The openvpn playbook is configured to use 2 factor authentication using the google authenticator PAM module, so its about as secure as you can get. Once the client has connected, they should have full visiblity of the home local network.   As it uses UDP, it should be fairly stable.  Once you have vpn'ed in to your home network you can:

  * Use Remote Desk Top
  * ssh (it's much more stable over UDP)
  * Remotely administer your home router


## live inventory

Edit the `live` inventory file, to include your home network specifics:

    [pi]
    127.0.0.1 local_lan="192.168.101.0" local_lan_mask="255.255.255.0" vpn_lan="10.8.0.0" vpn_lan_mask="255.255.255.0"

* The local_lan will be made available on the machine connected by the VPN.
* The vpn_lan is the subnet range, which will be allocated to each of the vpn clients.



## Certs and private keys

You can use the certs and keys provided, however you should really generate your own.  

Place your certs into `/home/vagrant/playbooks/roles/vpn-server/templates/etc/openvpn`, and also generate a new Diffie hellman parameter using:  'openssl dhparam -out dh1024.pem 1024'   

I found a really good [windows utility](http://sourceforge.net/projects/xca) for generating signed certs.


## Apply the vpn playbook

  cd ~/raspi-ansible
  ansible-playbook -i live vpn.yml


This will create a client config file: `/etc/openvpn/client.ovpn` which can be imported directly into an openvpn client.


## On your router

* Forward port 1194 (UDP) to your raspberry pi.


## Testing
* Install openvpn on your phone
* Install google authenticator on your phone.
* Somehow get the client.ovpn onto your phone.  (You could email it to yourself then download it!)


## 2 factor authentication

For each user of your vpn, you will need to generate a user on the raspberry pi, and a run google-authenticator. 

Log onto the raspberry pi using pi/raspberry

  sudo adduser fred (provide password as 'monday', and go with defaults for the remaining of the prompts)
  su - fred   (password: monday)
  google-authenticator  (Answer y to the questions)

This will generate a QR code.  Scan this into your phone using the google authenticator app.  There is also a URL,
which you could email to the user.  


## On your phone 

* Disable wifi, to ensure that you are not connecting via your home network.  Use mobile data ie. 3g.
* Open openvpn and import client.ovpn.  

You will be prompted for a username and password:

username:  fred
password:  monday13520    

The password, is fred's password concatenated with the google authenticator verification code provided by the app.  

You should now be able navigate to your routers home page ie.: http://192.168.101.254 











