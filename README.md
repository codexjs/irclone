# Irclone
## What is Irclone?
Irclone is a bash script which use inotify to watch to a folder and then upload any file change to the cloud storage configured in rclone.

This is is useful to make backups in the cloud or even have a shared folder in differents computers.

Another important thing about irclone is that thanks to rclone and inotify you are able to exclude files letting you upload just the files that you need.
  
## Which problem I wanted to solve with Irclone?
As a Software developer I have differents computers in which I work, and sometimes I have work which It's not finished and I have to continue in another laptop. 

The problem is that every time that I want to continue my work I had to zip the entire project and send it to my self and sometimes I just forget to send the changes and I'm not able to continue working until next day.

So in order to fix this problem I decided to make this script which let me have all my files updated in the cloud, and just booting my computer I have all those changes without having to do anithing.

## How irclone work?
Irclone is a bash script which use inotify to listen for folder changes and execute a rclone command depending on the inotify response, the operation is simple but it is very useful.

## Installation
In order to add this script to your computer you have 2 different options:
- irclone command as a service
- irclone with Docker

The easiest and simpler is using Docker but both of them are going to work exactly the same, the differences are that irclone with Docker setup is simple and faster.

> ⚠️ This tool is only going to work in a OS with Linux Kernel  and also  it will be limited to the limitations of inotify

## Docker installation
> ⚠️ Right now the docker image is not uploaded to Docker Hub but in the future I will upload it.

To install irclone with docker the best option and faster in using docker-compose.

#### 1. Clone the repository
``` bash
git clone https://github.com/codexjs/irclone
```
#### 2. Configuring rclone
In order to be able to use irclone you have to setup a rclone.conf file, in order to do this with docker you have to use this command.
```bash
docker run -it -v ~/.config/rclone:/config/rclone rclone/rclone config
```
This will execute the rclone config command letting you create the rclone.conf file without having to install rclone in your computer. Checkout rclone docs in order to get more information abaout rclone config https://rclone.org/

#### 3. Edit the docker-compose.yml
In the docker-compose.yml that I have in my repository you probably have to change some things:
#### environment:
Here we have 2 environment variables:
- DESTINATION_PATH: This variable should be which remote you want to use and where you want to store it.
- EXCLUDE: This variable is going to be used by inotify to don't do anithyng in case matching the extended regular expression.
> ⚠️ As you can see in the docker-compose file I use $$ instead of  just $ this is becasuse by  using just $ the file will not work correctly ($$==$)

#### volumes:
The irclone sript is made for listen to /backup folder so you have to add a volume from the folder you want to listen to /backup, In my case I'm going to listen to the /home/pi folder.
```
volumes:
    - /home/pi:/backup
``` 
And last but not least you have to make a volume to share the rclone.conf to the container.
```
    - ~/.config/rclone:/root/.config/rclone
```
#### 4. Edit the exclude file
If you look at the proyect structure you can see a folder called etc which contains inside irclone a file called "exclude". This file is going to be used by rclone to exclude files when syncing with the remote.

When the irclone script start the first thing that is going to do is:
- Pull all the files from the remote and add it to the local system
- Sync the folder with the remote.

The exclude file is neccessary to exclude all the files that you don't want to be synced to the remote storage.

To know more about exclide with rclone look at the rclone docs https://rclone.org/filtering/

#### 5. Build and start the container
As I said before right now the image is not uploaded to Docker Hub but this is not going to be a problem since docker-compose will build the image automatically, you just have to run:
``` bash
docker-compose up -d
```
After starting check if the script is running correctly by checking docker logs:
``` bash
docker-compose logs -f
```
If you see "Listening for changes in /backup" that means that the script is running correctly.

#### Multiple irclone contianers
If you want, you can use irclone in different folders the only thing you have to do is to edit the docker-compose.yml and add and config as many irclone services as you want.

## Irclone as a service
#### 1. Install rclone and inotify-tools
In order to install Irclone as a service, the first thing you have to do is to install "rclone" and "inotify-tools" in your computer. Depending which distribution you are using this is going to be different, checkout rclone and inotify-tools documentation in order to know how to install it:
- https://rclone.org/downloads/
- https://github.com/inotify-tools/inotify-tools/wiki

As example I'm going to use debian:
``` bash
sudo apt update && sudo apt install rclone inotify-tools
```

#### 2. Configuring rclone
In order to setup a rclone.conf file you have to use the rclone config command.
```bash
rclone config
```
Checkout rclone docs in order to get more information about rclone config https://rclone.org/

#### 4. Clone the repository
``` bash
git clone https://github.com/codexjs/irclone
```
#### 5. Adding the script to /usr/bin
After downloading the repository I recommend to add the script to /usr/bin in order to don't have any problem with the service.
``` bash
cd irclone
sudo cp bin/irclone /usr/bin
sudo chmod u+x /usr/bin/irclone
```
#### 6. Editing and moving "exclude" to /etc/irclone
After this the next step to do is to edit and move the "exclude" file to /etc/irclone.
``` bash
sudo mkdir /etc/irclone
sudo cp etc/irclone/exclude /etc/irclone
```
You can find more information about this file in the step 4 of the irclone with docker installation. 
#### 7. Creating the .service file
Once you have rclone, inotify-tools installed, rclone configured, irclone added to /usr/bin and the exclude file in /etc/irclone/exclude we have all setup to create the service.

In the repository folder you can find a folder called "system" which contains a irclone.service which is a service example file that you can use as a template.
#### environment
In rclone.service file the are 3 environment variables:
- ORIGIN_PATH: This variable is the folder that you want to watch which will be uploaded to the cloud storage.
- DESTINATION_PATH:  This variable should be which remote you want to use and where you want to store it.
- EXCLUDE: This variable is going to be used by inotify to don't do anithyng in case matching the extended regular expression.
#### User and Group
This two variables are the User and the Group which is going to execute the command, this user and group must be the user in where you  created the rclone.conf, If you use a user which dont have any rclone.conf file the script is not going to work.

#### 8. Add and enable the service
``` bash
sudo cp system/irclone.service /etc/systemd/system/
sudo systemctl enable irclone.service
sudo systemctl start irclone.service
```
This should enable the service, that means that when you boot the system is going the start the script automatically and also start the service in order to make the script start working.

After start the service check that is working correctly by checking the service status:
``` bash
sudo systemctl status irclone
```
If you see "Listening for changes in /backup" that means that the script is running correctly.

#### Multiple irclone services
If you want to watch to multiple folders using just a service I created a binary in which you can see an example of how to execute multiple irclone commands in just one script. The example is in the bin folder with the name of "irclone-multi".

Also I created a irlcone-multi.service as a example in the system folder.

### Irclone command
Irclone is a script that you can use as a command.
To do the installation follow the steps 1 to 6 in the "Irclone as a service" documentation.
To know more about how to use irclone command
``` bash
irclone --help
```

License
----
MIT
