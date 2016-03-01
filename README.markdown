# Wake CLI

Wake CLI packages, deploys, manages and orchestrates applications and application environments.

## Wakeful vs. Other Infrastructure Frameworks

Wakeful is an end-to-end solution for managing applications and
application environments from version control commit to running in
production. Wake uses other pluggable infrastructure frameworks such as
Kubernetes or Docker Swarm to power many of its features. In addition to
the functionality that these frameworks provide, wake also offers other
pluggable abstractions over IaaS providers, logging, and other common
infrastructure needs.

# Prereqs

* docker
* docker-machine

_NOTE: On Windows, you'll need to ensure that OpenSSL has access to a certificate
authority bundle.  Download the [Mozilla Certificat bundle](https://raw.githubusercontent.com/bagder/ca-bundle/master/ca-bundle.crt)
locally, and set the `SSL_CERT_FILE` environment variable to reference this file._

You may also want to add wake's bin directory to your path for ease of use.

# Terms

**cluster**: a collection of nodes managed together as a unit

**node**: a host in the cluster

**process**: the smallest unit of work (e.g. a web server or background job)

**application**: is a list of related processes defined by a `manifest.json`

**service**: is the collection of all running instances of a process

**container image**: a packaged up filesystem and startup script (docker
container image)

# Concepts

wake is broken up into these concepts:

**cli**: implimentation of the command line interface

**build**: responsible for building and pushing docker images and for
creating build pipelines

**iaas**: libraries for different iaas providers that expose a unified
interface

**infrastructure**: commands for interacting with iaas actions and
security of vms

**secrets**: implementations for different stores for securely getting
and setting application secrets

**orchestration**: libraries for different orchestration frameworks like
kubernetes and swarm

## Orchestration

Required features for an orchestration framework are:

* anti-affinity: two processes of the same application shouldn't be on
  the same vm
* dns:
    * master nodes should be registered in dns for easy discovery
    * services should be auto-addressable by dns names
* load balancing (internal and external)
* upgrade deployment strategy (replace/rollback)

The three we intend to support are:

* Kubernetes
* Swarm
* Nomad

# Opinions

wake is opinionated about:

* immutable infrastructure
* cluster bootstrap and scaling with iaas cli/http apis
* log aggregation
* secrets management
* ssh access
* building docker images
* pipeline from commit to build to run

# CLI conventions

Every command supports these three flags:

* `-c` or `--cluster` to set the current cluster to work with
* `-h` or `--help` which will output the usage information (can also use
  `wake help <command>`)
* `-v` or `--verbose` which will output lots of extra logging
  information
* `-vv` or `--very-verbose` which will output a ton of extra logging
  information that is mostly unecessary

# Cluster

A cluster is a logical collection of nodes.

Clusters are kept track of in `~/.wake/clusters/` and can be managed with
the `wake clusters` command.

## Create a cluster

```sh
$ wake clusters create wake-test-1 --iaas azure --datacenter eastus --orchestrator kubernetes
```

## List known clusters

```sh
$ wake clusters list
```

## Set the default cluster

Having a default cluster makes everything else easier, since almost
every other command will need to know which cluster to perform the
operation on (like creating a new host, where should it go?).

```sh
$ wake clusters set-default wake-test-1
```

## Delete a cluster

```sh
$ wake clusters delete wake-test-1
```

**This is a very destructive action: this will terminate the running
remote cluster.**

_NOTE: `wake-clusters-delete` will ask you to confirm the name of the
cluster before proceeding. It's possible to pass `--pre-confirm` with
the name again to prevent the confirmation prompt._

> *Environments*
>
> There are no environments with wake. Make a new cluster with a different name.

# Application conventions

**Every process must listen on port 8000 for `/_health`**

# `manifest.json`

Here are some examples:

```json
{
  "platform": "ruby",
  "app": "bestsiteever",
  "owners": [
    "nathan.herald@microsoft.com"
  ],
  "processes": {
    "web": {
      "start": "cd /opt/app && bin/puma -c config/puma.rb",
      "cpu": 1,
      "memory": 0.5
    },
    "worker": {
      "start": "cd /opt/app && bundle exec rake jobs:work",
      "cpu": 1,
      "memory": 0.5
    }
  }
}
```

```json
{
  "platform": "sbt",
  "app": "proxy",
  "owners": [
    "nathan.herald@microsoft.com"
  ],
  "processes": {
    "proxy": {
      "cpu": 4,
      "memory": 4,
      "start": "cd /opt/app && sbt run"
    }
  }
}
```

# docker images

wake is opinionated about how docker images are created. wake includes
pre-built `Dockerfile`s for different platforms. If your project does
not include a `Dockerfile` then one will be provided during build.

A `Dockerfile` is expected to accept to build ARGs: `sha` and `start`.

wake will only build docker files from git repositories. wake uses `git
ls-files` which means it will only include checked in files. **Dirty or
ignored files will never be included in an image.**

To build and push a docker image from master:

```sh
$ cd path/to/project
$ wake build
```

To build an image for a certain commit then specify the sha or branch:

```sh
$ wake build -r b5aedadd
```

# Run

**wake is opinionated about affinity. Containers of a single service are
never run together on the same node.**

Containers are scheduled with `wake run`. To run one redis in the cluster:

```sh
$ wake run redis-cache -i redis
```

In this example the image to run is "redis" and the service it's a
part of is "redis-cache".

To launch three nginx servers one might:

```sh
$ wake run frontend -i nginx-image -a 3
```

Now there should be 3 `nginx-image` containers running in the cluster, all
on different nodes, and all referencable internally with dns as
`frontend.service`.

# Scaling

Services are scaled with `wake scale`:

```sh
$ wake scale frontend -a 6
```

wake will add or subtract running containers until the final amount is
met. `0` is a valid value.

# Secrets

Secrets are configured with `wake secrets`. Some examples:

```sh
$ wake secrets list -a frontend
$ wake secrets get -a frontend REDIS_URL
$ wake secrets set -a frontend REDIS_URL=redis://localhost PORT=9000
```

# Development

If you are working with a git clone and not with an installed gem, then
you must run commands like so:

```sh
$ cd path/to/wake-gem
$ bundle exec bin/wake help
```

or setup an alias:

```sh
alias wake="cd path/to/wake-gem && bundle exec bin/wake"
```

# Tests

We are using minitest. Write tests for all non-cli stuff.

```sh
$ rake test
```
