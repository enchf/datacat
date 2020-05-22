# Implementation Details

## Solution description.

It consists of three parts:

* A monitoring agent reporting the current state of an instance, build as a Ruby gem.
* The monitoring system with scrapes metrics.
* An orchestration done by Docker compose in order to start the monitoring system
and N number of hosts being monitored by the Ruby gem agent.

### Ruby agent

The Ruby agent, named `Datacat`, is build as a Ruby gem and is installed and run in
an instance gathering metrics and reporting them to a monitoring system, in this case
Prometheus Pushgateway.

Advantages of having it as a Ruby gem:

* Ruby is a more readable language than bash or Go.
* It doesn't depend of a cronjob to execute, taking care of the metrics continuous reporting.
* Ruby is easier to configure and having the dependencies environment than Python pipenv (among others).
* Prometheus client Library written in Ruby is very easy to use.
* It can be uploaded to a Rubygems server and easily installed on each instance.
* Provisioning systems could easily replicate the installation of a Ruby gem.
* In Docker, Ruby image uses less memory than other languages images (Rust, Go).

Structure:

* It consist of a bin executable, which instantiate a Monitor object and put it to run.
* Gem encapsulates a OS command executor as a mixin, easier to integrate in other clases.
* For different OS, a Strategy pattern + an Abstract Factory are provided to encapsulate this differentiation.
* An improvement would be to add another strategy + abstract factory to support different monitoring systems.
* The use of design patterns makes this gem to be scalable and customizable for multiple OS and monitoring tools.
* Another improvement is to make the gem fully configurable at execution through CL options.

### Monitoring system

Prometheus infrastructure is chosen for its ease to install, because it is open source and
Pushgateway is included to facilitate the metrics scrapping from Prometheus server. Grafana is included
to make easier and fancier the visualization of metrics.

### Docker orchestration.

To easily replicate an environment with N number of hosts, a docker compose file is created to create
a network between the monitoring systems and the monitored N hosts. To simulate different loads of work
in each instance, a Ruby script which sorts a random size array of numbers is running each certain seconds.
This script can be improved with a more realistic job and a real differentiation in memory usage, as the
sorting arrays are almost equal in amount of memory used.


## Questions beyond the solution

### 1

```
How do you know that the metrics collected are working correctly?
```

For the metrics gathering, there were two approaches:

* Passive approach. Enable an interface in the instance that provides the
metrics on demand. There could be different ways to achieve this. One is to
allow the instance to be scrapped directly using SSH to execute the metrics command.
Another option could be to implement a TCP/IP lightweight server (i.e. using Ruby stdlib).
* Active approach. Allow instances to report to an entity (in this case Pushgateway).
The reporting entity on each instance could be easily replicated using a Ruby gem,
which is the solution approach, a snap, a package, a bash script with a cronjob, etc.

As metrics are taken as snapshots directly from the instance (using top command in
the case of Alpine Linux and Mac OSX), they reflect correctly the current state.
An alarm can be configured in the monitoring system when an instance stops reporting.

### 2

```
What monitoring infrastructure and/or metrics would you put in place for the metrics
backend if this was a production server?
```

Other useful metrics that could be collected are CPU usage (using same top command)
and Disk usage of the instance. Network availability, if the instance is required to
connect to external services/other instances. If the instance holds an application,
a binary (yes/no) health indicator of the application would be useful.

### 3

```
Please describe in detail your proposed architecture with specific tools/systems and
your design goals.
```

Starting from what we have in the solution, if we want to continue in the path of open
source tooks, AlertManager from Prometheus set of tools would be good to follow up metrics
and alerts. In this stack, preserving Pushgateway is important to separate the monitored
instances from the scrapping of Prometheus service. If the path of a managed system is 
chosen, Datadog would be an excellent option to gather all metrics.

All the infrastructure should be versioned, using tools such as Ansible or Terraform.
This in order to keep the infrastructure replicable, to facilitate testing, to automate
the creation of application environments, to deploy the application into a working
infrastructure, etc.

### 4

```
There are 1% of hosts (out of a fleet of 10K hosts) that are OOMing every hour (with the
Linux OOM killer kicking in). How would you discover and monitor that the hosts were in
fact running out of memory?
```

An alert management system is important to detect such cases, preserving the historical
data about these misworking nodes, to trace the metrics evolution. In case these OOM errors
make instances being unable to report metrics data, an alert of reporting absence would be
very useful along with having local logs per instance preserved (being careful of disk usage) 
that could be accessed to trace what really causes the instance to stop reporting.

### 5

```
What action would you take to automatically remediate the issue?
```

Restarting a stateful instance would be the first approach. Another approach is, taking
advantage of the versioned and replicable infrastructure, simply kill and replace the
misworking nodes. Another example is what is stated about Netflix architecture in the book
"Devops Handbook", identifying `outliers` and nodes that are working different that the 
common patterns, and removing and replacing them automatically. In this case, logs are 
important to be sent to both the development and operations teams to execute proper changes
to improve performance.
