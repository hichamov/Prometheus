# Prometheus & Grafana

## Table of content 

* Introduction
* Installation
* Prom: basics
* Prom: GUI
* Prom: node exporter
* Graf: Add metrics
* PromQL: Filters and Labels
* PromQL: Group By
* PromQL: time intervals
* PromQL: increase vs rate
* PromQL: Derived
* Prom: manipulation des labels
* PromQL: operators
* Exporters: haproxy, Nginx, nginx vts exporter, postgresql, process.
* Exporters: create own exporter with bash.
* Exporters: Use netdata as a source.
* PushGateway
* AlertManager
* Consul: autodiscovery
* Grafana: data sources, dashboards, variables
* Prom: longue time storage via Victoriametrics

## Introduction

* Why prometheus ?: Needed in devops chain, Stack widely used
* Coded in GO
* Time series based + web server + engine
* Scraping (pull based arch) based on url (ip:port/path)
* Good memory and disk management
* Storage: key / timestamp / value
* Double delta: if two successive values of the same time serie are equal, we don't store the second one.
* Auto discovery from consul and other services.
* Installation: reffer to the bash script or: https://computingforgeeks.com/install-prometheus-server-on-debian-ubuntu-linux/
* Port: 9090

* Grafana: Visualisation tool, of graphics, tables, gauges, histograms, points
* Graf: multiple sources, prom, influxdb, postgres, mysql, ES.
* Graf: can perform alerting.
* Installation: https://grafana.com/docs/grafana/latest/setup-grafana/installation/
* Port: 3000
* Config file: /etc/grafana/grafana.init
* Default login: admin/admin

## Basics and notions

Prometheus configuration is written in yaml, we can pass the config file with --config.file=prometheus.yaml.

The main file is composed of: 

global:
* scrape interval: interval of scraping metrics
* evaluation_interval: interval of evaluating rules
* scrape_timeout: timeout of scraping

rule_files: file that contains rules

scrape_configs: specific config of scraping that define blocs of targets
* job_name: name of bloc
* static_config: define specific config
* labels: list of labels
* targets: list of targets ip:ports 

* The format of a time serie is composed of: name{job="job_name", instance="instance.id", labels="values"} value

instance is the ip of the target
job is the name of the bloc, for example, databases.

## GUI

The Gui of prometheus can be used to create very basic dashboards and visualizations, but to have an advanced vizualization experience, we need to use grafana instead.

## Node exporter

Is an exporter used to expose linux OS metrics.

You can find the full list of exporters: https://prometheus.io/docs/instrumenting/exporters/

We can download the node exporter : https://prometheus.io/download/#node_exporter

By default, node exporter runs on port 9100.

## Importing datasets and dashboards at grafana

Grafana community offers preconfigured dashboards, we can check for all available dashboards at https://grafana.com/grafana/dashboards/

## PROMQL

### Labels and filters

Labels in prometheus are used to identify time series, to perform queries filters and can use Golang regex.

There is a best practice section on naming metrics: https://prometheus.io/docs/practices/naming/

In promql, if we want to filter by a label:

```
metric_name{label_name="value"}
```

we can use different operators:

= : equal
!= : not equal
=~ :  perform regex, ex: device=~"enp.*"
or: label_name=~"value1|value2"

### Grouping

In promql, we can use by expression to group metrics based on multiple labels.

examples:

count the number of timeseries:

count(node_cpu_seconds_total) by (cpu)
count(node_cpu_seconds_total) by (cpu,instance)

for example, if we want to count the number of CPUs:

count (count(node_cpu_seconds_total{instance="localhost:9100"}) by(cpu))

### Time, rane vector & offset

Range vector: interval of time, this can be used to retrieve values of a metric in a range of time.

example:

metric[range]
node_load1[5m]

offsets: the date (moment) where the range started, in the last example, we retrieved the last minute, what if we wanted the minute before the last one, we will change the offset.

metric[range] offset time
node_load1[5m] offset 1m

We can perform operations on the output of range vector results, such as sum ot avergae

sum_over_time(node_load1[1m])

We can perform basic operations on metrics

metric1 - metric2

### Rate vs increase

Metrics in prome can be of different types:

* HELP: A description of what is the metric about
* TYPE: 
  * Counter: Counts haw many time an event happens, ex: how many requests an HTTP server receives (Shouldn't be used for values that go down)
  * Gauge: For values that can can go up & down, ex: CPU utilization, Memory utilization 
  * Histogram: How long or how big an events is, how long an application had an out of memory.
  * Summaries: Similar to histograms, but instead of calculating a rate of values in prometheus, it does it in application level, so we can't calculate the sum of a specific value from different endpoints.

In this part, we will work with 2 functions 

* rate: rate(v range-vector) calculates the per-second average rate of increase of the time series in the range vector. (valueX - value1) / (TimeX - Time1)
ex: rate(metric[5s])

* increase: calculates the increase in the time series in the range vector. this is similar to rate, but it calculates the rate in a range of time.

### DELTA vs Deriv

deriv can be used with gauges.

* deriv: value of increase per seconde


* delta: difference between 2 timestamps

## Relabeling and filters

Why prometheus uses labels ?

* to filter metrics
* to avoid collecting too much metrics, uneeded metrics can be dropped based on labels
* relabeling, rename labels, add labels ...
* autodicovery.

To read more (https://medium.com/quiq-blog/prometheus-relabeling-tricks-6ae62c56cbda)








































#### OLD
## Prometheus

Prometheus is designes to monitor containerized distributed systems.

#### Main components

* Prometheus Server: The main piece, which also has 3 subcomponents, `Storage` whiche is a Time series database, `Retrieval` A process that pulls metrics from services & software pieces to monitor which is called a Data retrieval Worker, and finally, `UI` an HTTP server that accepts queries (Written in PromQL) 

Prometheus can monitor (OS, Web servers, DB servers, Applications ...) which are called `Targets`, & each target has units which can be (CPU consumption, Memory, Disk ...), data related to a unit is called a metric which are stored in prometheus database, and are in a Human Readeable format 

Each metric has two attributes:

    * HELP: A description of what is the metric about
    * TYPE: 
  * Counter: Counts haw many time an event happens, ex: how many requests an HTTP server receives (Shouldn't be used for values that go down)
  * Gauge: For values that can can go up & down, ex: CPU utilization, Memory utilization 
  * Histogram: How long or how big an events is, how long an application had an out of memory.
  * Summaries: Similar to histograms, but instead of calculating a rate of values in prometheus, it does it in application level, so we can't calculate the sum of a specific value from different endpoints.

Prometheus pulls data from endpoints using HTTP requests, for that, targets must expose a `/metrics` endpoint.

To make a target expose metrics, we need to install a piece of software called `exporter` alongside the target.

The full list of exporters can be found [Here](https://prometheus.io/docs/instrumenting/exporters/)

For applications, prometheus offers client libraries for the following languages:

* Python
* GO
* Java
* Ruby

While prometheus uses a Pull method to scrape metrics, there are few cases when we need to push metrics to Prometheus, for example, a Batch job, a backup script, in this case, we will use the push gateway.

##### Configuration

Promtheus reads its configuration from a yaml file called `prometheus.yaml`, which has 3 main sections:

* global: which has parameters such as `scrape_interval` and `evaluation_interval`
   
* rule-files: For aggregating metrics values or creating alerts when a condition is met
* scrape_configs: What resources prometheus will monitor, since prometheus exposes a `/metrics` endpoint, it can monitor itself, here we can define other jobs to monitor other components.

###### Alert Manager

Is the process responsible of sending alerts through a preconfigured channel (Email, Slack ...), when a specific condition is met, ex: when memory usage is higher then 60%.

When prometheus scrapes data, it stores it in a time series databes, it can be local or remote.

It offers a language `PromQL` to query the database, throught prometheus UI or other advanced tools like Grafana.

### Setup For Kubernetes

We will be using the official promtheus operator

Add the officiel prometheus repository

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

Update the repository

```
helm repo update
```

Install the operator

```
helm install prometheus prometheus-community/prometheus
```

Install Grafana



