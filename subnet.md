Avalanche Subnet Setup
## 1. Install AvalancheGo

First, you need to install AvalancheGo, the official node implementation of Avalanche. You can use the installer script to set up the nodes, which will abstract most of the setup process for you.

## 2. Configure Network Interface

Next, you need to configure your network interface. You can do this from the command line by using commands to change your current settings or by editing a number of system files.

To find the network interface cards on your computer, use the following command:

```bash
ls /sys/class/net
```

This will list the interface names for all NICs on your computer. It will probably include `eth0` (hardwired NIC), `lo` (loopback interface for the localhost), and something for your wireless card (like `wifi0`, or `wlan0`).

To configure a static IP address for your network card, edit `/etc/network/interfaces`. Replace `eth0` with your network interface card. Use the following commands:

```bash
sudo nano /etc/network/interfaces
```

Then, add the following lines to the file, replacing `192.168.2.33` and `192.168.2.1` with your desired static IP and gateway IP respectively:

```bash
# The primary network interface
auto eth0
iface eth0 inet static
address 192.168.2.33
gateway 192.168.2.1
```

Save and close the file. For these settings to take effect, you need to restart your networking services with the following command:

```bash
sudo /etc/init.d/networking restart
```

## 3. Create a Subnet

After setting up AvalancheGo and configuring your network, you can create a subnet using the Avalanche CLI. The `subnet create` command builds a new genesis file to configure your subnet. By default, the command runs an interactive wizard that walks you through all the steps you need to create your first subnet.

```bash
avalanche subnet create myNewSubnet
```

## 4. Deploy and Maintain the Subnet

After creating the subnet, you can deploy it and start syncing with the subnet. Restart the node and monitor the log output. You should notice something similar to the following:

```bash
Jul 30 18:26:31 node-fuji avalanchego[1728308]: [07-30|18:26:31.422] INFO chains/manager.go:262 creating chain:...
```

This indicates that your node is syncing with the subnet.

