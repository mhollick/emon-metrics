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
$ docker run --name "emon-local" -p 2003:mayan/emon-metrics 