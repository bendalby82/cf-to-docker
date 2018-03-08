# CF Ripper
Walkthrough: Rip a Cloud Foundry application to Docker.     
## 1. Summary  
Because they follow the [12 factors](https://12factor.net/), Cloud Foundry applications are easy to port to alternative platforms. This walkthrough demonstrates how to introspect a running Cloud Foundry application, and convert it into a running Docker container.
## 2. Prerequisites
1. cf CLI logged into a Cloud Foundry installation where you can push applications and call the API (I used cf version 6.34.1+bbdf81482.2018-01-17 running against PCF Dev version 0.29.0). 
2. docker CLI connected to a running Docker Machine where you can build images and launch containers (I used Docker version 18.02.0-ce, build fc4de44 running against Docker Machine version 0.13.0, build 9ba6da9). 
3. Access to this repository and [Spring Music](https://github.com/cloudfoundry-samples/spring-music) .  

PS: I found a great guide to installing Docker on OSX via Brew at https://pilsniak.com/how-to-install-docker-on-mac-os-using-brew/ . 
## 3. Walkthrough
This section walks through the various tasks that the ripping scripts are doing. If you just want to run the scripts, go to section 4.
### 3.1 Installing Spring Music on Cloud Foundry  
1. Clone https://github.com/cloudfoundry-samples/spring-music and https://github.com/bendalby82/cfripper     
2. Follow the instructions to push Spring Music to Cloud Foundry:   
https://github.com/cloudfoundry-samples/spring-music#running-the-application-on-cloud-foundry   
3. Verify you can access the application through your browser:  
<img src="https://github.com/bendalby82/cfripper/blob/master/images/spring-music-pcfdev.png" width="500px" border="1">   

### 3.2 Download and unpack the application's Droplet from Cloud Foundry   
To do this, you need to first retrieve your application's GUID (See [line 18](https://github.com/bendalby82/cfripper/blob/master/01-make-docker-file-from-cf.sh#L18)), and then make a call to the Cloud Foundry API (see [line 31](https://github.com/bendalby82/cfripper/blob/master/01-make-docker-file-from-cf.sh#L31)) to retrieve the application's droplet:  

<img src="https://github.com/bendalby82/cfripper/blob/master/images/spring-music-cf-api.png" width="500px" border="1">

This isn't very difficult, but you do need to know that the staged droplet is in .tar.gz format. Follow the links above to see the relevant lines in the `01-make-docker-file-from-cf.sh` script.  

### 3.3 Retrieve useful environment variables from Cloud Foundry
There are a couple of environment variables that we will need if we are to reuse the start command generated by Cloud Foundry's Java buildpack - namely $PORT and $MEMORY_LIMIT, rather than trying to figure it out for ourselves. Unfortunately we don't get PORT back by calling `cf env spring-music`, so I opted instead to query the running container's environment via SSH, and then process that. (See [line 26](https://github.com/bendalby82/cfripper/blob/master/01-make-docker-file-from-cf.sh#L26)).

### 3.4 Retrieve start command from Cloud Foundry  
When you unpack the staged droplet, you will see an incredibly helpful file called `staging_info.yml` in the root directory. This JSON file magically includes a `start_command` key, which we can use with a bit of munging we need to do with escape characters (See [line 36](https://github.com/bendalby82/cfripper/blob/master/01-make-docker-file-from-cf.sh#L36)):  
<img src="https://github.com/bendalby82/cfripper/blob/master/images/spring-music-droplet.png" border="1px"/>   

### 3.5 Create a Dockerfile   
We now have the application bits, the environment variables, and the start command. We can now bind this together into a Dockerfile (See [line 39](https://github.com/bendalby82/cfripper/blob/master/01-make-docker-file-from-cf.sh#L39)) onwards.  

### 3.6 Build Docker image and start container   
Once we have the Dockerfile, we've done all the heavy lifting. We just need to build the image (see [line 26](https://github.com/bendalby82/cfripper/blob/master/02-build-and-launch-docker-container.sh#L26)) and start the container (see [line 34](https://github.com/bendalby82/cfripper/blob/master/02-build-and-launch-docker-container.sh#L34)).  

The `02-build-and-launch-docker-container.sh` script includes some helper code at the end to report back on the URL of your running container:  
<img src="https://github.com/bendalby82/cfripper/blob/master/images/spring-music-docker-script.png" border="1px"/>

### 3.7 Admire your Cloud Foundry application served up by Docker
<img src="https://github.com/bendalby82/cfripper/blob/master/images/spring-music-docker.png" width="500px" border="1px"/>

## 4. Just use the Scripts
1. Follow step 3.1 above as before, making a note the name you gave the app - e.g. springmusic  
2. Open a command prompt and `cd` to the root of the `cfripper` repository   
2. `./01-make-docker-file-from-cf.sh springmusic`   
3. `./02-build-and-launch-docker-container.sh springmusic`   
