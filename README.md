# Ramadda Reverse Proxy Experiments

A local environment to [Ramadda](https://ramadda.org) under a reverse proxy.

## Purpose

This project is intended to debug and fix issues relating to running Ramadda behind a load balancer. Specifically a
load balancer which changes the *protocol*, *host* and *port* of requests. For example requests made to `https://www.example.com/repository/...` are reverse proxied to `http://example-prod-1.internal:1234/repository/...`.

Applications have to be aware when they running under load balancer, to ensure any URLs they generate match the client
facing *protocol*, *host* and *port*, rather than their internal values.

For Ramadda, it is hoped much of this awareness can be described using configuration options a Java Servlet Container, 
which manipulate/correct the details in the request object passed to running Java applications such as Ramadda.

Where Ramadda specific configuration is needed, this project serves as a minimal implementation that can be replicated
by Rmadda developers and operators to pin-point, debug and resolve issues.

This project uses [HAProxy](https://www.haproxy.com) as a reverse proxy and [Apache Tomcat](https://tomcat.apache.org) 
as a Servlet Container. 

## Implementation

This project consists of two Docker containers:

1. the official HAProxy image, to run HAProxy
2. a project specific Ramadda image, running a custom Ramadda build with additional HTTP request debugging

### HAProxy

HAProxy is used as a reverse proxy and for HTTPS termination.

HAProxy is configured to listen for HTTPS connections on port `9001`. It then directs them to the Ramdda container as a
HTTP connection on port `8080`. 

HAProxy is configured using `haproxy/haproxy.cfg`.

[Forwarding](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Forwarded) headers are added to requests to pass 
information to Tomcat/Ramadda about the original request. These include the original host and protocol used by the 
client (e.g. that the original request was made using the HTTPS protocol to host `www.example.com`).

### Tomcat/Ramadda

Tomcat is used as a container for the Ramadda application.

Tomcat is configured to listen for HTTP connections on port `8080`. It then determines which application the request
should be sent to (based on the URL path) and provides information about the incoming request through a 
[`HttpServletRequest`](https://tomcat.apache.org/tomcat-8.5-doc/servletapi/javax/servlet/http/HttpServletRequest.html).

Tomcat is configured using `tomcat/server.xml`, log files are written to `tomcat/`.

A [RemoteIpValve](https://tomcat.apache.org/tomcat-8.5-doc/api/org/apache/catalina/valves/RemoteIpValve.html) is
configured to trust headers added by HAProxy, specifically whether the original request made by the client was made 
using HTTP or HTTPS. This ensures that `request.isSecure()` for example gives the correct response. In this container
all proxies are trusted, in production this would be restricted. It also configures the port that should be used for 
HTTPS, to match the port used by the downstream load balancer.

Two applications are loaded in Tomcat, the first is a debugging script to check the values given by the 
[`HttpServletRequest`](https://tomcat.apache.org/tomcat-8.5-doc/servletapi/javax/servlet/http/HttpServletRequest.html),
the other is a [custom build](https://geodesystems.com/repository/entry/get/repository.war?entryid=synth%3A498644e1-20e4-426a-838b-65cffe8bd66f%3AL3JhbWFkZGFfMi4zL3JlcG9zaXRvcnkud2Fy) 
of Ramadda with additional HTTP debugging enabled.

The debugging application be accessed from [localhost:9001/tomcat-environment](https://localhost:9001/tomcat-environment).

The custom Ramadda build can be accessed from [localhost:9001/repository](https://localhost:9001/repository).

## Usage

You will need [Docker](https://hub.docker.com/search/?type=edition&offering=community) and Docker Compose to use this 
project. You will also need to generate a local, self-signed, TLS certificate for the Load Balancer to use.

```shell
# clone project
$ git clone https://github.com/felnne/ramadda-haproxy-reverse-proxy-experiments.git
$ cd ramadda-haproxy-reverse-proxy-experiments
# create local self-signed certificate
$ openssl req -x509 -out haproxy/localhost.crt -keyout haproxy/localhost.key -newkey rsa:2048 -nodes -sha256 -subj '/CN=localhost' -extensions EXT -config <( printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
$ cat haproxy/localhost.key haproxy/localhost.crt > haproxy/localhost.pem
# start HAProxy and Tomcat Docker containers
$ docker-compose up
```

Startup logs will be written to standard out, Tomcat logs will also be written to `tomcat/logs`.

After a few seconds you should be to visit 
[localhost:9001/tomcat-environment/index.jsp](https://localhost:9001/tomcat-environment/index.jsp) to view Tomcat
request information.

Visiting [localhost:9001/repsitory](https://localhost:9001/repository) will create a new Ramadda installation, which
will take ~10 seconds to complete.

You can start a shell in either container using Docker in another terminal:

```shell
# to login to the running HAProxy container
$ docker-compose exec haproxy bash
# to login to running Tomcat container
$ docker-compose exec app bash
```

To terminate the containers, `ctrl + c` to stop the containers and run `docker-compose down` to remove them.

## License

© UK Research and Innovation (UKRI), 2019, British Antarctic Survey.

You may use and re-use this software and associated documentation files free of charge in any format or medium, under 
the terms of the Open Government Licence v3.0.

You may obtain a copy of the Open Government Licence at http://www.nationalarchives.gov.uk/doc/open-government-licence/
