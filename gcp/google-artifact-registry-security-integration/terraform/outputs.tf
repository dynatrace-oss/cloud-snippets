output "function_url" {
  description = "The URL of the deployed Cloud Run function."
  value       = google_cloudfunctions2_function.process_occurrence.service_config[0].uri
}

output "function_service_account" {
  description = "The service account email used by the Cloud Run function."
  value       = google_service_account.function_sa.email
}
