# NEEO BRAIN HACK
Method by Niels de Klerk 2020

Big thanks to: dgiese and ZED


!! WARNINGS !!
- Hacking may not be legal in your country. always obey the law.
- This method may potentially couse harm and no one else than you will be responsible.
- Currently the needed decryption key is NOT included!


## How to prepare.

Download the folowing firmware images:
- https://neeo-cp6-recovery.s3.amazonaws.com/neeo_firmware_0.50.6-20180424-481315c-0523-151625_emmc.img
- https://neeo-firmware.s3.amazonaws.com/neeo_firmware_0.53.8-20180424-05eb8e2-0201-092014_emmc.img

You will probably only want to use neeo firmware 0.53.8 but it never hurts to get both.

## how the rooting method works.

The hack works by inserting a SSH certificate in the firmware image so that when the firmware image is installed you will be able to SSH in to the brain using your certificate key.
The firmware images are encrypted and need a passphrase to decrypt. after the decryption the authorized_keys file can be altered to add your own key. after the change the image must be encrypted and offered to the neeo brain. after the installation you will be able to login using user "neeo".

## Firmware decryption/encryption keys.
I have not included the key in this code. The reason is that the NEEO remote as a product is still working including the cloud services. I do not want to jeopardize the cloudservices being taken offline. The reason to share all this now is to let everyone know that a potential closing of the cloud services won't turn your devices into a beautiful doorstopper.
If you can't wait for the decryption key you need to desolder the mmc chip and start searching :stuck_out_tongue_closed_eyes:

Using the script (root_cp6_wo-key.sh) the firmware file will be decrypted, altered and encrypted.  (USE ONLY WITH A VALID KEY !!!!)

1) download the firmware image from

2) generate a SSH key
````
sudo apt-get install putty-tools
puttygen neeo.ppk -O private-openssh -o neeo.pem
chmod 400 neeo.pem
ssh -i neeo.pem neeo@brain-ip
````

3) Change the following parameters in the root_cp6_wo-key.sh script accordingly
   FW_KEY=***********************************
   SSH_KEY_FILE=${DIR}/key/authorized_keys

4) run the script.


## How to force a custom firmware image.

1) Upload the altered firmware image to a local webserver.  (DO NOT ALTER THE NAME OF THE FILE, KEEP IT AS IT IS! i.e. neeo_firmware_0.53.8-20180424-05eb8e2-0201-092014_emmc.img)
2) add a file on the webserver named "firmware_info.txt" and add the following as content "0.53.8-20180424-05eb8e2-0201-092014"
3) Put your NEEO brain into recovery mode. by removing power, connect UTP, Hold top lid button while plugging in power.
4) Use a browser to go to the IP address of your brain like http://<BRAIN_IP>
   - only use the first two buttons (check/download)when you want to revert no a non hacked unit.
   - use this page for logging information.
5) open a new browser tab and the folowing API call to read the version number of the hacked firmware image:
   - http://<BRAIN_IP>/checkforfirmware?server=http://<YOUR_WEB_SERVER_IP>
6) look at the status page, when the download is complete (be patient!!!) then press the install button. (and be even more patient!!!))
   - after the install is complete, the brain will come back with his normal IP-address. the status page will not show when it's ready.
   
## How to SSH into a hacked neeo

Use a SSH client like putty and set it up to use the private.ppk file
the session will ask for your username. enter "neeo" without quotes.
