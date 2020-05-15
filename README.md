# DataCat

A sample monitoring system with Docker, Ruby and Pushgateway/Grafana/Prometheus.

## Requirements

* Ruby & Docker installed.

## Description and instructions

This project sets up a docker composer file with containers for pushgateway, grafana and prometheus
connected, along with n instances of linux hosts monitoring themselves and sending registries to 
pushgateway.

To run the project, use: `docker-compose up --build --scale monitor=N`,
being N the number of instances to run.
Remove `--build` flag for subsequents executions.
