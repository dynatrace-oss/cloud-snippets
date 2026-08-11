terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# ---------------------------------------------------------------------------
# Enable required APIs
# ---------------------------------------------------------------------------
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "pubsub.googleapis.com",
    "containeranalysis.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ])

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# ---------------------------------------------------------------------------
# Service account for the Cloud Run function
# ---------------------------------------------------------------------------
resource "google_service_account" "function_sa" {
  project      = var.project_id
  account_id   = "${var.function_name}-sa"
  display_name = "Service account for ${var.function_name} Cloud Run function"

  depends_on = [google_project_service.apis]
}

# Grant the SA permission to read Container Analysis occurrences
resource "google_project_iam_member" "ca_viewer" {
  project = var.project_id
  role    = "roles/containeranalysis.occurrences.viewer"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

# Grant the SA permission to read image details from Artifact Registry 
resource "google_project_iam_member" "ar_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

# Allow the function SA to access the secret with the DT API token
resource "google_secret_manager_secret_iam_member" "function_sa_secret_access" {
  project   = var.project_id
  secret_id = var.dt_api_token_secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.function_sa.email}"
}

# ---------------------------------------------------------------------------
# Pub/Sub topic (data source – assumes topic already exists)
# ---------------------------------------------------------------------------
data "google_pubsub_topic" "occurrences" {
  project = var.project_id
  name    = "container-analysis-occurrences-v1"

  depends_on = [google_project_service.apis]
}

# ---------------------------------------------------------------------------
# Download the function source code from GitHub
# ---------------------------------------------------------------------------
resource "null_resource" "download_function_source" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "curl -fsSL -o ${path.module}/function-source.zip ${var.function_source_url}"
  }
}

resource "random_id" "function_source_suffix" {
  byte_length = 4

  keepers = {
    always_run = timestamp()
  }
}

# Upload source zip to a GCS bucket
resource "google_storage_bucket" "function_source" {
  project                     = var.project_id
  name                        = "${var.project_id}-${var.function_name}-source"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true

  depends_on = [google_project_service.apis]
}

resource "google_storage_bucket_object" "function_source_zip" {
  name   = "function-source-${random_id.function_source_suffix.hex}.zip"
  bucket = google_storage_bucket.function_source.name
  source = "${path.module}/function-source.zip"

  depends_on = [null_resource.download_function_source]
}

# ---------------------------------------------------------------------------
# Cloud Run Function (gen2)
# ---------------------------------------------------------------------------
resource "google_cloudfunctions2_function" "process_occurrence" {
  project  = var.project_id
  name     = var.function_name
  location = var.region

  depends_on = [google_project_service.apis]

  build_config {
    runtime     = "go126"
    entry_point = "process_occurrence"

    source {
      storage_source {
        bucket = google_storage_bucket.function_source.name
        object = google_storage_bucket_object.function_source_zip.name
      }
    }
  }

  service_config {
    available_memory                 = "256Mi"
    available_cpu                    = "1"
    timeout_seconds                  = 60
    max_instance_count               = var.max_instances
    min_instance_count               = var.min_instances
    max_instance_request_concurrency = var.concurrency
    service_account_email            = google_service_account.function_sa.email

    environment_variables = {
      DT_BASE_URL      = var.dt_base_url
      GCP_ORG_ID       = var.gcp_org_id
      GCP_ORG_NAME     = var.gcp_org_name
      LOG_EXECUTION_ID = "true"
    }

    secret_environment_variables {
      key        = "DT_API_TOKEN"
      project_id = var.project_id
      secret     = var.dt_api_token_secret_id
      version    = "latest"
    }
  }

  event_trigger {
    trigger_region        = var.region
    event_type            = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic          = data.google_pubsub_topic.occurrences.id
    retry_policy          = "RETRY_POLICY_RETRY"
    service_account_email = google_service_account.function_sa.email
  }
}

# Grant Pub/Sub publisher permissions to invoke the function's SA
# (needed for Pub/Sub to push events to the Cloud Run service)
resource "google_project_iam_member" "pubsub_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}
