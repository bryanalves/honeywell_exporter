# honeywell_exporter

This is a simple screen-scraping metrics exporter for Honeywell Wifi enabled thermostats.  Used to track in-house temperatures and run-frequencies of your HVAC systems.  To be used with Prometheus.

# Usage

```
export THERM_USER: me@example.com
export THERM_PASSWORD: mypassword
export THERM_DEVICE_ID: 123456
bundle exec ruby app.rb
```

You can see metrics:

```
curl localhost:9100 # high level output
curl localhost:9100/metrics # In prometheus format
```
