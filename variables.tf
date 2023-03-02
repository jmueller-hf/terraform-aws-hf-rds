variable "cluster_name" {
  type        = string
  description = " Cluster Identifier"
}

variable "database_name" {
  type        = string
  description = "Database Name"
}

variable "engine" {
  type        = string
  description = "RDS Database Engine"
}

variable "engine_version" {
  type        = string
  description = "RDS Database Engine Version"
  default     = ""
}

variable "instance_size" {
  type        = string
  description = "RDS Instance Size"
}

variable "master_username" {
  type        = string
  description = "Database Master Username"
  default     = "root"
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Skip Final Snapshot"
  default     = false
}

variable "backup_retention_period" {
  type        = number
  description = "Backup Retention Period"
  default     = 7
}

variable "copy_tags_to_snapshot" {
  type        = bool
  description = "Copy Tags to Snapshot"
  default     = true
}

variable "instance_count" {
  type        = string
  description = "RDS Cluster Instance Count"
  default     = "1"
}

variable "environment" {
  type        = string
}

variable "subnet_type" {
  type        = string
}

variable "account_vars" {
  type        = map
  description = "Global account variables"
}

