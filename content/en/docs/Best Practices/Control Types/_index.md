---
title: "Control Types"
linkTitle: "Control Types"
weight: 2
description: >
  VMware STIG Control Types
---

VMware STIG controls can be broken up into two categories, Product or Appliance. This helps differentiate where and how these controls are handled.

**Product Control:** Configurations that interact with the Product via the User Interface or API that are exposed to administrators. Whether these are Default or Non-Default, the risk of mis-configuration effecting availability of the product is low but could impact how the environment is operated if not assessed.  

**Appliance Control:** Appliance controls deal with the underlying components (databases, web servers, Photon OS, etc) that make up the product that is shipped as an appliance. Altering these add risk to product availability if precautionary steps and care in implementation are not taken. Identifying and relying on Default settings in this category makes this category less risky (Default Appliance Controls should be seen as a positive).  