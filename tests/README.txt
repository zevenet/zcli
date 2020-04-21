# The tests in this directory are bash scripts that execute commands
# against a load balancer. 

# Requirements:
#  - zcli has to be installed in the host where tests are being executed
#  - zcli has to be executed previously in order to configure a load balancer
#  - If zcli has configured more than one load balancer, the default one will be used