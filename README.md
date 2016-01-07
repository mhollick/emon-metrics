# emon-metrics

A blend of

- carbon-c-relay
- go-carbon
- graphite-api
- postfix

Held together by monit

Intended for used as part of a high resolution monitoring solution on AWS
Docker environmental variables are used to configure all security related elements

## Diagram

         ┌─────────────────────────────────────────────────────────────────┐            ┌─────────────────────────────────────────────────────────────────┐
         │                                                                 │            │                                                                 │
         │                        Service A                                │            │                          Central management systems             │
         │                                                                 │            │                                                                 │
         │                                                                 │            │                                                                 │
         │                                                                 │            │          ┌─────────────────────────────────────────────┐        │
         │       ┌─────────────┐              ┌───────────────────┐        │            │          │  Docker Server           ┌──────────────┐   │        │
         │       │             │              │  Docker Server    │        │            │          │     Cluster              │              │   │        │
         │       │   Client    │              │     Cluster       │        │            │          │                          │  emon-alerter│   │        │
         │       │   Server    │────────┐     │                   │        │            │          │                     ┌────│   (central)  │   │        │
         │       │             │        │     │  ┌──────────────┐ │        │            │          │ ┌──────────────┐    │    │              │   │        │
         │       └─────────────┘        │     │  │              │ │        │            │          │ │              │    │    └──────────────┘   │        │
         │       ┌─────────────┐        │     │  │ emon-metrics │ │        │            │          │ │ emon-metrics │    │                       │        │
         │       │             │        ├─────┼─▶│   (local)    │─┼────────┼────────────┼──────────┼▶│   (central)  │▣───┤                       │        │
         │       │   Client    │        │     │  │              │ │        │            │          │ │              │    │    ┌──────────────┐   │        │
         │       │   Server    │────────┤     │  └──────────────┘ │        │            │          │ └──────────────┘    │    │              │   │        │
         │       │             │        │     │          ▣        │        │            │          │                     │    │   Grafana    │   │        │
         │       └─────────────┘        │     │          ├────────┼────────┼────────────┼──────────┼─────────────────────┴────│              │   │        │
         │       ┌─────────────┐        │     │          │        │        │            │          │                          │              │   │        │
         │       │             │        │     │  ┌──────────────┐ │        │            │          │                          └──────────────┘   │        │
         │       │   Client    │        │     │  │              │ │        │            │          │                                             │        │
         │       │   Server    │────────┘     │  │ emon-alerter │ │        │            │          │                                             │        │
         │       │             │              │  │   (local)    │ │        │            │          └─────────────────────────────────────────────┘        │
         │       └─────────────┘              │  │              │ │        │            │                                                                 │
         │                                    │  └──────────────┘ │        │            │                                                                 │
         │                                    │                   │        │            │                                                                 │
         │                                    └───────────────────┘        │            │                                                                 │
         │                                                                 │            │                                                                 │
         └─────────────────────────────────────────────────────────────────┘            └─────────────────────────────────────────────────────────────────┘

## Example implementation on a development platform


```
$ # Static port assignments are made
$ sudo mkdir -p /srv/docker/{emon-local,emon-central,grafana}/{data,config}
$ docker run --name "emon-local" -p 2003:2003 -p 8888:8888 -v /data /srv/docker/emon-local mayan/emon-metrics
$ docker run --name "emon-central" -p 2003:3003 -p 8888:9888 -v /data /srv/docker/emon-local mayan/emon-central
$ docker run --name "grafana" -p 3000:80 grafana/grafana
```

