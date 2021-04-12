# Squid Proxy AMI

A quick test squid proxy AMI for replication/debug use cases requiring a HTTP forward proxy for outbound connections.

Configured by default to listen on port 8080, accepting HTTP(s) traffic with no caching as a basic forward HTTP proxy server.
Change `files/squid-min.conf` to adjust squid config as needed.

## Building

**Prerequisites**

[Install packer](https://learn.hashicorp.com/tutorials/packer/getting-started-install)

[Configure AWS creds](https://docs.aws.amazon.com/general/latest/gr/aws-security-credentials.html)


**Build using packer**
Adjust `region` in `squid.pkr.hcl` to your AWS region. Then run:
```sh
$ packer build squid.pkr.hcl
```

## Configure client

There isn't exactly a standard for how to configure clients to use a HTTP(s) proxy, but in general applications that support HTTP proxies typically read `HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY` environment variables to discover this information.

Example:

```sh
export http_proxy="http://<squid-proxy-ip>:8080"
export HTTP_PROXY=$http_proxy
export https_proxy="http://<squid-proxy-ip>:8080"
export HTTPS_PROXY=$https_proxy
export no_proxy="127.0.0.1,localhost,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,100.64.0.0/10"
export NO_PROXY=$no_proxy

$ curl -v "https://checkip.amazonaws.com"
```