# azure_nsg_in_state_57850
Checking for removal of attribute values in a dynamic loop that are not recognized by Terraform for NSG rules in Azure

# Intro

There is a claim : 

> We have a Network module we've been using for some time. As of recently, we've noticed that when we remove NSG rules from our root code that calls the module, the NSG rules are not removed from Azure and remain in the TF state. TF does not recognize that a change has happened and takes no action.
> 

This repository aims to test it.


# Step-by-step


# TODO

- [x] import & santitize customer code into "original_code" folder
- [x] make it work (code have been provided as is directly in the ticket not in ZIP archove, so potentially contains some glitches from Markup )
- [ ] clean and simplify the code to bare minimum
- [ ] check the claim 
- [ ] update readme
- [ ] update ticket and potentially file a bug
