terraform {
  required_version = "~> 1.9"

  required_providers {
    jira = {
      source  = "fourplusone/jira"
      version = "~> 0.1.14"
    }
  }
}

provider "jira" {
  url      = var.jira_url
  user     = var.jira_user
  password = var.jira_api_token
}

resource "jira_project" "test" {
  name = "Example Project"
  key  = "EX"
  lead = var.jira_user
}

resource "jira_issue_type" "task" {
  name        = "Task"
  description = "A task that needs to be done."
  project_id  = jira_project.example.id
}

resource "jira_automation_rule" "issue_created" {
  name    = "Issue Created Notification"
  project = jira_project.example.key
  trigger = jsonencode({
    "type" : "ISSUE_CREATED"
  })
  action = jsonencode({
    "type" : "SEND_WEB_REQUEST",
    "parameters" : {
      "url" : var.discord_webhook_url,
      "method" : "POST",
      "headers" : [
        {
          "key" : "Content-Type",
          "value" : "application/json"
        }
      ],
      "body" : {
        "content" : "New issue created: {{issue.key}} - {{issue.summary}}"
      }
    }
  })
}

variable "jira_url" {
  description = "The URL of your Jira instance"
  type        = string
}

variable "jira_user" {
  description = "Jira user email"
  type        = string
}

variable "jira_api_token" {
  description = "Jira API token"
  type        = string
  sensitive   = true
}

variable "discord_webhook_url" {
  description = "Discord webhook URL"
  type        = string
  sensitive   = true
}
