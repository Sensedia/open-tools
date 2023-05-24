# ATTENTION!!!
# This feature works only with Terraform 1.1 or later
# Reference: 
# * https://developer.hashicorp.com/terraform/tutorials/configuration-language/move-config
# * https://developer.hashicorp.com/terraform/language/modules/develop/refactoring
#
# It's used by rename resource into terraform state.
# It require run terraform apply command once time. It will rename all resources of the module.
#
# Example:

#moved {
#  from = module.karpenter_irsa
#  to   = module.karpenter_irsa[0]
#}
