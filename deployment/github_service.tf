locals {
  org_id = "632614034120" # meshcloud-dev
}

resource "google_organization_iam_member" "serviceAccountAdmin" {
  org_id = local.org_id
  role   = "roles/iam.serviceAccountAdmin"
  member = "serviceAccount:${google_service_account.pipeline_service_account.email}"
}

resource "google_organization_iam_member" "workloadIdentityPoolAdmin" {
  org_id = local.org_id
  role   = "roles/iam.workloadIdentityPoolAdmin"
  member = "serviceAccount:${google_service_account.pipeline_service_account.email}"
}

resource "google_organization_iam_member" "projectIamAdmin" {
  org_id = local.org_id
  role   = "roles/resourcemanager.projectIamAdmin"
  member = "serviceAccount:${google_service_account.pipeline_service_account.email}"
}

