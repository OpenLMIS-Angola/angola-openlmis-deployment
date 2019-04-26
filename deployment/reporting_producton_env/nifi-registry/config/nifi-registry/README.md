# ReportingStack NiFi Registry

There is a place where you can place your custom files, which will be copied into nifi-registry working dir. These files will be moved the machine before the nifi-registry service start.

Basically, this solution allows loading already existing dump of nifi-registry. To do that we must placed here 2 directories:
* `database` - it contains definition of buckets and flows (with their UUID)
* `flow_storage` - it contains content of flows


These files can be obtained only from a running instance - files are deleted when the container is restarted. Steps of creating a nifi-registry dump:
1. Read nifi-registry container id
    ``` docker ps ```
2. Copy `database` and `flow_storage` directories to local machine (use read container id)
    ```
    docker cp <containerId>:/opt/nifi-registry/nifi-registry-0.2.0/database .
    docker cp <containerId>:/opt/nifi-registry/nifi-registry-0.2.0/flow_storage .
    ```
