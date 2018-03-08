# CF Ripper
Walkthrough: Rip a Cloud Foundry application to Docker.     
## 1. Summary  
Because they follow the [12 factors](https://12factor.net/), Cloud Foundry applications are easy to port to alternative platforms. This walkthrough demonstrates how to introspect a running Cloud Foundry application, and convert it into a running Docker container.
## 2. Prerequisites
1. cf CLI logged into a Cloud Foundry installation where you can push applications and call the API (I used cf version 6.34.1+bbdf81482.2018-01-17 running against PCF Dev version 0.29.0). 
2. docker CLI connected to a running Docker Machine where you can build images and launch containers (I used Docker version 18.02.0-ce, build fc4de44 running against Docker Machine version 0.13.0, build 9ba6da9). 
3. Access to this repository and [Spring Music](https://github.com/cloudfoundry-samples/spring-music) .  

PS: I found a great guide to installing Docker on OSX via Brew at https://pilsniak.com/how-to-install-docker-on-mac-os-using-brew/ . 
## 3. Installing Spring Music on Cloud Foundry  
1. Clone https://github.com/cloudfoundry-samples/spring-music   
2. Follow the instructions to push Spring Music to Cloud Foundry:   
https://github.com/cloudfoundry-samples/spring-music#running-the-application-on-cloud-foundry   
3. Verify you can access the application through your browser:  
## 4. Download the application's Droplet from Cloud Foundry   

