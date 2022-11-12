variable "prefix" {
  description 	= "The prefix which should be used for all resources in this example"
  default 		= "azure-cicd"
  type 			= string
}

variable "location" {
  description   = "The Azure Region in which all resources in this example should be created."
  default 		= "Australia East"
  type 			= string
}

variable "username" {
  description 	= "The username of the virtual machines."
  default     	= "Nghianv"
  type        	= string
}

variable "password" {
  description 	= "The password of the virtual machines."
  default     	= "Nghianv@123456"
  type        	= string
}

variable "app_service_plan_sku" {
  description 	= "App service plan sku "
  default     	= "B1"
  type        	= string
}

variable "python_version" {
  description 	= "Python version for agent vm"
  default     	= "3.7"
  type        	= string
}

variable "agent_vm_size" {
  description 	= "Agent vm size"
  default     	= "Standard_B1ms"
  type        	= string
}

#20.70.192.165