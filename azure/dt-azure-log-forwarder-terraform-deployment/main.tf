# deploy forwarder function
module "dt_log_forwarder_infrastructure" {
  source = "./_modules/dt-log-forwarder/infrastructure"
  deployment_name = "dtazurelgfwd"
  location =  "West Europe"
  dynatrace_url = ""
  dynatrace_access_key = ""
  event_hub_name = ""
  event_hub_connection_string = ""
  require_valid_certificate = true
  version_number = "0.2.2"
}
