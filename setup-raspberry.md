# setup raspberry

## WLAN Hotspot on second wlan interface

### Current startup procedure

Step 1:

```bash
 cd ~/Donwloads/CM762-35264_USB无线网卡驱动_V1.3/Linux/linux_driver_package/
 sudo dpkg -i aic8800d80fdrvpackage.deb
 ```

Step 2: Run as root: `hotspot-init.sh`

### Install UGREEN USB Wifi6 Stick (AX900)

Download driver from [https://www.lulian.cn/download/135.html](https://www.lulian.cn/download/135.html)

unzip file with 
```bash
unzip CM.... -d CM762
```
If not installed, install linux-header
```bash
sudo apt-get install build-essential linux-headers-$(uname -r)
```
Install package with
```bash
dpkg -i CM[...].deb
```
switch mode from usb device: 
```bash
sudo /usr/sbin/usb_modeswitch -KQ -v a69c -p 5723
```


### Configure Hotspot

Install hostapd
```bash
sudo apt install hostapd
```

create `/etc/hostapd/hostapd.conf` with content:

```conf
interface=wlan1
ssid=FotoBox
hw_mode=g
channel=6
auth_algs=1
wmm_enabled=1
ignore_broadcast_ssid=0
```

start service:

```bash
systemctl unmask hostapd
systemctl enable hostapd
systemctl start hostapd
```

### Configure dhcp

create `dnsmasq.conf`:

```bash
# Listen on wlan1
interface=wlan1
bind-interfaces

# DHCP settings
dhcp-range=192.168.100.10,192.168.100.100
dhcp-option=3,192.168.100.1  # Default gateway
dhcp-option=6,8.8.8.8,8.8.4.4  # DNS servers

# Logging
log-queries
log-dhcp
```

start dnsmasq (todo: create start script)

```bash
sudo dnsmasq -C /path/to/dnsmasq.conf
```

configure own ip address (todo: create start script)

```bash
ifconfig wlan1 192.168.100.1 netmask 255.255.255.0
```