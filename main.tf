provider "github" {
  owner = var.github_owner
  token = var.github_token
}

resource "github_repository" "this" {
  name       = var.repository_name
  visibility = var.repository_visibility
  auto_init  = true
}

resource "github_repository_deploy_key" "this" {
  title      = var.public_key_openssh_title
  repository = github_repository.this.name
  key        = var.public_key_openssh
  read_only  = false
}

resource "github_repository_file" "config" {
  for_each = var.configs_path_local == null ? toset([]) : fileset(var.configs_path_local, "*.yaml")

  repository          = github_repository.this.name
  branch              = "main"
  file                = "${var.configs_path_remote}/${each.value}"
  content             = file("${var.configs_path_local}/${each.value}")
  commit_message      = "Added ${each.value}"
  commit_author       = var.github_owner
  commit_email        = "terraform@example.com"
}
