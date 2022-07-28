#### Book

Chapter 1: Introduction to Prometheus: (Done)

* Architecture
* Client libraries
* Exporters
* Service discovery
* Scraping
* Storage
* Dashboards
* Recording rules & alerts
* Alert Management
* Long-term storage 

Chapter 2: Getting started with Prometheus (Done)

* Running prometheus
* Using the expression browser (rate function, operators (==, /, -, +))
* Running the node exporter
* Alerting

Chapter 3: Instrumentation (Done)

* Python program
* The counter (Count the size of an event, how many requests, how many times a function was called, the counter is always increasing, except if the application restarts, prometheus uses a 64 bit floating nbr, so counter can be incremented by .x and not just by one)

* The gauge (is a metric with values that goes up & down, ex: memory usage, it has 3 methods (inc, dec and set), 'time() - hello_world_last_time_seconds' is used to know the last time a request was handled)

* The summary (Used to calculate how much time an event take, ex: how much time a backend service took to respond, the method used is `observe`, we can think of summary like a composed type of multiple counters, for ex: rate(total_requests[1m]) / rate(sum(request_duration[1m]), will give us an average time of request duration)

* The histogram (Is like the summary, but allows us to calculate quantiles, it provides multiple time series for a counter, called buckets, for example, http_reques_duration{le=0.25} and http_reques_duration{le=0.5}, then we can count how many requests took less than 0.5 seconds, for ex:   rate(http_request_duration_seconds_sum[5m]) / rate(http_request_duration_seconds_count[5m]))

Same result can be reached with the 2 following request:

rate(hello_world_latency_seconds_count[1m]) / rate(hello_world_latency_seconds_sum[1m])

And 

histogram_quantile(0.95, rate(hello_world_latency_seconds_bucket[1m]))

* Buckets: For histograms, prometheus stores their values in devided equal sections called buckets, for example, if we want to calculate how much time a web server took to process an http request, we define a 0 to 10 seconds as an estimated range, then it will be devided to ten equal parts called buckets, if a request took 9.5 seconds, it will be stored in the `0.9` bucket, then we can calculate an average of multiple buckets.   
  
* Unit testing instrumentation: Taking metrics for granted can be tricky, it's always better to test metrics before consedering they are correct, for ex, testing a counter before running a function & after, to see if it increases, the coverage mustn't be 100% as it will take a lot of work, but for most important tests.

* Approaching instrumentation: we can instrument two items, services and libraries.

Services has 3 types, online services which are running and have other component waiting for them at the real time, such as a web server, a database service, in this case we would better use the RED method (Requests - Errors - Duration), offline services, such as logs centralization system, we can use the USE (Utilization - Saturation - Errors) method, and the 3rd type is `batch` jobs, which are not running always, they are only running for a specific time, we need to monitor only if the jo was succeedded, and how much time it took, and this must be scraped with the pushgateways.

Libraries: requests, latency, and errors

* Naming: for libraries (library_name_unit_suffix) and it's always better to use snake_case, that is, each
component of the name should be lowercase and separated by an underscore.

The _total, the _count, _sum, and _bucket suffixes are used by the counter, summary,
and histogram metrics. Aside from always having a _total suffix on counters,
you should avoid putting these suffixes on the end of your metric names to avoid
confusion

Chapter 4: Exposition (Done)

Python
You have already seen start_http_server in Chapter 3. It starts up a background
thread with a HTTP server that only serves Prometheus metrics.

```
from prometheus_client import start_http_server

if __name__ == '__main__':
    start_http_server(8000)
    // Your code goes here.
```

start_http_server is very convenient to get up and running quickly. But it is likely
that you already have a HTTP server in your application that you would like your
metrics to be served from.
In Python there are various ways this can be done depending on which frameworks
you are using.

* Pushgateways: Are used to store batch jobs metrics, whenever a batch jobs gets executed, it send its metrics to pushgateway before exiting, pushgateway metrics doesn't have an `instance` label, when running a pushgateway, the following config needs to be added so prometheus can scrape it.

```
scrape_configs:
  - job_name: pushgateway
    honor_labels: true
    static_configs:
      - targets:
        - localhost:9091    
```

* Bridges: Client libraries can convert & output prometheus metrics to other systems, such as `graphite`
 
Chapter 5: Labels (Done)

* Labels are key value pairs that identifies timeseries, they help organize metrics and working with promql, for ex: if we want to calculate the rate of requests for each path, we can create a metric for each path, which needs a lot of work, instead we can create one metric, & attach a `path` label to each timserie.

* Labels come from two sources, instrumentation labels and target labels.

* Instumentation: ex: `07-labels.py`, Snake case is the convention for label names

* A metric can be a timeseries, a child or a metric family, when we create a histogram, it automatically creates a metric family and childs, anf finally timeseries

* We can create multiple labels, and calls and methods should respect the order of labels.  
  
* Child: a child metric can be tricky to work with, it appears only when its called through code, we can initialize it to make it always present.

* Aggregation: if we want to calculate the rate of total requests 'sum without(path)(rate(hello_worlds_total[5m]))', the `without` removes the path label, in contrast to `without`, `by` clause is used to specify the labels to group with.

* info: a common use case of strings is to store infos about the application, in a gauge metric, its value will be always 1, & it will have labels such as version or application name, these should be suffixed with `_info`

* Cardinality: adding a simple label, to a histogram with 10 buckets, will give us 100 time series, so we need to be aware of cardinality of our metrics, it should be lower than in most metrics.

Chapter 6: Dashboarding with Grafana (Very basic concepts) (Done)

* To install grafana, reffer to standalone directory.

* After installing grafana, a `data source` must be added to retrieve data, grafana supports multiple data sources (Prometheus, Elasticsearch, Zabbix, Mysql ...)

* Creating a dashboard which has too many pannels & rows is an antipattern in grafana, we need to keep dashboards as small as possible, & create general & detailed types of dashboards.

* Graph panel:

Chapter 7: Node exporter (CPU, Memory, Disk, Network ...) (Done)

* CPU collector:

To calculate the average of each state of the cpu for all CPUs:
avg without(cpu, mode)(rate(node_cpu_seconds_total{mode="idle"}[1m]))

To calculate the cpu load, we will use the idle time (when the cpu has nothing to perform), (100% - idle time)
cpu load by machine: '100 - (avg by (instance) (irate(node_cpu_seconds_total{job!="",mode="idle"})) * 100)'

* Filesystem collector (Disk Usage)

Free disk space:
node_filesystem_avail_bytes / node_filesystem_size_bytes

Disk Usage of /:
100 - ((node_filesystem_avail_bytes{mountpoint="/",fstype!="rootfs"} * 100) / node_filesystem_size_bytes{mountpoint="/",fstype!="rootfs"})

* Diskstats collector (Disk Inout Output Stats)

Disk I/O utilization:
rate(node_disk_io_time_seconds_total[1m])

average time for read I/O:
rate(node_disk_io_time_seconds_total[1m])

Disk IOps Completed:
irate(node_disk_reads_completed_total{device="sda"}[1h])

Disk R/W Data:
irate(node_disk_read_bytes_total[5m])
irate(node_disk_written_bytes_total[5m])

* Netdev collector (Network Device Stats)

Number of packets received of a specific interface:
rate(node_network_receive_bytes_total{device="wlp2s0"}[1m]) 

Network traffic by packets:
irate(node_network_receive_packets_total[5m]) 
irate(node_network_transmit_packets_total[5m])

Network Traffic Errors:
irate(node_network_receive_errs_total{instance=~"$node:$port",job=~"$job"}[5m])
irate(node_network_transmit_errs_total[5m])

Network Traffic Drop:
irate(node_network_receive_drop_total[5m])
irate(node_network_transmit_drop_total[5m])

* Meminfo collector

Used RAM Memory:
100 - ((node_memory_MemAvailable_bytes * 100) / node_memory_MemTotal_bytes)

Swap:
((node_memory_SwapTotal_bytes - node_memory_SwapFree_bytes) / (node_memory_SwapTotal_bytes )) * 100

* HWmon collector (Hardware Monitor, used in bare metal env)

Labels of each cpu core:
node_hwmon_sensor_label

Temperature of each component: (use labels ti retrieve specific core)
node_hwmon_temp_celsius

* Stat collector

Uptime:
time() - node_boot_time_seconds

* Uname collector
* Loadavg collector
* Textfile collector

Cahpter 8: Service Discovery Done

When monitoring a network with few static machines, static configuration will do the job, but when working with a highly dynamic environment like k8s or even a huge architecture in the cloud, thiw will be tough.

That's why we use `service discovery`, so prometheus will dynamically find targets to scrape, service discovery supports a lot of mechanisms:

* Static (An ansible template can be used to generate the list of machines we have), ex:

```
scrape_configs:
- job_name: node
static_configs:
- targets:
{% for host in groups["all"] %}
- {{ host }}:9100
{% endfor %}
```

* File (Prometheus can read the list of targets from a JSON or YAML file), which can be generated by another mechanism, ex:

```
[
  {
    "targets": [ "host1:9100", "host2:9100" ],
    "labels": {
      "team": "infra",
      "job": "node"
  }
},
  {
  "targets": [ "host1:9090" ],
  "labels": {
    "team": "monitoring",
    "job": "prometheus"
  }
}
```

Then, we specify the path of our file in `scrape_configs` section

```
scrape_configs:
- job_name: file
file_sd_configs:
- files:
- '*.json'
```

* Consul (can be used to dinamically feed prometheus with the list of targets to scrape), ex:

```
scrape_configs:
- job_name: consul
consul_sd_configs:
- server: 'localhost:8500'
```

* EC2 (can be used in AWS environments, prometheus should be running in the same network as targets to avoid cost issues), ex:

```
scrape_configs:
- job_name: ec2
ec2_sd_configs:
- region: <region>
access_key: <access key>
secret_key: <secret key>
```

#### Relabelling




Chapter 9: Containers and kubernetes (Done)

* cAdvisor: Exporter that provides metrics about cgroups

Kubernetes:

Service discovery:

* nodes
* endpoints
* service
* Pod
* Ingress




