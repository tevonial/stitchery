variable "ORG" {
  default = "tevonial"

  validation {
    condition = ORG != ""
    error_message = "ORG cannot be empty"
  }
}

variable "TAG" {
  default = "latest"

  validation {
    condition = TAG != ""
    error_message = "TAG cannot be empty"
  }
}

variable "TARGET" {
  default = "prod"

  validation {
    condition = contains(["dev", "prod"], TARGET)
    error_message = "TARGET must be either 'dev' or 'prod'"
  }
}

target "api" {
    target = TARGET
    tags = ["${ORG}/stitchery-api:${TAG}"]
}

target "frontend" {
    target = TARGET
    tags = ["${ORG}/stitchery-frontend:${TAG}"]
}

target "db" {
    tags = ["${ORG}/stitchery-db:${TAG}"]
}